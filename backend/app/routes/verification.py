"""
SmartCrop AI — Verification Route
====================================
POST /verify-image — Checks image quality before prediction.
"""

from fastapi import APIRouter, UploadFile, File, HTTPException
from app.schemas.verification import VerificationResponse, VerificationErrorResponse
from app.services.verification_service import get_verification_service
from app.services.image_service import ImageService

router = APIRouter()


@router.post(
    "/verify-image",
    response_model=VerificationResponse,
    responses={400: {"model": VerificationErrorResponse}},
)
async def verify_image(image: UploadFile = File(...)):
    """
    Verify image quality for crop disease analysis.

    Checks:
    - Image validity (is it a real image?)
    - Resolution (minimum 224x224)
    - Blur (Laplacian variance)
    - Brightness (not too dark / bright)
    """
    try:
        # Read image bytes
        image_bytes = await image.read()

        # Check file size
        if not ImageService.validate_file_size(image_bytes, max_mb=10.0):
            return VerificationResponse(
                valid=False,
                message="The photo is too large. Please take a smaller photo.",
                issues=["file_too_large"],
            )

        # Run verification
        service = get_verification_service()
        result = service.verify(image_bytes)

        return VerificationResponse(**result)

    except Exception as e:
        print(f"Verification error: {e}")
        raise HTTPException(
            status_code=500,
            detail="We couldn't check your photo. Please try again.",
        )
