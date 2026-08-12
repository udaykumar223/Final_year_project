"""
SmartCrop AI — Verification Schemas
=====================================
Pydantic models for the image verification API.
"""

from pydantic import BaseModel, Field
from typing import Optional


class VerificationResponse(BaseModel):
    """Response from the /verify-image endpoint."""
    valid: bool = Field(..., description="Whether the image passes all checks")
    resolution_ok: bool = Field(True, description="Resolution check passed")
    blur_ok: bool = Field(True, description="Blur check passed")
    brightness_ok: bool = Field(True, description="Brightness check passed")
    format_ok: bool = Field(True, description="Format/validity check passed")
    message: str = Field(..., description="Farmer-friendly result message")
    issues: list[str] = Field(default_factory=list, description="List of issue codes")
    details: dict = Field(default_factory=dict, description="Technical details")


class VerificationErrorResponse(BaseModel):
    """Error response."""
    valid: bool = False
    message: str = Field(..., description="Farmer-friendly error message")
