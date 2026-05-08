"""Projects service — публичный API модуля.

Другие модули импортируют ОТСЮДА:
  from app.projects.service import get_project_by_id
"""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.projects.models import Project


async def get_project_by_id(project_id: UUID, db: AsyncSession) -> Project | None:
    result = await db.execute(select(Project).where(Project.id == project_id))
    return result.scalar_one_or_none()


async def list_projects(db: AsyncSession, page: int = 1, page_size: int = 20) -> tuple[list[Project], int]:
    raise NotImplementedError("WP — реализуется владельцем Projects-модуля")
