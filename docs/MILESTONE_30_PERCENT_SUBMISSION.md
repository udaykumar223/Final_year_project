# SMARTCROP AI — 30% Milestone Submission & Evaluation Report

**Project Title:** SmartCrop AI — AI-Powered Crop Disease Diagnosis & Farmer Advisory System  
**Project Milestone:** 30% Implementation Review (Initial Setup & Functional Core Modules)  
**Version:** `0.3.0`  
**Git Tag:** `v0.3.0-milestone-30`  
**Target Crops (Phase 1):** Banana, Groundnut, Radish (20 Disease Classes, 15,011 Images)  

---

## 1. Executive Summary & Scope Breakdown (30+% Milestone)

The SmartCrop AI project is architected as an end-to-end intelligent agricultural mobile system. This 30% milestone review delivers the complete **vertical slice** of the core application:

```
[Farmer]
   ↓ (Mobile UI)
[Crop Selection & Camera / Gallery Capture]
   ↓ (Multipart HTTP Upload)
[OpenCV Image Verification & Quality Filtering]
   ↓ (Preprocessed 256x256 Tensor)
[MobileViT Deep Learning Inference Engine]
   ↓ (Softmax Probabilities & Top-K Extraction)
[FastAPI REST API Service]
   ↓ (JSON Response & MongoDB Storage)
[Interactive Diagnosis Screen with Farmer-Friendly Confidence Badge]
```

### Milestone Progress vs. Final Project Roadmap

| Module / Layer | 30% Milestone Deliverable | Status | Target Full Project (100%) |
|---|---|---|---|
| **1. Dataset Pipeline** | 15,011 images (3 crops, 20 classes), 70/15/15 stratified split | **100% Complete** | Expand to 5+ crops (add Pepper & Potato) |
| **2. AI Computer Vision** | MobileViT-XXS classification engine (88.27% test accuracy) | **100% Complete** | Fine-tune with GPU, multi-scale augmentations |
| **3. Image Quality Checker** | OpenCV Laplacian variance blur + brightness + resolution checks | **100% Complete** | Background segmentation & leaf contouring |
| **4. REST API Backend** | FastAPI server with `/health`, `/verify-image`, `/predict` | **100% Complete** | Add User Auth JWT, MongoDB Atlas clustering |
| **5. Mobile App Frontend** | Flutter app with 9 functional screens & M3 design system | **100% Complete** | Add offline mode, multilingual voice TTS |
| **6. Future Scope** | Phase 2 (Severity), Phase 3 (History), Phase 4 (Weather) | *Scheduled (70%)* | Treatment recommendations & weather risk |

---

## 2. Implemented Functional Modules (Implementation Evidence)

### Module 1: Computer Vision & AI Inference Engine (`ai_model/`)
- **Model Choice:** MobileViT-XXS (Vision Transformer for Mobile, 957,444 parameters). Combines the spatial inductive bias of convolutions with the global context modeling of self-attention mechanisms, while keeping model size under 12 MB for mobile edge deployment.
- **Dataset Stratification:** 10,497 training, 2,254 validation, and 2,260 held-out test images across 20 disease classes.
- **Trained Performance:**
  - **Overall Test Accuracy:** **88.27%**
  - **Weighted Precision:** **90.31%**
  - **Weighted Recall:** **88.27%**
  - **Weighted F1-Score:** **0.8838**
- **Evidence Files:**
  - `ai_model/checkpoints/best_model.pth` (Model weights)
  - `docs/confusion_matrix.png` (Confusion matrix across all 20 classes)
  - `docs/training_curves.png` (Loss & accuracy progression curves)
  - `docs/training_report.md` (Per-class precision, recall, and support report)

---

### Module 2: Image Quality Verification Pipeline (`backend/app/services/verification_service.py`)
Ensures that noisy, blurry, or low-resolution field photos taken by farmers are caught early before passing into neural network inference:
- **Resolution Filter:** Minimum dimension $\ge 224 \times 224$ px.
- **Blur Detection (Laplacian Variance):** Computes $Var(\nabla^2 I_{gray})$. If variance $< 100.0$, the image is flagged as blurry with actionable advice: *"The photo is too blurry. Please hold your phone steady and try again."*
- **Illumination Filter:** Validates mean grayscale luminance $\mu \in [40, 240]$ to prevent over-exposed or dark captures.
- **API Endpoint:** `POST /verify-image`

---

### Module 3: High-Performance Backend API (`backend/app/`)
Built with **FastAPI** (Python 3.11) with non-blocking async architecture:
- `GET /health` — Service health and model readiness probe.
- `POST /verify-image` — Multipart image upload for OpenCV validation.
- `POST /predict` — Disease diagnosis with confidence calculation, top-3 candidates, and farmer-friendly messaging.
- **MongoDB Persistence:** Asynchronous storage of predictions via `motor` with graceful fallback if the database server is offline.
- **Interactive Documentation:** Auto-generated OpenAPI / Swagger UI at `/docs`.

---

### Module 4: Mobile Application Frontend (`mobile/lib/`)
Built with **Flutter** (Material 3) adhering to the **"Nature + AI + Simplicity"** design system:
1. `screens/splash/splash_screen.dart` — Brand launch with organic pulsing leaf animation.
2. `screens/login/login_screen.dart` — Simple mobile/email login with quick skip.
3. `screens/home/home_screen.dart` — Quick stats, selected crop overview, and hero **SCAN NOW** button.
4. `screens/crop_selection/crop_selection_screen.dart` — Banana, Groundnut, Radish selection cards.
5. `screens/scan/scan_screen.dart` — Camera & photo gallery picker with live photography guidelines.
6. `screens/image_preview/image_preview_screen.dart` — Image inspection, retake, and confirmation.
7. `screens/verification/verification_screen.dart` — OpenCV quality checklist with visual badges.
8. `screens/analysis/analysis_screen.dart` — Multi-step animated AI pipeline indicator.
9. `screens/result/result_screen.dart` — Final diagnosis display with color-coded confidence badge (Green $\ge 75\%$, Amber $\ge 50\%$, Red $< 50\%$) and alternative possibilities breakdown.
- **Static Code Analysis:** `dart analyze .` passes with **0 issues / 0 warnings**.

---

## 3. Real Sample Inference Verification

Live API testing with real held-out test images yielded the following verified outputs:

### Sample 1: Banana Leaf
- **Image:** `data/test/Banana___Cordana/cordana-101-_jpeg.rf.b25ec6844a9177591f5246b22015f66e.jpg`
- **Output:** `Banana > Cordana`
- **Confidence:** **98.6% (High)**
- **Message:** *"The AI is confident about this result."*

### Sample 2: Radish Leaf
- **Image:** `data/test/Radish___Downy_Mildew/Downey-Mildew-101-_jpg.rf.dec5d01497c540a8c8fc4668422a2255.jpg`
- **Output:** `Radish > Downy Mildew`
- **Confidence:** **96.2% (High)**
- **Message:** *"The AI is confident about this result."*

### Sample 3: Groundnut Leaf
- **Image:** `data/test/Groundnut___Nutrition_Deficiency/Nutirtion-Deficiency-1007-_jpg.rf.c81fb3bbca07842bcbb3d1073c1d06ac.jpg`
- **Output:** `Groundnut > Nutrition Deficiency`
- **Confidence:** **92.9% (High)**
- **Message:** *"The AI is confident about this result."*

---

## 4. Evaluator Quick-Start Guide (Step-by-Step Reproduction)

### Step 1: Environment Setup
Ensure Python 3.11+ and Flutter 3.38+ are installed.
```bash
# Clone or navigate to the repository
cd smart_crop_AI
```

### Step 2: Test AI Model Inference
```bash
# Evaluate full test set (2,260 images):
python3.11 ai_model/evaluate.py

# Predict a single image:
python3.11 ai_model/inference.py "data/test/Radish___Downy_Mildew/Downey-Mildew-101-_jpg.rf.dec5d01497c540a8c8fc4668422a2255.jpg"
```

### Step 3: Run the FastAPI Backend
```bash
cd backend
python3.11 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
*Open your browser at `http://127.0.0.1:8000/docs` to test endpoints interactively.*

### Step 4: Run the Flutter Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

---

## 5. Summary of Deliverables Submitted

1. **Git Repository:** Fully tracked with commit history and tag `v0.3.0-milestone-30`.
2. **AI Artifacts:** Saved checkpoint (`best_model.pth`), evaluation metrics (`evaluation_results.json`), training history (`training_history.json`).
3. **Visual Plots:** `docs/confusion_matrix.png`, `docs/training_curves.png`, `docs/class_distribution.png`.
4. **API Backend:** Functional FastAPI server with Pydantic validation schemas, OpenCV quality algorithms, and MongoDB models.
5. **Mobile Frontend:** 9 Flutter screens, complete navigation architecture, and custom design system.
