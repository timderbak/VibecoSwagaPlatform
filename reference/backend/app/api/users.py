from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.core.dependencies import get_current_user
from app.schemas._common import PaginatedResponse
from app.schemas.users import UserCreate, UserRead, UserUpdate

router = APIRouter(prefix="/users", tags=["users"])


@router.post("", response_model=UserRead, status_code=201)
async def create_user(
    payload: UserCreate,
    db: AsyncSession = Depends(get_db),
) -> UserRead:
    raise NotImplementedError("WP-USERS-1 — реализуется владельцем слайса users")


@router.get("", response_model=PaginatedResponse[UserRead])
async def list_users(
    page: int = 1,
    page_size: int = 20,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user),
) -> PaginatedResponse[UserRead]:
    raise NotImplementedError("WP-USERS-2 — реализуется владельцем слайса users")


@router.get("/{user_id}", response_model=UserRead)
async def get_user(
    user_id: UUID,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user),
) -> UserRead:
    raise NotImplementedError("WP-USERS-3 — реализуется владельцем слайса users")


@router.patch("/{user_id}", response_model=UserRead)
async def update_user(
    user_id: UUID,
    payload: UserUpdate,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user),
) -> UserRead:
    raise NotImplementedError("WP-USERS-4 — реализуется владельцем слайса users")


@router.delete("/{user_id}", status_code=204)
async def delete_user(
    user_id: UUID,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user),
) -> None:
    raise NotImplementedError("WP-USERS-5 — реализуется владельцем слайса users")
