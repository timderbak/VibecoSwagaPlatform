"""Mock-реализации cross-module читателей.

Активны при MOCK_CROSS_MODULES=true (см. playbook 12-isolated-development.md).

Каждая mock-функция должна возвращать тот же тип, что и реальная.
Не делай моки слишком умными — достаточно базовых полей, чтобы тесты прошли.
"""

import uuid
from datetime import datetime
from uuid import UUID

# ВАЖНО: типы импортируем из shared (это публичный контракт), а не из чужих models.
from app.shared.schemas import ProjectRead, UserRead


async def mock_get_user_by_id(user_id: UUID, db) -> UserRead:
    """Заглушка для app.profile.service.get_user_by_id."""
    return UserRead(
        id=user_id,
        email=f"mock-{user_id}@test.local",
        role="user",  # type: ignore[arg-type]
        created_at=datetime.utcnow(),
    )


async def mock_get_project_by_id(project_id: UUID, db) -> ProjectRead:
    """Заглушка для app.projects.service.get_project_by_id."""
    return ProjectRead(
        id=project_id,
        title=f"Mock Project {str(project_id)[:8]}",
        status="in_progress",  # type: ignore[arg-type]
        owner_id=uuid.uuid4(),
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
