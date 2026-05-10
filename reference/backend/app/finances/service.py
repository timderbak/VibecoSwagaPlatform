"""Finances service — пример cross-module reads через переключатель."""

from decimal import Decimal
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.finances.deps import get_project_lookup, get_user_lookup


async def calc_payout_for_user(user_id: UUID, project_id: UUID, db: AsyncSession) -> Decimal:
    """Пример cross-module чтения: читаем User и Project через deps.

    В Mode B (MOCK_CROSS_MODULES=true) данные приходят из _mocks.py — Dev
    может разрабатывать Finances не упираясь в готовность Profile/Projects.
    В production-режиме идут на реальные сервисы.
    """
    get_user = get_user_lookup()
    get_project = get_project_lookup()

    user = await get_user(user_id, db)
    project = await get_project(project_id, db)

    # Здесь твоя реальная бизнес-логика расчёта payout
    # Не зависит от того, реальные данные или mock — форма та же (UserRead, ProjectRead).
    _ = user, project
    return Decimal("0.00")
