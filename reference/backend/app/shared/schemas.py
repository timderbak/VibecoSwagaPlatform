"""Публичные Read-схемы для общих сущностей.

Каждая схема имеет owner-модуль. Менять — только через RFC-PR.

Owner-модуль решает форму схемы. Reader-модули импортируют отсюда:
  from app.shared.schemas import UserRead

Если другой модуль хочет добавить поле в UserRead — это cross-zone-issue
к owner'у (Profile в случае User).
"""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, EmailStr

from app.shared.enums import ProjectStatus, Role


class UserRead(BaseModel):
    """Публичная форма User. Owner: Profile (Dev #N).

    Используется в:
      - Profile API (/users/...)
      - Finances (для split rules — кто получает долю)
      - Logs (для отображения, кто что сделал)
      - AI (для контекста)
    """

    id: UUID
    email: EmailStr
    role: Role
    created_at: datetime

    class Config:
        from_attributes = True


class ProjectRead(BaseModel):
    """Публичная форма Project. Owner: Projects (Dev #N).

    Используется в:
      - Projects API (/projects/...)
      - Finances (income/expense FK на project)
      - AI (контекст для генерации summary/budget)
    """

    id: UUID
    title: str
    status: ProjectStatus
    owner_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
