"""
SmartCrop AI — Image Service
===============================
Handles image preprocessing for the backend API.
Converts uploaded bytes to PIL Image for the model.
"""

import io
import cv2
import numpy as np
from PIL import Image


class ImageService:
    """Handles image loading and preprocessing for the API."""

    @staticmethod
    def bytes_to_pil(image_bytes: bytes) -> Image.Image:
        """Convert raw bytes to PIL Image."""
        image = Image.open(io.BytesIO(image_bytes))
        return image.convert("RGB")

    @staticmethod
    def bytes_to_cv2(image_bytes: bytes) -> np.ndarray:
        """Convert raw bytes to OpenCV image (BGR)."""
        nparr = np.frombuffer(image_bytes, np.uint8)
        return cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    @staticmethod
    def pil_to_cv2(pil_image: Image.Image) -> np.ndarray:
        """Convert PIL Image to OpenCV BGR."""
        rgb = np.array(pil_image)
        return cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR)

    @staticmethod
    def cv2_to_pil(cv_image: np.ndarray) -> Image.Image:
        """Convert OpenCV BGR to PIL Image."""
        rgb = cv2.cvtColor(cv_image, cv2.COLOR_BGR2RGB)
        return Image.fromarray(rgb)

    @staticmethod
    def validate_file_size(image_bytes: bytes, max_mb: float = 10.0) -> bool:
        """Check if file size is within limits."""
        size_mb = len(image_bytes) / (1024 * 1024)
        return size_mb <= max_mb
