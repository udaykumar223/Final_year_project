"""
SmartCrop AI — FastAPI Application
=====================================
Main application entry point.
Configures CORS, routes, Auth, and MongoDB connection.
"""

import sys
from pathlib import Path
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient

from app.config import MONGODB_URL, MONGODB_DB_NAME, CORS_ORIGINS

# Add ai_model to path
AI_MODEL_DIR = Path(__file__).parent.parent.parent / "ai_model"
sys.path.insert(0, str(AI_MODEL_DIR))

# ─── MongoDB ─────────────────────────────────────────────
_db = None
_client = None


def get_db():
    """Get the MongoDB database instance."""
    return _db


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan — startup and shutdown."""
    global _db, _client

    print("\n" + "=" * 50)
    print("  SMARTCROP AI — Starting Server")
    print("=" * 50)

    # Connect to MongoDB (supports online MongoDB Atlas connection string)
    try:
        _client = AsyncIOMotorClient(MONGODB_URL, serverSelectionTimeoutMS=5000)
        # Test connection
        await _client.admin.command("ping")
        _db = _client[MONGODB_DB_NAME]
        print(f"  [OK] MongoDB connected: {MONGODB_DB_NAME}")
    except Exception as e:
        print(f"  [!] MongoDB not available: {e}")
        print("  -> Running with in-memory user & prediction storage")
        _db = None

    # Pre-load the AI model
    print("  Loading AI model...")
    try:
        from app.services.model_service import get_model_service
        service = get_model_service()
        if service.is_loaded:
            print("  [OK] AI model ready")
        else:
            print("  [!] AI model not available — /predict will return 503")
    except Exception as e:
        print(f"  [!] Model loading failed: {e}")

    print("\n  Server ready! [SmartCrop AI]")
    print("=" * 50 + "\n")

    yield

    # Shutdown
    if _client:
        _client.close()
        print("  MongoDB disconnected")


# ─── Create App ──────────────────────────────────────────
app = FastAPI(
    title="SmartCrop AI",
    description=(
        "AI-powered crop disease detection API. "
        "Upload a photo of a crop leaf to identify diseases and severity."
    ),
    version="0.3.0",
    lifespan=lifespan,
)

# ─── CORS ────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Routes ──────────────────────────────────────────────
from app.routes.health import router as health_router
from app.routes.verification import router as verification_router
from app.routes.prediction import router as prediction_router
from app.routes.auth import router as auth_router

app.include_router(health_router, tags=["Health"])
app.include_router(auth_router, tags=["Authentication"])
app.include_router(verification_router, tags=["Verification"])
app.include_router(prediction_router, tags=["Prediction"])


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "service": "SmartCrop AI",
        "version": "0.3.0",
        "docs": "/docs",
        "health": "/health",
    }
