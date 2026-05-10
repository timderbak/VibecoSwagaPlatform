#!/usr/bin/env bash
# scaffold-module.sh — Генератор шаблонного кода для нового модуля.
#
# Usage:
#   ./scripts/scaffold-module.sh <module> <Entity>
# Пример:
#   ./scripts/scaffold-module.sh billing Subscription
#
# Создаёт минимальный модульный скелет:
#   backend/app/<module>/
#     __init__.py, models.py, service.py, api.py
#   frontend/app/<module>/
#     page.tsx, [id]/page.tsx
#
# Не пишет публичную Read-схему в shared/ — это RFC-PR (см. CLAUDE.md §17).
# Запускается после того, как для модуля написан spec и план.

set -euo pipefail

MODULE="${1:?Usage: $0 <module> <Entity>}"
ENTITY="${2:?Usage: $0 <module> <Entity>}"
ENTITY_LOWER=$(echo "$ENTITY" | tr '[:upper:]' '[:lower:]')

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

BACKEND_DIR="backend/app/$MODULE"
FRONTEND_DIR="frontend/app/$MODULE"

if [ -d "$BACKEND_DIR" ]; then
  echo "✗ $BACKEND_DIR уже существует."
  exit 1
fi

mkdir -p "$BACKEND_DIR" "$FRONTEND_DIR"

# Backend __init__
cat > "$BACKEND_DIR/__init__.py" <<EOF
"""$MODULE module — owner $ENTITY.

Public API:
  - app.shared.schemas.${ENTITY}Read — публичная схема (в общей зоне)
  - app.$MODULE.service.get_${ENTITY_LOWER}_by_id — read через сервис

Internal (НЕ импортировать из других модулей):
  - app.$MODULE.models.$ENTITY
"""
EOF

# Backend models.py
cat > "$BACKEND_DIR/models.py" <<EOF
"""SQLAlchemy-модели $MODULE-модуля. Приватная реализация."""

import uuid
from datetime import datetime

from sqlalchemy import DateTime, String, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.db import Base


class $ENTITY(Base):
    __tablename__ = "${ENTITY_LOWER}s"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    # TODO: добавь свои поля
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
    )
EOF

# Backend service.py
cat > "$BACKEND_DIR/service.py" <<EOF
"""$MODULE service — публичный API модуля."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.$MODULE.models import $ENTITY


async def get_${ENTITY_LOWER}_by_id(${ENTITY_LOWER}_id: UUID, db: AsyncSession) -> $ENTITY | None:
    result = await db.execute(select($ENTITY).where($ENTITY.id == ${ENTITY_LOWER}_id))
    return result.scalar_one_or_none()
EOF

# Backend api.py (CRUD по convention)
cat > "$BACKEND_DIR/api.py" <<EOF
"""$MODULE API.

CRUD по convention (см. backend/app/profile/api.py как пример):
  POST   /${ENTITY_LOWER}s          201 → ${ENTITY}Read
  GET    /${ENTITY_LOWER}s          PaginatedResponse[${ENTITY}Read]
  GET    /${ENTITY_LOWER}s/{id}     ${ENTITY}Read | 404
  PATCH  /${ENTITY_LOWER}s/{id}     ${ENTITY}Read | 404
  DELETE /${ENTITY_LOWER}s/{id}     204 | 404
"""

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.profile.dependencies import get_current_user
from app.shared._common import PaginatedResponse
# TODO: после RFC-PR с публичной схемой:
# from app.shared.schemas import ${ENTITY}Read
from app.$MODULE.service import get_${ENTITY_LOWER}_by_id

router = APIRouter(prefix="/${ENTITY_LOWER}s", tags=["$MODULE"])


class ${ENTITY}Create(BaseModel):
    pass  # TODO: поля для создания


class ${ENTITY}Update(BaseModel):
    pass  # TODO: optional поля для PATCH


# TODO: эндпоинты с raise NotImplementedError("WP — Dev #N")
EOF

# Frontend page.tsx
cat > "$FRONTEND_DIR/page.tsx" <<EOF
export default function ${ENTITY}sPage() {
  return (
    <div>
      <h1 className="text-2xl font-semibold mb-4">$ENTITY</h1>
      <p className="text-muted-foreground">WP в работе. Владелец: Dev #N.</p>
    </div>
  );
}
EOF

mkdir -p "$FRONTEND_DIR/[id]"
cat > "$FRONTEND_DIR/[id]/page.tsx" <<EOF
export default function ${ENTITY}DetailPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <h1 className="text-2xl font-semibold mb-4">$ENTITY {params.id}</h1>
      <p className="text-muted-foreground">WP в работе.</p>
    </div>
  );
}
EOF

echo "✓ Module $MODULE с сущностью $ENTITY создан."
echo ""
echo "Дальше:"
echo "  1. Заполни backend/app/$MODULE/models.py — поля сущности"
echo "  2. Создай RFC-PR с публичной ${ENTITY}Read в backend/app/shared/schemas.py"
echo "  3. После мержа RFC-PR — добавь импорт в api.py и регистрируй роутер в main.py"
echo "  4. alembic revision --autogenerate, alembic upgrade head"
echo "  5. Фичи — через superpowers:writing-plans + superpowers:test-driven-development (см. CLAUDE.md §1)"
