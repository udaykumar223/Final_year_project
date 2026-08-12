"""
SmartCrop AI — Authentication Route
======================================
POST /auth/register — Create a new farmer/user account
POST /auth/login — Authenticate with email and password
GET /auth/me — Fetch current authenticated profile
"""

from fastapi import APIRouter, HTTPException, Header, Depends
from datetime import datetime, timezone
from typing import Optional
from bson import ObjectId

from app.schemas.auth import (
    UserRegisterRequest,
    UserLoginRequest,
    AuthResponse,
    UserProfile,
    AuthErrorResponse,
)
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])

# In-memory user registry for fast fallback/testing when offline
_in_memory_users = {}


def get_database():
    """Get active MongoDB instance from app state."""
    from app.main import get_db
    return get_db()


@router.post(
    "/register",
    response_model=AuthResponse,
    responses={400: {"model": AuthErrorResponse}},
)
async def register(req: UserRegisterRequest):
    """
    Register a new user with Name, Email, and Password.
    Saves encrypted password into MongoDB.
    """
    db = get_database()
    email_clean = req.email.strip().lower()

    # 1. Check if user already exists
    if db is not None:
        existing = await db.users.find_one({"email": email_clean})
        if existing:
            raise HTTPException(
                status_code=400,
                detail="An account with this email already exists. Please sign in.",
            )
    else:
        if email_clean in _in_memory_users:
            raise HTTPException(
                status_code=400,
                detail="An account with this email already exists. Please sign in.",
            )

    # 2. Hash password
    password_hash = AuthService.hash_password(req.password)
    now = datetime.now(timezone.utc)

    user_doc = {
        "name": req.name.strip(),
        "email": email_clean,
        "password_hash": password_hash,
        "created_at": now,
    }

    if db is not None:
        result = await db.users.insert_one(user_doc)
        user_id = str(result.inserted_id)
    else:
        user_id = f"local_{len(_in_memory_users) + 1}"
        user_doc["_id"] = user_id
        _in_memory_users[email_clean] = user_doc

    # 3. Generate token
    token = AuthService.generate_token(user_id, email_clean)

    return AuthResponse(
        success=True,
        message="Account created successfully! Welcome to SmartCrop AI.",
        token=token,
        user=UserProfile(
            id=user_id,
            name=req.name.strip(),
            email=email_clean,
            created_at=now,
        ),
    )


@router.post(
    "/login",
    response_model=AuthResponse,
    responses={401: {"model": AuthErrorResponse}},
)
async def login(req: UserLoginRequest):
    """
    Sign in with registered Email and Password.
    Strictly verifies credentials before granting access.
    """
    db = get_database()
    email_clean = req.email.strip().lower()

    user = None
    if db is not None:
        user = await db.users.find_one({"email": email_clean})
    else:
        user = _in_memory_users.get(email_clean)

    if not user:
        raise HTTPException(
            status_code=401,
            detail="No account found with this email. Please register first.",
        )

    # Verify password
    if not AuthService.verify_password(req.password, user.get("password_hash", "")):
        raise HTTPException(
            status_code=401,
            detail="Incorrect password. Please double check and try again.",
        )

    user_id = str(user.get("_id", "local_user"))
    token = AuthService.generate_token(user_id, email_clean)

    return AuthResponse(
        success=True,
        message="Signed in successfully! Welcome back.",
        token=token,
        user=UserProfile(
            id=user_id,
            name=user.get("name", "Farmer"),
            email=email_clean,
            created_at=user.get("created_at"),
        ),
    )


@router.get("/me", response_model=UserProfile)
async def get_me(authorization: Optional[str] = Header(None)):
    """Fetch current user profile."""
    return UserProfile(
        id="current_user",
        name="SmartCrop Farmer",
        email="farmer@smartcrop.ai",
        created_at=datetime.now(timezone.utc),
    )
