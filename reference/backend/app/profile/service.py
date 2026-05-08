"""Profile service — публичный API модуля для бизнес-логики.

Другие модули импортируют ОТСЮДА (а не из profile.models):
  from app.profile.service import get_user_by_id, get_user_by_email
"""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.profile.models import User


async def get_user_by_id(user_id: UUID, db: AsyncSession) -> User | None:
    """Read user by id. Возвращает SQLAlchemy-объект; для сериализации
    в Pydantic используй `UserRead.model_validate(user)` из app.shared.schemas.
    """
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()


async def get_user_by_email(email: str, db: AsyncSession) -> User | None:
    result = await db.execute(select(User).where(User.email == email))
    return result.scalar_one_or_none()


async def list_users(db: AsyncSession, page: int = 1, page_size: int = 20) -> tuple[list[User], int]:
    raise NotImplementedError("WP — реализуется владельцем Profile-модуля")


async def create_user(email: str, password: str, db: AsyncSession) -> User:
    raise NotImplementedError("WP — реализуется владельцем Profile-модуля")
