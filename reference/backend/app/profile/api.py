"""Profile API — auth + users.

CRUD-конвенция для всех модулей:
  POST   /<entity>           201, body, returns Read
  GET    /<entity>            PaginatedResponse[Read]
  GET    /<entity>/{id}       Read | 404
  PATCH  /<entity>/{id}       Read | 404
  DELETE /<entity>/{id}       204 | 404

Все ошибки → ErrorResponse (см. app.shared._common).
Все list-эндпоинты → PaginatedResponse.
"""

from datetime import timedelta
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from jose import jwt
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.db import get_db
from app.profile._password import verify_password
from app.profile.dependencies import get_current_user
from app.profile.service import (
    create_user,
    get_user_by_email,
    get_user_by_id,
    list_users,
)
from app.shared._common import PaginatedResponse
from app.shared.schemas import UserRead

router = APIRouter(tags=["profile"])


# ---- Auth ----


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


@router.post("/auth/login", response_model=TokenResponse)
async def login(
    form: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db),
) -> TokenResponse:
    """Логин по email + паролю, возвращает JWT."""
    user = await get_user_by_email(form.username, db)
    if not user or not verify_password(form.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    expire = timedelta(minutes=settings.JWT_EXPIRE_MINUTES)
    payload = {"sub": str(user.id), "role": user.role}
    token = jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return TokenResponse(access_token=token)


@router.post("/auth/logout")
async def logout(user=Depends(get_current_user)) -> dict:
    """Logout — на фронте просто выкинуть JWT. Здесь — заглушка для symmetry."""
    return {"status": "logged out"}


# ---- Users CRUD ----


class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)


class UserUpdate(BaseModel):
    email: EmailStr | None = None
    role: str | None = None


@router.post("/users", response_model=UserRead, status_code=201)
async def post_user(
    payload: UserCreate,
    db: AsyncSession = Depends(get_db),
) -> UserRead:
    user = await create_user(payload.email, payload.password, db)
    return UserRead.model_validate(user)


@router.get("/users", response_model=PaginatedResponse[UserRead])
async def get_users(
    page: int = 1,
    page_size: int = 20,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> PaginatedResponse[UserRead]:
    items, total = await list_users(db, page=page, page_size=page_size)
    return PaginatedResponse[UserRead](
        items=[UserRead.model_validate(u) for u in items],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/users/{user_id}", response_model=UserRead)
async def get_user(
    user_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> UserRead:
    user = await get_user_by_id(user_id, db)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserRead.model_validate(user)


@router.patch("/users/{user_id}", response_model=UserRead)
async def patch_user(
    user_id: UUID,
    payload: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> UserRead:
    raise NotImplementedError("WP — реализуется владельцем Profile-модуля")


@router.delete("/users/{user_id}", status_code=204)
async def delete_user(
    user_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> None:
    raise NotImplementedError("WP — реализуется владельцем Profile-модуля")
