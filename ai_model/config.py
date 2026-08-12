"""
SmartCrop AI — Model Configuration
===================================
Central configuration for dataset paths, model hyperparameters,
and class mappings. Add new crops by updating SELECTED_CROPS.
"""

import os
from pathlib import Path

# ─── Paths ───────────────────────────────────────────────
PROJECT_ROOT = Path(__file__).parent.parent
DATASET_ROOT = Path(r"C:\Users\udayd\Downloads\Crop___Disease")
DATA_DIR = PROJECT_ROOT / "data"
TRAIN_DIR = DATA_DIR / "train"
VAL_DIR = DATA_DIR / "validation"
TEST_DIR = DATA_DIR / "test"
CHECKPOINT_DIR = Path(__file__).parent / "checkpoints"
CLASS_NAMES_FILE = Path(__file__).parent / "class_names.json"

# ─── Dataset ─────────────────────────────────────────────
# Phase 1 crops — best data quality and balance
SELECTED_CROPS = ["Banana", "Groundnut", "Radish"]

# Train / Validation / Test split ratios
TRAIN_RATIO = 0.70
VAL_RATIO = 0.15
TEST_RATIO = 0.15

# Random seed for reproducibility
RANDOM_SEED = 42

# ─── Model ───────────────────────────────────────────────
# MobileViT variant from timm
# Using mobilevit_xxs for faster CPU training
MODEL_NAME = "mobilevit_xxs"

# Input image size expected by MobileViT
IMAGE_SIZE = 256

# ImageNet normalization (used by MobileViT pretrained weights)
IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD = [0.229, 0.224, 0.225]

# ─── Training Hyperparameters ────────────────────────────
BATCH_SIZE = 32
NUM_EPOCHS = 3  # Reduced for CPU — increase to 20+ with GPU
LEARNING_RATE = 1e-4
WEIGHT_DECAY = 1e-4
NUM_WORKERS = 0  # Windows compatibility — set to 0

# Early stopping
PATIENCE = 2  # Reduced for CPU quick baseline

# ─── Augmentation ────────────────────────────────────────
# Applied ONLY to training data
AUGMENTATION = {
    "horizontal_flip": True,
    "vertical_flip": False,
    "rotation_degrees": 15,
    "color_jitter": {
        "brightness": 0.2,
        "contrast": 0.2,
        "saturation": 0.2,
        "hue": 0.05,
    },
    "random_resized_crop_scale": (0.8, 1.0),
}

# ─── Inference ───────────────────────────────────────────
# Confidence thresholds for farmer-friendly labels
CONFIDENCE_HIGH = 0.75
CONFIDENCE_MEDIUM = 0.50
CONFIDENCE_LOW = 0.30

# Top-k predictions to return
TOP_K = 3
