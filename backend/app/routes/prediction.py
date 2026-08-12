"""
SmartCrop AI — Prediction Route
==================================
POST /predict — Runs MobileViT inference on a crop image.
"""

from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional
from datetime import datetime, timezone

from app.schemas.prediction import (
    PredictionResponse,
    PredictionItem,
    PredictionErrorResponse,
)
from app.services.model_service import get_model_service
from app.services.image_service import ImageService

router = APIRouter()


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
    Predict crop disease from an uploaded image.

    Returns the predicted disease, confidence score,
    and top-k predictions.
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

        # Save to MongoDB (non-blocking, best-effort)
        try:
            await save_prediction(result, crop)
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

        return PredictionResponse(
            success=True,
            crop=result["crop"],
            predicted_disease=result["predicted_disease"],
            confidence=result["confidence"],
            confidence_percent=result["confidence_percent"],
            confidence_label=result["confidence_label"],
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


async def save_prediction(result: dict, crop_name: str = None):
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
                "requested_crop": crop_name,
                "created_at": datetime.now(timezone.utc),
            }
            await db.predictions.insert_one(doc)
    except Exception:
        pass  # Non-critical — don't fail prediction
