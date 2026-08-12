"""
SmartCrop AI — Model Service
===============================
High-level service layer wrapping the predictor.
Used by the FastAPI backend. Provides extension points
for future services (leaf detection, background removal).
"""

from pathlib import Path
from PIL import Image
from inference import CropDiseasePredictor, get_predictor


class ModelService:
    """
    Orchestrates the AI pipeline:
    Image → Preprocessing → MobileViT → Prediction

    Future extension points:
    - LeafDetectionService (YOLOv8-Nano)
    - BackgroundRemovalService (U²-Net)
    - SeverityService
    - GradeService
    """

    def __init__(self):
        self.predictor = get_predictor()
        # Future services (Phase 2+)
        self.leaf_detector = None       # YOLOv8-Nano placeholder
        self.bg_remover = None          # U²-Net placeholder
        self.severity_model = None      # Severity model placeholder

    def predict(self, image: Image.Image, crop_name: str = None) -> dict:
        """
        Run the full prediction pipeline.

        Args:
            image: PIL Image
            crop_name: Optional crop name to filter predictions

        Returns:
            Prediction result dict
        """
        # Phase 1: Direct prediction
        result = self.predictor.predict(image)

        # If crop_name provided, verify the prediction matches
        if crop_name:
            result["requested_crop"] = crop_name
            if result["crop"].lower() != crop_name.lower():
                # The model might predict a different crop
                # Flag this for the frontend
                result["crop_mismatch"] = True
            else:
                result["crop_mismatch"] = False

        # Add farmer-friendly message
        result["message"] = self.predictor.get_confidence_message(
            result["confidence_label"]
        )

        return result

    def is_ready(self) -> bool:
        """Check if the model is loaded and ready."""
        return self.predictor is not None and self.predictor.model is not None


# Module-level singleton
_service = None


def get_model_service() -> ModelService:
    """Get or create the singleton model service."""
    global _service
    if _service is None:
        _service = ModelService()
    return _service
