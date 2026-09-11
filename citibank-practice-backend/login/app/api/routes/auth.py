from fastapi import APIRouter, HTTPException, status

from app.schemas.auth import LoginRequest, LoginResponse
from app.services.auth_service import (
    authenticate_user,
    AuthenticationError,
)
from app.services.token_service import create_access_token


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)


@router.post(
    "/login",
    response_model=LoginResponse,
)
def login(request: LoginRequest):
    try:
        user = authenticate_user(
            request.email,
            request.password,
        )

        access_token = create_access_token(
            user_id=user["user_id"],
            role=user["role"],
        )

        return LoginResponse(
            access_token=access_token,
            token_type="bearer",
            user_id=user["user_id"],
            role=user["role"],
        )

    except AuthenticationError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )