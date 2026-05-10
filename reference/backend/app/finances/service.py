"""Finances service — пример cross-module reads через публичные сервисы."""

from decimal import Decimal
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.profile.service import get_user_by_id
from app.projects.service import get_project_by_id


async def calc_payout_for_user(user_id: UUID, project_id: UUID, db: AsyncSession) -> Decimal:
    """Пример cross-module чтения: тянем User и Project через их публичные сервисы.

    Не импортируем app.profile.models / app.projects.models напрямую —
    только public service.
    """
    user = await get_user_by_id(user_id, db)
    project = await get_project_by_id(project_id, db)

    _ = user, project  # сюда твоя бизнес-логика расчёта payout
    return Decimal("0.00")
