"""
SmartCrop AI — Inference
==========================
Single-image inference using the trained MobileViT model.
Returns prediction, confidence, and top-k results.
"""

import json
from pathlib import Path

import torch
import numpy as np
from PIL import Image
import timm

from config import (
    CHECKPOINT_DIR, MODEL_NAME, IMAGE_SIZE,
    CONFIDENCE_HIGH, CONFIDENCE_MEDIUM, CONFIDENCE_LOW,
    TOP_K, CLASS_NAMES_FILE,
)
from preprocessing import get_inference_transforms


class CropDiseasePredictor:
    """
    Loads a trained MobileViT checkpoint and predicts
    crop disease from a single image.
    """

    def __init__(self, checkpoint_path=None, device=None):
        self.device = device or torch.device(
            "cuda" if torch.cuda.is_available() else "cpu"
        )

        if checkpoint_path is None:
            checkpoint_path = CHECKPOINT_DIR / "best_model.pth"

        self.checkpoint_path = Path(checkpoint_path)
        self.model = None
        self.class_names = None
        self.num_classes = None
        self.transforms = get_inference_transforms()

        self._load_model()

    def _load_model(self):
        """Load the trained model from checkpoint."""
        if not self.checkpoint_path.exists():
            raise FileNotFoundError(
                f"No model checkpoint found at {self.checkpoint_path}. "
                "Please train the model first: python train.py"
            )

        checkpoint = torch.load(
            self.checkpoint_path,
            map_location=self.device,
            weights_only=False,
        )

        self.class_names = checkpoint["class_names"]
        self.num_classes = checkpoint["num_classes"]
        model_name = checkpoint.get("model_name", MODEL_NAME)

        self.model = timm.create_model(
            model_name, pretrained=False, num_classes=self.num_classes
        )
        self.model.load_state_dict(checkpoint["model_state_dict"])
        self.model = self.model.to(self.device)
        self.model.eval()

        print(f"  [OK] Model loaded: {model_name}, {self.num_classes} classes")

    def predict(self, image):
        """
        Predict disease from a PIL Image or file path.

        Args:
            image: PIL.Image.Image or str (file path)

        Returns:
            dict with prediction results
        """
        # Load image if path
        if isinstance(image, (str, Path)):
            image = Image.open(image).convert("RGB")
        elif not isinstance(image, Image.Image):
            raise ValueError("Input must be a PIL Image or file path")

        image = image.convert("RGB")

        # Preprocess
        input_tensor = self.transforms(image).unsqueeze(0).to(self.device)

        # Inference
        with torch.no_grad():
            outputs = self.model(input_tensor)
            probabilities = torch.softmax(outputs, dim=1)[0]

        # Get top-k predictions
        top_probs, top_indices = torch.topk(probabilities, min(TOP_K, self.num_classes))

        top_predictions = []
        for prob, idx in zip(top_probs.cpu().numpy(), top_indices.cpu().numpy()):
            class_name = self.class_names[idx]
            # Parse crop and disease from class name
            parts = class_name.split("___")
            crop = parts[0] if len(parts) > 1 else "Unknown"
            disease = parts[1].replace("_", " ") if len(parts) > 1 else class_name

            top_predictions.append({
                "class_name": class_name,
                "crop": crop,
                "disease": disease,
                "confidence": float(prob),
            })

        # Primary prediction
        primary = top_predictions[0]
        confidence = primary["confidence"]

        # Confidence level label
        if confidence >= CONFIDENCE_HIGH:
            confidence_label = "High"
        elif confidence >= CONFIDENCE_MEDIUM:
            confidence_label = "Medium"
        elif confidence >= CONFIDENCE_LOW:
            confidence_label = "Low"
        else:
            confidence_label = "Very Low"

        return {
            "crop": primary["crop"],
            "predicted_disease": primary["disease"],
            "confidence": confidence,
            "confidence_percent": round(confidence * 100, 1),
            "confidence_label": confidence_label,
            "top_predictions": top_predictions,
        }

    @staticmethod
    def get_confidence_message(confidence_label):
        """Return farmer-friendly confidence message."""
        messages = {
            "High": "The AI is confident about this result.",
            "Medium": "The AI has moderate confidence. Consider taking another photo for confirmation.",
            "Low": "The AI has low confidence. Please try another clear photo.",
            "Very Low": "The AI could not confidently identify the condition. Please try another clear photo.",
        }
        return messages.get(confidence_label, "")


# Module-level singleton for the backend
_predictor = None


def get_predictor():
    """Get or create the singleton predictor instance."""
    global _predictor
    if _predictor is None:
        _predictor = CropDiseasePredictor()
    return _predictor


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python inference.py <image_path>")
        sys.exit(1)

    image_path = sys.argv[1]
    predictor = CropDiseasePredictor()
    result = predictor.predict(image_path)

    print(f"\n  Crop:       {result['crop']}")
    print(f"  Disease:    {result['predicted_disease']}")
    print(f"  Confidence: {result['confidence_percent']}% ({result['confidence_label']})")
    print(f"\n  Top predictions:")
    for p in result["top_predictions"]:
        print(f"    {p['crop']} → {p['disease']}: {p['confidence']*100:.1f}%")
