"""
SmartCrop AI — Prediction Schemas
====================================
Pydantic models for the prediction API.
"""

from pydantic import BaseModel, Field
from typing import Optional


class PredictionItem(BaseModel):
    """A single prediction entry."""
    class_name: str = Field(..., description="Full class name e.g. Banana___Sigatoka")
    crop: str = Field(..., description="Crop name e.g. Banana")
    disease: str = Field(..., description="Disease name e.g. Sigatoka")
    confidence: float = Field(..., ge=0, le=1, description="Confidence 0-1")


class PredictionResponse(BaseModel):
    """Response from the /predict endpoint."""
    success: bool = True
    crop: str = Field(..., description="Detected crop")
    predicted_disease: str = Field(..., description="Predicted disease")
    confidence: float = Field(..., ge=0, le=1, description="Confidence 0-1")
    confidence_percent: float = Field(..., description="Confidence as percentage")
    confidence_label: str = Field(..., description="High / Medium / Low / Very Low")
    message: str = Field(..., description="Farmer-friendly message")
    top_predictions: list[PredictionItem] = Field(
        default_factory=list, description="Top-K predictions"
    )
    requested_crop: Optional[str] = Field(
        None, description="Crop the farmer selected (if any)"
    )


class PredictionErrorResponse(BaseModel):
    """Error response from the /predict endpoint."""
    success: bool = False
    error: str = Field(..., description="Farmer-friendly error message")
