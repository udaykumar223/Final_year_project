"""
SmartCrop AI — Image Verification Service
===========================================
Performs real image-quality checks using OpenCV:
- Resolution check
- Blur detection (Laplacian variance)
- Brightness check
- Image validity check

Returns structured results with farmer-friendly messages.
"""

import cv2
import numpy as np
from PIL import Image
import io


class ImageVerificationService:
    """
    Verifies that an uploaded image meets quality requirements
    for disease classification.
    """

    def __init__(
        self,
        min_resolution: int = 224,
        blur_threshold: float = 100.0,
        brightness_min: int = 40,
        brightness_max: int = 240,
    ):
        self.min_resolution = min_resolution
        self.blur_threshold = blur_threshold
        self.brightness_min = brightness_min
        self.brightness_max = brightness_max

    def verify(self, image_bytes: bytes) -> dict:
        """
        Verify image quality.

        Args:
            image_bytes: Raw image bytes from upload

        Returns:
            dict with verification results
        """
        result = {
            "valid": True,
            "resolution_ok": True,
            "blur_ok": True,
            "brightness_ok": True,
            "format_ok": True,
            "issues": [],
            "message": "Image is suitable for analysis.",
            "details": {},
        }

        # ─── 1. Format / Validity Check ──────────────────
        try:
            image = Image.open(io.BytesIO(image_bytes))
            image.verify()
            # Re-open after verify
            image = Image.open(io.BytesIO(image_bytes))
            image = image.convert("RGB")
        except Exception:
            result["valid"] = False
            result["format_ok"] = False
            result["issues"].append("invalid_format")
            result["message"] = (
                "This doesn't look like a valid photo. "
                "Please take a new photo of the crop."
            )
            return result

        width, height = image.size
        result["details"]["width"] = width
        result["details"]["height"] = height
        result["details"]["format"] = image.format or "JPEG"

        # Convert to OpenCV format
        cv_image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)

        # ─── 2. Resolution Check ─────────────────────────
        if width < self.min_resolution or height < self.min_resolution:
            result["resolution_ok"] = False
            result["valid"] = False
            result["issues"].append("low_resolution")

        result["details"]["min_dimension"] = min(width, height)

        # ─── 3. Blur Detection ───────────────────────────
        gray = cv2.cvtColor(cv_image, cv2.COLOR_BGR2GRAY)
        laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()
        result["details"]["blur_score"] = round(float(laplacian_var), 2)

        if laplacian_var < self.blur_threshold:
            result["blur_ok"] = False
            result["valid"] = False
            result["issues"].append("too_blurry")

        # ─── 4. Brightness Check ─────────────────────────
        mean_brightness = float(gray.mean())
        result["details"]["brightness"] = round(mean_brightness, 2)

        if mean_brightness < self.brightness_min:
            result["brightness_ok"] = False
            result["valid"] = False
            result["issues"].append("too_dark")
        elif mean_brightness > self.brightness_max:
            result["brightness_ok"] = False
            result["valid"] = False
            result["issues"].append("too_bright")

        # ─── Build farmer-friendly message ────────────────
        if not result["valid"]:
            result["message"] = self._build_message(result["issues"])

        return result

    @staticmethod
    def _build_message(issues: list) -> str:
        """Build a farmer-friendly error message."""
        messages = []

        if "invalid_format" in issues:
            return (
                "This doesn't look like a valid photo. "
                "Please take a new photo of the crop."
            )

        if "low_resolution" in issues:
            messages.append(
                "The photo is too small. "
                "Please move closer to the crop and try again."
            )

        if "too_blurry" in issues:
            messages.append(
                "The photo is too blurry. "
                "Please hold your phone steady and try again."
            )

        if "too_dark" in issues:
            messages.append(
                "The photo is too dark. "
                "Please move to a brighter area and try again."
            )

        if "too_bright" in issues:
            messages.append(
                "The photo is too bright. "
                "Please avoid direct sunlight and try again."
            )

        return " ".join(messages) if messages else "Please take another photo."


# Module-level singleton
_service = None


def get_verification_service() -> ImageVerificationService:
    """Get or create the singleton verification service."""
    global _service
    if _service is None:
        from app.config import (
            MIN_RESOLUTION, BLUR_THRESHOLD,
            BRIGHTNESS_MIN, BRIGHTNESS_MAX,
        )
        _service = ImageVerificationService(
            min_resolution=MIN_RESOLUTION,
            blur_threshold=BLUR_THRESHOLD,
            brightness_min=BRIGHTNESS_MIN,
            brightness_max=BRIGHTNESS_MAX,
        )
    return _service
