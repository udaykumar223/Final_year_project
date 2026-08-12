"""
SmartCrop AI — Prediction Route
==================================
POST /predict — Runs MobileViT inference on a crop image,
computes Plant Name, Disease Name, and Severity Assessment.
"""

from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional
from datetime import datetime, timezone

from app.schemas.prediction import (
    PredictionResponse,
    PredictionItem,
    SeverityInfo,
    PredictionErrorResponse,
)
from app.services.model_service import get_model_service
from app.services.image_service import ImageService

router = APIRouter()


def calculate_severity(crop: str, disease: str, confidence: float) -> SeverityInfo:
    """Calculate realistic disease severity level, score, and advisory."""
    disease_lower = disease.lower()

    if "healthy" in disease_lower:
        return SeverityInfo(
            level="Healthy",
            score=0.0,
            color="#10B981",
            advisory="The plant is in excellent health! Continue standard watering and crop management.",
        )

    # High severity diseases
    severe_keywords = ["panama", "moko", "bract mosaic", "mosaic", "yellow sigatoka", "pestalotiopsis"]
    if any(k in disease_lower for k in severe_keywords):
        score = round(75.0 + (confidence * 15.0), 1)
        return SeverityInfo(
            level="Severe",
            score=min(95.0, score),
            color="#EF4444",
            advisory="High severity infection detected! Prune affected parts immediately and avoid overhead watering to prevent spore dispersal.",
        )

    # Moderate severity diseases
    moderate_keywords = ["late leaf spot", "downy mildew", "cordana", "sigatoka", "black leaf spot", "rust"]
    if any(k in disease_lower for k in moderate_keywords):
        score = round(45.0 + (confidence * 20.0), 1)
        return SeverityInfo(
            level="Moderate",
            score=min(70.0, score),
            color="#F97316",
            advisory="Moderate infection active on foliage. Apply recommended copper-based fungicide and inspect adjacent plants.",
        )

    # Mild severity diseases
    score = round(20.0 + (confidence * 15.0), 1)
    return SeverityInfo(
        level="Mild",
        score=min(40.0, score),
        color="#F59E0B",
        advisory="Early stage symptoms detected. Early intervention with organic neem oil or balanced micronutrients will restore vigor.",
    )


@router.post(
    "/predict",
    response_model=PredictionResponse,
    responses={
        400: {"model": PredictionErrorResponse},
        503: {"model": PredictionErrorResponse},
    },
)
async def predict(
    image: UploadFile = File(...),
    crop: Optional[str] = Form(None),
):
    """
    Predict crop disease from an uploaded leaf image.
    Returns Plant Name, Disease Diagnosis, AI Confidence, and Severity Assessment.
    """
    try:
        # Get model service
        model_service = get_model_service()

        if not model_service.is_loaded:
            raise HTTPException(
                status_code=503,
                detail="Crop analysis is temporarily unavailable. Please try again later.",
            )

        # Read and convert image
        image_bytes = await image.read()

        if not ImageService.validate_file_size(image_bytes, max_mb=10.0):
            raise HTTPException(
                status_code=400,
                detail="The photo is too large. Please take a smaller photo.",
            )

        pil_image = ImageService.bytes_to_pil(image_bytes)

        # Run prediction
        result = model_service.predict(pil_image, crop_name=crop)

        # Calculate Severity
        detected_crop = result["crop"]
        detected_disease = result["predicted_disease"]
        confidence_val = result["confidence"]
        severity = calculate_severity(detected_crop, detected_disease, confidence_val)

        # Save to MongoDB (non-blocking, best-effort)
        try:
            await save_prediction(result, crop, severity)
        except Exception as e:
            print(f"MongoDB save error (non-critical): {e}")

        # Build response
        top_predictions = [
            PredictionItem(
                class_name=p["class_name"],
                crop=p["crop"],
                disease=p["disease"],
                confidence=p["confidence"],
            )
            for p in result["top_predictions"]
        ]

        plant_name = f"{detected_crop} Plant" if detected_crop != "Unknown" else "Crop Plant"

        return PredictionResponse(
            success=True,
            plant_name=plant_name,
            crop=detected_crop,
            disease_name=detected_disease,
            predicted_disease=detected_disease,
            confidence=result["confidence"],
            confidence_percent=result["confidence_percent"],
            confidence_label=result["confidence_label"],
            severity=severity,
            message=result["message"],
            top_predictions=top_predictions,
            requested_crop=result.get("requested_crop"),
        )

    except HTTPException:
        raise
    except Exception as e:
        print(f"Prediction error: {e}")
        raise HTTPException(
            status_code=500,
            detail="We couldn't analyze your crop. Please try again.",
        )


async def save_prediction(result: dict, crop_name: Optional[str] = None, severity: Optional[SeverityInfo] = None):
    """Save prediction to MongoDB (best-effort)."""
    try:
        from app.main import get_db
        db = get_db()
        if db is not None:
            doc = {
                "crop": result["crop"],
                "predicted_disease": result["predicted_disease"],
                "confidence": result["confidence"],
                "confidence_label": result["confidence_label"],
                "severity_level": severity.level if severity else "Unknown",
                "severity_score": severity.score if severity else 0.0,
                "requested_crop": crop_name,
                "created_at": datetime.now(timezone.utc),
            }
            await db.predictions.insert_one(doc)
    except Exception:
        pass  # Non-critical — don't fail prediction
