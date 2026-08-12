"""
SmartCrop AI — MobileViT Training
===================================
Trains MobileViT on the prepared dataset with:
- Pretrained ImageNet weights (transfer learning)
- Class-weighted cross-entropy for imbalance
- Early stopping
- Best checkpoint saving
- Training history logging
"""

import os
import sys
import json
import time
import copy
from pathlib import Path

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision.datasets import ImageFolder
import timm
import numpy as np
from collections import Counter

from config import (
    TRAIN_DIR, VAL_DIR, MODEL_NAME, IMAGE_SIZE,
    BATCH_SIZE, NUM_EPOCHS, LEARNING_RATE, WEIGHT_DECAY,
    NUM_WORKERS, PATIENCE, CHECKPOINT_DIR, CLASS_NAMES_FILE,
    RANDOM_SEED,
)
from preprocessing import get_train_transforms, get_eval_transforms


def compute_class_weights(dataset):
    """Compute inverse-frequency class weights for imbalanced data."""
    targets = [s[1] for s in dataset.samples]
    counter = Counter(targets)
    total = len(targets)
    num_classes = len(counter)

    weights = []
    for i in range(num_classes):
        count = counter.get(i, 1)
        w = total / (num_classes * count)
        weights.append(w)

    return torch.FloatTensor(weights)


def train():
    """Main training loop."""
    print("=" * 60)
    print("  SMARTCROP AI — MOBILEVIT TRAINING")
    print("=" * 60)

    # ─── Setup ────────────────────────────────────────────
    torch.manual_seed(RANDOM_SEED)
    np.random.seed(RANDOM_SEED)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"\n  Device: {device}")
    print(f"  Model:  {MODEL_NAME}")

    # ─── Datasets ─────────────────────────────────────────
    print("\n  Loading datasets...")
    train_dataset = ImageFolder(str(TRAIN_DIR), transform=get_train_transforms())
    val_dataset = ImageFolder(str(VAL_DIR), transform=get_eval_transforms())

    num_classes = len(train_dataset.classes)
    class_names = train_dataset.classes

    print(f"  Classes: {num_classes}")
    print(f"  Training images: {len(train_dataset)}")
    print(f"  Validation images: {len(val_dataset)}")

    # Print class distribution
    train_counter = Counter([s[1] for s in train_dataset.samples])
    print("\n  Class distribution (train):")
    for i, name in enumerate(class_names):
        print(f"    {name}: {train_counter.get(i, 0)}")

    # Save class names
    with open(CLASS_NAMES_FILE, "w") as f:
        json.dump(class_names, f, indent=2)
    print(f"\n  [OK] Class names saved to {CLASS_NAMES_FILE}")

    # ─── DataLoaders ──────────────────────────────────────
    train_loader = DataLoader(
        train_dataset,
        batch_size=BATCH_SIZE,
        shuffle=True,
        num_workers=NUM_WORKERS,
        pin_memory=False,  # CPU mode
    )
    val_loader = DataLoader(
        val_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False,
        num_workers=NUM_WORKERS,
        pin_memory=False,  # CPU mode
    )

    # ─── Model ────────────────────────────────────────────
    print(f"\n  Loading pretrained {MODEL_NAME}...")
    model = timm.create_model(
        MODEL_NAME,
        pretrained=True,
        num_classes=num_classes,
    )
    model = model.to(device)

    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"  Total parameters: {total_params:,}")
    print(f"  Trainable parameters: {trainable_params:,}")

    # ─── Loss & Optimizer ─────────────────────────────────
    class_weights = compute_class_weights(train_dataset).to(device)
    criterion = nn.CrossEntropyLoss(weight=class_weights)

    optimizer = optim.AdamW(
        model.parameters(),
        lr=LEARNING_RATE,
        weight_decay=WEIGHT_DECAY,
    )

    # Learning rate scheduler
    scheduler = optim.lr_scheduler.CosineAnnealingLR(
        optimizer, T_max=NUM_EPOCHS, eta_min=1e-6
    )

    # ─── Training Loop ────────────────────────────────────
    print(f"\n  Starting training for {NUM_EPOCHS} epochs...")
    print(f"  Early stopping patience: {PATIENCE}")
    print("-" * 60)

    best_val_acc = 0.0
    best_val_loss = float("inf")
    patience_counter = 0
    history = {"train_loss": [], "train_acc": [], "val_loss": [], "val_acc": [], "lr": []}

    CHECKPOINT_DIR.mkdir(parents=True, exist_ok=True)

    for epoch in range(NUM_EPOCHS):
        epoch_start = time.time()

        # ── Train ──
        model.train()
        running_loss = 0.0
        correct = 0
        total = 0

        for batch_idx, (inputs, labels) in enumerate(train_loader):
            inputs, labels = inputs.to(device), labels.to(device)

            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            running_loss += loss.item() * inputs.size(0)
            _, predicted = outputs.max(1)
            total += labels.size(0)
            correct += predicted.eq(labels).sum().item()

            # Progress
            if (batch_idx + 1) % 20 == 0 or (batch_idx + 1) == len(train_loader):
                print(f"\r  Epoch {epoch+1}/{NUM_EPOCHS} "
                      f"[{batch_idx+1}/{len(train_loader)}] "
                      f"Loss: {loss.item():.4f}  "
                      f"Acc: {100.*correct/total:.1f}%", end="")

        train_loss = running_loss / total
        train_acc = 100.0 * correct / total

        # ── Validate ──
        model.eval()
        val_loss = 0.0
        val_correct = 0
        val_total = 0

        with torch.no_grad():
            for inputs, labels in val_loader:
                inputs, labels = inputs.to(device), labels.to(device)
                outputs = model(inputs)
                loss = criterion(outputs, labels)

                val_loss += loss.item() * inputs.size(0)
                _, predicted = outputs.max(1)
                val_total += labels.size(0)
                val_correct += predicted.eq(labels).sum().item()

        val_loss = val_loss / val_total
        val_acc = 100.0 * val_correct / val_total

        # Step scheduler
        current_lr = optimizer.param_groups[0]["lr"]
        scheduler.step()

        epoch_time = time.time() - epoch_start

        # Log
        history["train_loss"].append(train_loss)
        history["train_acc"].append(train_acc)
        history["val_loss"].append(val_loss)
        history["val_acc"].append(val_acc)
        history["lr"].append(current_lr)

        print(f"\r  Epoch {epoch+1}/{NUM_EPOCHS}  "
              f"Train Loss: {train_loss:.4f}  Train Acc: {train_acc:.1f}%  "
              f"Val Loss: {val_loss:.4f}  Val Acc: {val_acc:.1f}%  "
              f"LR: {current_lr:.6f}  Time: {epoch_time:.1f}s")

        # ── Checkpoint ──
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            best_val_loss = val_loss
            patience_counter = 0

            checkpoint = {
                "epoch": epoch + 1,
                "model_state_dict": model.state_dict(),
                "optimizer_state_dict": optimizer.state_dict(),
                "val_acc": val_acc,
                "val_loss": val_loss,
                "class_names": class_names,
                "num_classes": num_classes,
                "model_name": MODEL_NAME,
                "image_size": IMAGE_SIZE,
            }
            ckpt_path = CHECKPOINT_DIR / "best_model.pth"
            torch.save(checkpoint, ckpt_path)
            print(f"  [BEST] Best model saved (Val Acc: {val_acc:.1f}%)")
        else:
            patience_counter += 1
            if patience_counter >= PATIENCE:
                print(f"\n  [STOP] Early stopping at epoch {epoch+1} "
                      f"(no improvement for {PATIENCE} epochs)")
                break

    # ─── Save History ─────────────────────────────────────
    history_path = CHECKPOINT_DIR / "training_history.json"
    with open(history_path, "w") as f:
        json.dump(history, f, indent=2)

    print("\n" + "=" * 60)
    print("  TRAINING COMPLETE")
    print("=" * 60)
    print(f"\n  Best Validation Accuracy: {best_val_acc:.1f}%")
    print(f"  Best Validation Loss:    {best_val_loss:.4f}")
    print(f"  Checkpoint: {CHECKPOINT_DIR / 'best_model.pth'}")
    print(f"  History:    {history_path}")

    return history


if __name__ == "__main__":
    train()
