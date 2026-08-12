"""
SmartCrop AI — FastAPI Backend Configuration
=============================================
Central configuration from environment variables.
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# Load .env file
load_dotenv()

# ─── Server ──────────────────────────────────────────────
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))
DEBUG = os.getenv("DEBUG", "true").lower() == "true"

# ─── MongoDB ─────────────────────────────────────────────
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
MONGODB_DB_NAME = os.getenv("MONGODB_DB_NAME", "smartcrop_ai")

# ─── Model ───────────────────────────────────────────────
PROJECT_ROOT = Path(__file__).parent.parent.parent
MODEL_CHECKPOINT = PROJECT_ROOT / "ai_model" / "checkpoints" / "best_model.pth"
CLASS_NAMES_FILE = PROJECT_ROOT / "ai_model" / "class_names.json"

# ─── Image Verification Thresholds ───────────────────────
MIN_RESOLUTION = 224          # Minimum width/height in pixels
MAX_FILE_SIZE_MB = 10         # Maximum upload size
BLUR_THRESHOLD = 100.0        # Laplacian variance threshold
BRIGHTNESS_MIN = 40           # Minimum mean brightness (0-255)
BRIGHTNESS_MAX = 240          # Maximum mean brightness (0-255)
MIN_IMAGE_AREA = 224 * 224    # Minimum pixel area

# ─── CORS ────────────────────────────────────────────────
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "*").split(",")

# ─── JWT (future) ────────────────────────────────────────
JWT_SECRET = os.getenv("JWT_SECRET", "change-me-in-production")
JWT_ALGORITHM = "HS256"
JWT_EXPIRY_HOURS = 24
