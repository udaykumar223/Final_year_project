"""
SmartCrop AI — Authentication Schemas
========================================
Pydantic models for user registration, login, and profile.
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class UserRegisterRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=50, description="User's full name")
    email: str = Field(..., min_length=5, max_length=100, description="Email address")
    password: str = Field(..., min_length=6, max_length=100, description="Password (min 6 characters)")


class UserLoginRequest(BaseModel):
    email: str = Field(..., min_length=3, description="Registered email address")
    password: str = Field(..., min_length=1, description="Account password")


class UserProfile(BaseModel):
    id: str
    name: str
    email: str
    created_at: Optional[datetime] = None


class AuthResponse(BaseModel):
    success: bool
    message: str
    token: str
    user: UserProfile


class AuthErrorResponse(BaseModel):
    success: bool = False
    detail: str
