# SmartCrop AI — Training & Evaluation Report

## Model Configuration

| Setting | Value |
|---|---|
| Model | mobilevit_xxs |
| Input Size | 256×256 |
| Classes | 20 |
| Best Epoch | 3 |
| Test Images | 2260 |

## Overall Results

| Metric | Value |
|---|---|
| **Test Accuracy** | **88.27%** |

## Per-Class Results

| Class | Precision | Recall | F1-Score | Support |
|---|---|---|---|---|
| Banana > Bract Mosaic Virus | 0.9565 | 0.9778 | 0.9670 | 45 |
| Banana > Cordana | 1.0000 | 1.0000 | 1.0000 | 61 |
| Banana > Healthy | 0.9459 | 0.9722 | 0.9589 | 72 |
| Banana > Insect Pest | 0.9259 | 0.9868 | 0.9554 | 76 |
| Banana > Moko | 1.0000 | 0.9804 | 0.9901 | 51 |
| Banana > Panama | 0.8167 | 0.9074 | 0.8596 | 108 |
| Banana > Pestalotiopsis | 0.7381 | 1.0000 | 0.8493 | 62 |
| Banana > Sigatoka | 0.9375 | 0.4717 | 0.6276 | 159 |
| Banana > Yellow Sigatoka | 0.9852 | 0.8370 | 0.9051 | 319 |
| Groundnut > Early Leaf Spot | 0.4528 | 0.7328 | 0.5598 | 131 |
| Groundnut > Early Rust | 0.9219 | 1.0000 | 0.9593 | 177 |
| Groundnut > Healthy | 0.9615 | 1.0000 | 0.9804 | 50 |
| Groundnut > Late Leaf Spot | 0.7812 | 0.7415 | 0.7609 | 236 |
| Groundnut > Nutrition Deficiency | 0.9944 | 0.9778 | 0.9860 | 180 |
| Groundnut > Rust | 0.9190 | 0.9324 | 0.9257 | 207 |
| Radish > Black Leaf Spot | 1.0000 | 1.0000 | 1.0000 | 63 |
| Radish > Downy Mildew | 1.0000 | 1.0000 | 1.0000 | 70 |
| Radish > Flea Beetle | 1.0000 | 1.0000 | 1.0000 | 54 |
| Radish > Healthy | 1.0000 | 1.0000 | 1.0000 | 73 |
| Radish > Mosaic | 1.0000 | 1.0000 | 1.0000 | 66 |

> All metrics are computed from actual model predictions on the held-out test set.
> No metrics are fabricated.