"""
SmartCrop AI — Authentication & Security Service
===================================================
Handles password hashing (PBKDF2-SHA256), verification,
and token generation.
"""

import hashlib
import os
import secrets
from datetime import datetime, timezone, timedelta
from typing import Optional


class AuthService:
    """Authentication utility service."""

    @staticmethod
    def hash_password(password: str) -> str:
        """Hash password using PBKDF2-HMAC-SHA256 with a unique random salt."""
        salt = secrets.token_hex(16)
        key = hashlib.pbkdf2_hmac(
            "sha256",
            password.encode("utf-8"),
            salt.encode("utf-8"),
            100_000,
        )
        return f"{salt}${key.hex()}"

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """Verify plain text password against stored salt$hash."""
        try:
            salt, stored_hash = hashed_password.split("$")
            key = hashlib.pbkdf2_hmac(
                "sha256",
                plain_password.encode("utf-8"),
                salt.encode("utf-8"),
                100_000,
            )
            return secrets.compare_digest(key.hex(), stored_hash)
        except Exception:
            return False

    @staticmethod
    def generate_token(user_id: str, email: str) -> str:
        """Generate a secure authentication token for session validation."""
        random_bytes = secrets.token_hex(24)
        timestamp = int(datetime.now(timezone.utc).timestamp())
        payload = f"{user_id}:{email}:{timestamp}:{random_bytes}"
        return hashlib.sha256(payload.encode("utf-8")).hexdigest() + secrets.token_hex(16)
