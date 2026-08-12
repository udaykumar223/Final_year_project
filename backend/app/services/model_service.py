"""
SmartCrop AI — Model Service (Backend)
========================================
Wraps the AI model inference for the FastAPI backend.
Loads the trained MobileViT model and provides prediction.
"""

import sys
from pathlib import Path
from PIL import Image

# Add ai_model to path so we can import from it
AI_MODEL_DIR = Path(__file__).parent.parent.parent.parent / "ai_model"
sys.path.insert(0, str(AI_MODEL_DIR))

from inference import CropDiseasePredictor


class ModelService:
    """Backend model service — loads model once, serves predictions."""

    def __init__(self):
        self.predictor = None
        self.is_loaded = False

    def load_model(self):
        """Load the MobileViT model."""
        try:
            self.predictor = CropDiseasePredictor()
            self.is_loaded = True
            print("  [OK] Model loaded successfully")
        except FileNotFoundError as e:
            print(f"  [!] Model not loaded: {e}")
            self.is_loaded = False
        except Exception as e:
            print(f"  [X] Error loading model: {e}")
            self.is_loaded = False

    def predict(self, image: Image.Image, crop_name: str = None) -> dict:
        """
        Run prediction on an image.

        Args:
            image: PIL Image
            crop_name: Optional crop filter

        Returns:
            Prediction result dict
        """
        if not self.is_loaded:
            raise RuntimeError("Model is not loaded")

        result = self.predictor.predict(image)

        if crop_name:
            result["requested_crop"] = crop_name

        result["message"] = self.predictor.get_confidence_message(
            result["confidence_label"]
        )

        return result

    def get_status(self) -> dict:
        """Return model status."""
        return {
            "loaded": self.is_loaded,
            "num_classes": self.predictor.num_classes if self.is_loaded else 0,
            "class_names": self.predictor.class_names if self.is_loaded else [],
        }


# Singleton
_model_service = None


def get_model_service() -> ModelService:
    """Get or create the singleton model service."""
    global _model_service
    if _model_service is None:
        _model_service = ModelService()
        _model_service.load_model()
    return _model_service
