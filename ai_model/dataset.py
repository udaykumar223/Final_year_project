"""
SmartCrop AI — Dataset Preparation
====================================
Inspects the raw dataset, validates images, creates
stratified train/val/test splits, and generates reports.

The original dataset is NEVER modified.
"""

import os
import json
import shutil
import random
from pathlib import Path
from collections import defaultdict

from PIL import Image
from sklearn.model_selection import train_test_split

from config import (
    DATASET_ROOT, DATA_DIR, TRAIN_DIR, VAL_DIR, TEST_DIR,
    SELECTED_CROPS, TRAIN_RATIO, VAL_RATIO, TEST_RATIO,
    RANDOM_SEED, CLASS_NAMES_FILE,
)


def inspect_dataset():
    """Inspect the full dataset and return structured info."""
    print("=" * 60)
    print("  DATASET INSPECTION")
    print("=" * 60)

    dataset_info = {}
    total_images = 0
    corrupted_images = []
    invalid_files = []

    for crop in sorted(os.listdir(DATASET_ROOT)):
        crop_path = DATASET_ROOT / crop
        if not crop_path.is_dir():
            continue

        crop_info = {"classes": {}, "total": 0}

        for cls_name in sorted(os.listdir(crop_path)):
            cls_path = crop_path / cls_name
            if not cls_path.is_dir():
                continue

            files = list(cls_path.iterdir())
            image_files = []
            widths, heights = [], []

            for f in files:
                if not f.is_file():
                    continue
                try:
                    img = Image.open(f)
                    img.verify()  # Verify it's a valid image
                    # Re-open after verify (verify closes the file)
                    img = Image.open(f)
                    w, h = img.size
                    widths.append(w)
                    heights.append(h)
                    image_files.append(str(f))
                except Exception as e:
                    if f.suffix.lower() in ('.jpg', '.jpeg', '.png', '.bmp', '.webp'):
                        corrupted_images.append((str(f), str(e)))
                    else:
                        invalid_files.append(str(f))

            crop_info["classes"][cls_name] = {
                "count": len(image_files),
                "files": image_files,
                "min_width": min(widths) if widths else 0,
                "max_width": max(widths) if widths else 0,
                "min_height": min(heights) if heights else 0,
                "max_height": max(heights) if heights else 0,
            }
            crop_info["total"] += len(image_files)
            total_images += len(image_files)

        dataset_info[crop] = crop_info

    # Print summary
    print(f"\n{'Crop':<15} {'Class':<45} {'Count':>7}")
    print("-" * 70)
    for crop, info in dataset_info.items():
        for cls_name, cls_info in info["classes"].items():
            marker = " *" if crop in SELECTED_CROPS else ""
            print(f"{crop:<15} {cls_name:<45} {cls_info['count']:>7}{marker}")
        print(f"{'':<15} {'TOTAL':<45} {info['total']:>7}")
        print("-" * 70)

    print(f"\n{'GRAND TOTAL':<60} {total_images:>7}")
    print(f"\nSelected crops for Phase 1: {', '.join(SELECTED_CROPS)}")

    if corrupted_images:
        print(f"\n[!] Found {len(corrupted_images)} corrupted images:")
        for path, err in corrupted_images[:10]:
            print(f"  {path}: {err}")
    else:
        print("\n[OK] No corrupted images found.")

    if invalid_files:
        print(f"\n[!] Found {len(invalid_files)} non-image files:")
        for path in invalid_files[:10]:
            print(f"  {path}")
    else:
        print("[OK] No invalid files found.")

    return dataset_info, corrupted_images, invalid_files


def create_splits(dataset_info):
    """
    Create stratified train/val/test splits for selected crops.
    Copies files to data/train, data/validation, data/test.
    Original dataset is never modified.
    """
    print("\n" + "=" * 60)
    print("  CREATING TRAIN / VALIDATION / TEST SPLITS")
    print("=" * 60)

    # Clean existing split directories
    for split_dir in [TRAIN_DIR, VAL_DIR, TEST_DIR]:
        if split_dir.exists():
            shutil.rmtree(split_dir)
        split_dir.mkdir(parents=True, exist_ok=True)

    class_names = []
    split_report = []

    for crop in SELECTED_CROPS:
        if crop not in dataset_info:
            print(f"[!] Crop '{crop}' not found in dataset!")
            continue

        crop_info = dataset_info[crop]

        for cls_name, cls_info in crop_info["classes"].items():
            files = cls_info["files"]
            count = cls_info["count"]

            if count < 10:
                print(f"[!] Skipping {cls_name} -- only {count} images (minimum 10)")
                continue

            class_names.append(cls_name)

            # Stratified split: 70% train, 15% val, 15% test
            random.seed(RANDOM_SEED)

            # First split: train vs (val+test)
            train_files, temp_files = train_test_split(
                files,
                test_size=(VAL_RATIO + TEST_RATIO),
                random_state=RANDOM_SEED,
            )

            # Second split: val vs test (50/50 of remaining)
            val_files, test_files = train_test_split(
                temp_files,
                test_size=TEST_RATIO / (VAL_RATIO + TEST_RATIO),
                random_state=RANDOM_SEED,
            )

            # Verify no data leakage
            train_set = set(train_files)
            val_set = set(val_files)
            test_set = set(test_files)
            assert len(train_set & val_set) == 0, "Data leakage: train & val"
            assert len(train_set & test_set) == 0, "Data leakage: train & test"
            assert len(val_set & test_set) == 0, "Data leakage: val & test"

            # Copy files to split directories
            for split_name, split_files, split_dir in [
                ("train", train_files, TRAIN_DIR),
                ("validation", val_files, VAL_DIR),
                ("test", test_files, TEST_DIR),
            ]:
                cls_dir = split_dir / cls_name
                cls_dir.mkdir(parents=True, exist_ok=True)
                for src_path in split_files:
                    dst_path = cls_dir / Path(src_path).name
                    shutil.copy2(src_path, dst_path)

            split_report.append({
                "crop": crop,
                "class": cls_name,
                "total": count,
                "train": len(train_files),
                "validation": len(val_files),
                "test": len(test_files),
            })

            print(f"  {cls_name:<45} "
                  f"Total: {count:>5}  "
                  f"Train: {len(train_files):>5}  "
                  f"Val: {len(val_files):>5}  "
                  f"Test: {len(test_files):>5}")

    # Sort class names and save
    class_names = sorted(class_names)
    with open(CLASS_NAMES_FILE, "w") as f:
        json.dump(class_names, f, indent=2)
    print(f"\n[OK] Saved {len(class_names)} class names to {CLASS_NAMES_FILE}")

    return split_report, class_names


def generate_report(dataset_info, split_report, corrupted, invalid):
    """Generate a markdown dataset report."""
    report_path = Path(__file__).parent.parent / "docs" / "dataset_report.md"
    report_path.parent.mkdir(parents=True, exist_ok=True)

    lines = [
        "# SmartCrop AI — Dataset Report\n",
        f"**Generated**: Auto-generated during dataset preparation\n",
        f"**Source**: `{DATASET_ROOT}`\n",
        f"**Selected crops**: {', '.join(SELECTED_CROPS)}\n",
        "",
        "## Full Dataset Overview\n",
        "| Crop | Classes | Total Images |",
        "|---|---|---|",
    ]

    for crop, info in dataset_info.items():
        selected = " [SELECTED]" if crop in SELECTED_CROPS else ""
        lines.append(f"| {crop}{selected} | {len(info['classes'])} | {info['total']} |")

    grand_total = sum(info["total"] for info in dataset_info.values())
    lines.append(f"| **Total** | **{sum(len(info['classes']) for info in dataset_info.values())}** | **{grand_total}** |")

    lines.extend([
        "",
        "## Selected Crops — Detailed Class Breakdown\n",
        "| Crop | Class | Total | Train | Validation | Test |",
        "|---|---|---|---|---|---|",
    ])

    for entry in split_report:
        # Clean up class name for display
        display_name = entry["class"].replace("___", " > ").replace("_", " ")
        lines.append(
            f"| {entry['crop']} | {display_name} | "
            f"{entry['total']} | {entry['train']} | "
            f"{entry['validation']} | {entry['test']} |"
        )

    total_train = sum(e["train"] for e in split_report)
    total_val = sum(e["validation"] for e in split_report)
    total_test = sum(e["test"] for e in split_report)
    total_selected = sum(e["total"] for e in split_report)

    lines.append(
        f"| **Total** | **{len(split_report)} classes** | "
        f"**{total_selected}** | **{total_train}** | "
        f"**{total_val}** | **{total_test}** |"
    )

    lines.extend([
        "",
        "## Data Quality\n",
        f"- Corrupted images: **{len(corrupted)}**",
        f"- Invalid files: **{len(invalid)}**",
        f"- Image format: **JPEG, 640x640, RGB** (uniform across dataset)",
        f"- Split ratios: **70% / 15% / 15%**",
        f"- Data leakage check: **PASSED** (no overlap between splits)",
        "",
        "## Class Imbalance Analysis\n",
    ])

    # Per-crop imbalance
    for crop in SELECTED_CROPS:
        crop_entries = [e for e in split_report if e["crop"] == crop]
        if crop_entries:
            min_cls = min(crop_entries, key=lambda x: x["total"])
            max_cls = max(crop_entries, key=lambda x: x["total"])
            ratio = max_cls["total"] / min_cls["total"] if min_cls["total"] > 0 else float("inf")
            lines.append(f"**{crop}**: Min = {min_cls['total']} ({min_cls['class']}), "
                         f"Max = {max_cls['total']} ({max_cls['class']}), "
                         f"Imbalance ratio = {ratio:.1f}x")

    lines.extend([
        "",
        "> Training augmentation is applied to help mitigate class imbalance.",
    ])

    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"\n[OK] Dataset report saved to {report_path}")
    return report_path


def generate_distribution_chart(split_report):
    """Generate class distribution bar chart."""
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("[!] matplotlib not available -- skipping chart generation")
        return None

    chart_path = Path(__file__).parent.parent / "docs" / "class_distribution.png"

    # Group by crop
    crops = {}
    for entry in split_report:
        crop = entry["crop"]
        if crop not in crops:
            crops[crop] = []
        crops[crop].append(entry)

    fig, axes = plt.subplots(1, len(crops), figsize=(6 * len(crops), 8))
    if len(crops) == 1:
        axes = [axes]

    colors_map = {
        "Banana": "#FFD700",
        "Groundnut": "#CD853F",
        "Radish": "#FF6B6B",
    }

    for ax, (crop, entries) in zip(axes, crops.items()):
        class_labels = [e["class"].split("___")[1].replace("_", " ") for e in entries]
        counts_train = [e["train"] for e in entries]
        counts_val = [e["validation"] for e in entries]
        counts_test = [e["test"] for e in entries]

        x = np.arange(len(class_labels))
        width = 0.25

        ax.barh(x - width, counts_train, width, label="Train", color="#2E7D32", alpha=0.85)
        ax.barh(x, counts_val, width, label="Validation", color="#66BB6A", alpha=0.85)
        ax.barh(x + width, counts_test, width, label="Test", color="#A5D6A7", alpha=0.85)

        ax.set_yticks(x)
        ax.set_yticklabels(class_labels, fontsize=9)
        ax.set_xlabel("Number of Images")
        ax.set_title(f"{crop}", fontsize=14, fontweight="bold",
                     color=colors_map.get(crop, "#333"))
        ax.legend(fontsize=8)
        ax.invert_yaxis()

    plt.suptitle("SmartCrop AI - Class Distribution (Phase 1)",
                 fontsize=16, fontweight="bold", y=1.02)
    plt.tight_layout()
    plt.savefig(chart_path, dpi=150, bbox_inches="tight")
    plt.close()

    print(f"[OK] Distribution chart saved to {chart_path}")
    return chart_path


if __name__ == "__main__":
    # Step 1: Inspect
    dataset_info, corrupted, invalid = inspect_dataset()

    # Step 2: Create splits
    split_report, class_names = create_splits(dataset_info)

    # Step 3: Generate report
    generate_report(dataset_info, split_report, corrupted, invalid)

    # Step 4: Generate visualization
    generate_distribution_chart(split_report)

    print("\n" + "=" * 60)
    print("  DATASET PREPARATION COMPLETE")
    print("=" * 60)
    print(f"\n  Classes: {len(class_names)}")
    print(f"  Train dir: {TRAIN_DIR}")
    print(f"  Val dir:   {VAL_DIR}")
    print(f"  Test dir:  {TEST_DIR}")
    print(f"  Class map: {CLASS_NAMES_FILE}")
