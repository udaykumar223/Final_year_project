# SmartCrop AI — Dataset Report

**Generated**: Auto-generated during dataset preparation

**Source**: `C:\Users\udayd\Downloads\Crop___Disease`

**Selected crops**: Banana, Groundnut, Radish


## Full Dataset Overview

| Crop | Classes | Total Images |
|---|---|---|
| Banana [SELECTED] | 9 | 6325 |
| Cauliflower | 4 | 490 |
| Chilli | 6 | 798 |
| Groundnut [SELECTED] | 6 | 6523 |
| Radish [SELECTED] | 5 | 2163 |
| **Total** | **30** | **16299** |

## Selected Crops — Detailed Class Breakdown

| Crop | Class | Total | Train | Validation | Test |
|---|---|---|---|---|---|
| Banana | Banana > Bract Mosaic Virus | 295 | 206 | 44 | 45 |
| Banana | Banana > Cordana | 406 | 284 | 61 | 61 |
| Banana | Banana > Healthy | 476 | 333 | 71 | 72 |
| Banana | Banana > Insect Pest | 504 | 352 | 76 | 76 |
| Banana | Banana > Moko | 334 | 233 | 50 | 51 |
| Banana | Banana > Panama | 714 | 499 | 107 | 108 |
| Banana | Banana > Pestalotiopsis | 412 | 288 | 62 | 62 |
| Banana | Banana > Sigatoka | 1059 | 741 | 159 | 159 |
| Banana | Banana > Yellow Sigatoka | 2125 | 1487 | 319 | 319 |
| Groundnut | Groundnut > Early Leaf Spot | 868 | 607 | 130 | 131 |
| Groundnut | Groundnut > Early Rust | 1177 | 823 | 177 | 177 |
| Groundnut | Groundnut > Healthy | 327 | 228 | 49 | 50 |
| Groundnut | Groundnut > Late Leaf Spot | 1573 | 1101 | 236 | 236 |
| Groundnut | Groundnut > Nutrition Deficiency | 1199 | 839 | 180 | 180 |
| Groundnut | Groundnut > Rust | 1379 | 965 | 207 | 207 |
| Radish | Radish > Black Leaf Spot | 418 | 292 | 63 | 63 |
| Radish | Radish > Downy Mildew | 465 | 325 | 70 | 70 |
| Radish | Radish > Flea Beetle | 358 | 250 | 54 | 54 |
| Radish | Radish > Healthy | 485 | 339 | 73 | 73 |
| Radish | Radish > Mosaic | 437 | 305 | 66 | 66 |
| **Total** | **20 classes** | **15011** | **10497** | **2254** | **2260** |

## Data Quality

- Corrupted images: **0**
- Invalid files: **0**
- Image format: **JPEG, 640x640, RGB** (uniform across dataset)
- Split ratios: **70% / 15% / 15%**
- Data leakage check: **PASSED** (no overlap between splits)

## Class Imbalance Analysis

**Banana**: Min = 295 (Banana___Bract_Mosaic_Virus), Max = 2125 (Banana___Yellow_Sigatoka), Imbalance ratio = 7.2x
**Groundnut**: Min = 327 (Groundnut___Healthy), Max = 1573 (Groundnut___Late_Leaf_Spot), Imbalance ratio = 4.8x
**Radish**: Min = 358 (Radish___Flea_Beetle), Max = 485 (Radish___Healthy), Imbalance ratio = 1.4x

> Training augmentation is applied to help mitigate class imbalance.