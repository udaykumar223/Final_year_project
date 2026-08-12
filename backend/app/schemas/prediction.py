"""
SmartCrop AI — Prediction Schemas
====================================
Pydantic models for the prediction API including
Plant Name, Disease Name, and Severity Assessment.
"""

from pydantic import BaseModel, Field
from typing import Optional, List


class PredictionItem(BaseModel):
    """A single candidate prediction entry."""
    class_name: str = Field(..., description="Full class name e.g. Banana___Sigatoka")
    crop: str = Field(..., description="Crop name e.g. Banana")
    disease: str = Field(..., description="Disease name e.g. Sigatoka")
    confidence: float = Field(..., ge=0, le=1, description="Confidence 0-1")


class SeverityInfo(BaseModel):
    """Disease severity estimation metrics."""
    level: str = Field(..., description="Healthy / Mild / Moderate / Severe")
    score: float = Field(..., ge=0, le=100, description="Severity percentage (0-100%)")
    color: str = Field(..., description="Color indicator e.g. #22C55E, #F59E0B, #EF4444")
    advisory: str = Field(..., description="Actionable severity-specific recommendation")


class PredictionResponse(BaseModel):
    """Response from the /predict endpoint with full diagnostic & severity metrics."""
    success: bool = True
    plant_name: str = Field(..., description="Plant / Crop Name")
    crop: str = Field(..., description="Detected crop")
    disease_name: str = Field(..., description="Specific Disease Name")
    predicted_disease: str = Field(..., description="Predicted disease")
    confidence: float = Field(..., ge=0, le=1, description="Confidence 0-1")
    confidence_percent: float = Field(..., description="Confidence as percentage")
    confidence_label: str = Field(..., description="High / Medium / Low / Very Low")
    severity: SeverityInfo = Field(..., description="Severity evaluation")
    message: str = Field(..., description="Farmer-friendly summary message")
    top_predictions: List[PredictionItem] = Field(
        default_factory=list, description="Top-K alternative predictions"
    )
    requested_crop: Optional[str] = Field(
        None, description="Crop the farmer selected (if any)"
    )


class PredictionErrorResponse(BaseModel):
    """Error response from the /predict endpoint."""
    success: bool = False
    detail: str = Field(..., description="Farmer-friendly error message")
