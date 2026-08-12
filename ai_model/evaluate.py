"""
SmartCrop AI — Model Evaluation
=================================
Evaluates the trained MobileViT model on the test set.
Generates accuracy, precision, recall, F1-score,
and confusion matrix. All metrics are REAL — no faking.
"""

import json
from pathlib import Path

import torch
import numpy as np
import timm
from torch.utils.data import DataLoader
from torchvision.datasets import ImageFolder
from sklearn.metrics import (
    classification_report,
    confusion_matrix,
    accuracy_score,
)

from config import (
    TEST_DIR, CHECKPOINT_DIR, MODEL_NAME, IMAGE_SIZE,
    BATCH_SIZE, NUM_WORKERS, CLASS_NAMES_FILE,
)
from preprocessing import get_eval_transforms


def evaluate():
    """Evaluate the best model on the test set."""
    print("=" * 60)
    print("  SMARTCROP AI — MODEL EVALUATION")
    print("=" * 60)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"\n  Device: {device}")

    # ─── Load checkpoint ──────────────────────────────────
    ckpt_path = CHECKPOINT_DIR / "best_model.pth"
    if not ckpt_path.exists():
        print(f"  [X] No checkpoint found at {ckpt_path}")
        print("  Please train the model first: python train.py")
        return

    checkpoint = torch.load(ckpt_path, map_location=device, weights_only=False)
    class_names = checkpoint["class_names"]
    num_classes = checkpoint["num_classes"]
    model_name = checkpoint.get("model_name", MODEL_NAME)

    print(f"  Model: {model_name}")
    print(f"  Classes: {num_classes}")
    print(f"  Checkpoint epoch: {checkpoint['epoch']}")
    print(f"  Checkpoint val acc: {checkpoint['val_acc']:.1f}%")

    # ─── Load model ───────────────────────────────────────
    model = timm.create_model(model_name, pretrained=False, num_classes=num_classes)
    model.load_state_dict(checkpoint["model_state_dict"])
    model = model.to(device)
    model.eval()

    # ─── Test dataset ─────────────────────────────────────
    test_dataset = ImageFolder(str(TEST_DIR), transform=get_eval_transforms())
    test_loader = DataLoader(
        test_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False,
        num_workers=NUM_WORKERS,
    )
    print(f"  Test images: {len(test_dataset)}")

    # ─── Inference ────────────────────────────────────────
    all_preds = []
    all_labels = []
    all_probs = []

    print("\n  Running evaluation...")
    with torch.no_grad():
        for batch_idx, (inputs, labels) in enumerate(test_loader):
            inputs = inputs.to(device)
            outputs = model(inputs)
            probs = torch.softmax(outputs, dim=1)

            _, predicted = outputs.max(1)
            all_preds.extend(predicted.cpu().numpy())
            all_labels.extend(labels.numpy())
            all_probs.extend(probs.cpu().numpy())

            if (batch_idx + 1) % 10 == 0:
                print(f"\r  Batch {batch_idx+1}/{len(test_loader)}", end="")

    all_preds = np.array(all_preds)
    all_labels = np.array(all_labels)

    # ─── Metrics ──────────────────────────────────────────
    accuracy = accuracy_score(all_labels, all_preds) * 100

    print(f"\n\n  Overall Test Accuracy: {accuracy:.2f}%\n")

    # Classification report
    report = classification_report(
        all_labels, all_preds,
        target_names=class_names,
        digits=4,
        output_dict=True,
    )

    # Print report
    report_str = classification_report(
        all_labels, all_preds,
        target_names=class_names,
        digits=4,
    )
    print("  Classification Report:")
    print("  " + report_str.replace("\n", "\n  "))

    # Confusion matrix
    cm = confusion_matrix(all_labels, all_preds)

    # ─── Save results ─────────────────────────────────────
    results = {
        "accuracy": accuracy,
        "num_classes": num_classes,
        "test_images": len(test_dataset),
        "class_names": class_names,
        "per_class": {},
        "confusion_matrix": cm.tolist(),
    }

    for i, name in enumerate(class_names):
        if name in report:
            results["per_class"][name] = {
                "precision": report[name]["precision"],
                "recall": report[name]["recall"],
                "f1_score": report[name]["f1-score"],
                "support": report[name]["support"],
            }

    results_path = CHECKPOINT_DIR / "evaluation_results.json"
    with open(results_path, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\n  [OK] Results saved to {results_path}")

    # ─── Generate confusion matrix plot ───────────────────
    try:
        generate_confusion_matrix(cm, class_names)
        generate_training_curves()
    except Exception as e:
        print(f"  [!] Could not generate plots: {e}")

    # ─── Generate training report ─────────────────────────
    generate_training_report(results, checkpoint)

    print("\n" + "=" * 60)
    print("  EVALUATION COMPLETE")
    print("=" * 60)

    return results


def generate_confusion_matrix(cm, class_names):
    """Generate and save a confusion matrix heatmap."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import seaborn as sns

    # Shorten class names for display
    short_names = [n.split("___")[1].replace("_", " ")[:20] for n in class_names]

    fig, ax = plt.subplots(figsize=(14, 12))
    sns.heatmap(
        cm, annot=True, fmt="d", cmap="Greens",
        xticklabels=short_names,
        yticklabels=short_names,
        ax=ax, linewidths=0.5,
    )
    ax.set_xlabel("Predicted", fontsize=12)
    ax.set_ylabel("Actual", fontsize=12)
    ax.set_title("SmartCrop AI - Confusion Matrix", fontsize=14, fontweight="bold")
    plt.xticks(rotation=45, ha="right", fontsize=8)
    plt.yticks(rotation=0, fontsize=8)
    plt.tight_layout()

    save_path = Path(__file__).parent.parent / "docs" / "confusion_matrix.png"
    plt.savefig(save_path, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"  [OK] Confusion matrix saved to {save_path}")


def generate_training_curves():
    """Generate training loss/accuracy curves from saved history."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    history_path = CHECKPOINT_DIR / "training_history.json"
    if not history_path.exists():
        return

    with open(history_path) as f:
        history = json.load(f)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    epochs = range(1, len(history["train_loss"]) + 1)

    # Loss
    ax1.plot(epochs, history["train_loss"], "o-", color="#2E7D32", label="Train Loss")
    ax1.plot(epochs, history["val_loss"], "o-", color="#EF4444", label="Val Loss")
    ax1.set_xlabel("Epoch")
    ax1.set_ylabel("Loss")
    ax1.set_title("Training & Validation Loss", fontweight="bold")
    ax1.legend()
    ax1.grid(alpha=0.3)

    # Accuracy
    ax2.plot(epochs, history["train_acc"], "o-", color="#2E7D32", label="Train Acc")
    ax2.plot(epochs, history["val_acc"], "o-", color="#1565C0", label="Val Acc")
    ax2.set_xlabel("Epoch")
    ax2.set_ylabel("Accuracy (%)")
    ax2.set_title("Training & Validation Accuracy", fontweight="bold")
    ax2.legend()
    ax2.grid(alpha=0.3)

    plt.suptitle("SmartCrop AI - Training Curves", fontsize=14, fontweight="bold")
    plt.tight_layout()

    save_path = Path(__file__).parent.parent / "docs" / "training_curves.png"
    plt.savefig(save_path, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"  [OK] Training curves saved to {save_path}")


def generate_training_report(results, checkpoint):
    """Generate a markdown training report."""
    report_path = Path(__file__).parent.parent / "docs" / "training_report.md"

    lines = [
        "# SmartCrop AI — Training & Evaluation Report\n",
        "## Model Configuration\n",
        f"| Setting | Value |",
        f"|---|---|",
        f"| Model | {checkpoint.get('model_name', 'mobilevit_xxs')} |",
        f"| Input Size | {checkpoint.get('image_size', 256)}×{checkpoint.get('image_size', 256)} |",
        f"| Classes | {results['num_classes']} |",
        f"| Best Epoch | {checkpoint['epoch']} |",
        f"| Test Images | {results['test_images']} |",
        "",
        f"## Overall Results\n",
        f"| Metric | Value |",
        f"|---|---|",
        f"| **Test Accuracy** | **{results['accuracy']:.2f}%** |",
        "",
        "## Per-Class Results\n",
        "| Class | Precision | Recall | F1-Score | Support |",
        "|---|---|---|---|---|",
    ]

    for name, metrics in results["per_class"].items():
        display_name = name.replace("___", " > ").replace("_", " ")
        lines.append(
            f"| {display_name} | "
            f"{metrics['precision']:.4f} | "
            f"{metrics['recall']:.4f} | "
            f"{metrics['f1_score']:.4f} | "
            f"{int(metrics['support'])} |"
        )

    lines.extend([
        "",
        "> All metrics are computed from actual model predictions on the held-out test set.",
        "> No metrics are fabricated.",
    ])

    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"  [OK] Training report saved to {report_path}")


if __name__ == "__main__":
    evaluate()
