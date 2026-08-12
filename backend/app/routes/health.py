"""
SmartCrop AI — Health Route
==============================
Simple health check endpoint.
"""

from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
async def health_check():
    """Health check endpoint."""
    from app.services.model_service import get_model_service

    try:
        model_service = get_model_service()
        model_loaded = model_service.is_loaded
    except Exception:
        model_loaded = False

    return {
        "status": "ok",
        "model_loaded": model_loaded,
        "service": "SmartCrop AI",
        "version": "0.3.0",
    }
