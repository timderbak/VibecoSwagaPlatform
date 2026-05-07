# Playbook 04 — Contracts

Цель: зафиксировать публичный контракт API в виде Pydantic-моделей и сгенерировать TS-типы для фронта.

## Когда запускается
- После `playbook 03-decomposition.md` и апрува плана.
- Вручную: `/contracts`.

## Зачем это нужно

**Контракт = код, не markdown.** Pydantic-модели определяют форму API. Из них:
- FastAPI автоматически собирает OpenAPI-схему (`/docs`).
- Скрипт генерит TypeScript-типы для фронта.
- Фронт может работать против моков, не дожидаясь готового бэка.

Это **исключает** ситуацию «фронт ждал {x: int}, бэк отдал {x: string}».

## Что писать

### `backend/app/schemas/<slice>.py` — для каждого слайса

```python
from pydantic import BaseModel, Field
from datetime import datetime
from uuid import UUID

class ProjectCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    client_id: UUID

class ProjectRead(BaseModel):
    id: UUID
    title: str
    client_id: UUID
    status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ProjectUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=200)
    status: str | None = None
```

### `backend/app/schemas/_common.py` — общие базы

```python
from pydantic import BaseModel
from typing import Generic, TypeVar

T = TypeVar('T')

class PaginatedResponse(BaseModel, Generic[T]):
    items: list[T]
    total: int
    page: int
    page_size: int

class ErrorResponse(BaseModel):
    code: str
    message: str
    details: dict | None = None
```

Все эндпоинты должны возвращать либо доменную модель, либо `ErrorResponse`. Никаких `dict[str, Any]`.

### `backend/app/api/<slice>.py` — эндпоинты с `NotImplementedError`

```python
from fastapi import APIRouter
from app.schemas.projects import ProjectCreate, ProjectRead, ProjectUpdate
from app.schemas._common import PaginatedResponse

router = APIRouter(prefix="/projects", tags=["projects"])

@router.post("", response_model=ProjectRead, status_code=201)
async def create_project(payload: ProjectCreate) -> ProjectRead:
    raise NotImplementedError("WP-1.1 — Dev #1")

@router.get("", response_model=PaginatedResponse[ProjectRead])
async def list_projects(page: int = 1, page_size: int = 20):
    raise NotImplementedError("WP-1.2 — Dev #1")

# ...
```

## Alembic миграция

На этом же шаге создаётся первая миграция со всеми таблицами:

```bash
docker compose exec backend alembic revision --autogenerate -m "initial schema"
docker compose exec backend alembic upgrade head
```

Миграция коммитится вместе с контрактами.

## Генерация TS-типов

Скрипт `scripts/gen-types.sh`:

```bash
#!/bin/bash
docker compose up -d backend
sleep 3
curl http://localhost:8000/openapi.json -o /tmp/openapi.json
docker compose down
npx -y openapi-typescript /tmp/openapi.json -o frontend/lib/api/types.ts
```

Запускается на этом шаге и **после каждого изменения** контрактов.

## После завершения

Один коммит: `feat: define contracts (Pydantic + Alembic + TS types)`.

Файлы в коммите:
- `backend/app/schemas/*.py`
- `backend/app/api/*.py` (роутеры с `NotImplementedError`)
- `backend/app/main.py` (регистрация роутеров)
- `alembic/versions/<ts>_initial_schema.py`
- `frontend/lib/api/types.ts` (автогенерённый)

## После этого момента

**Контракты — святое (см. CLAUDE.md §17).** Менять только через RFC-PR с аппрувом всех CODEOWNERS общей зоны.

Скажи человеку: «Контракты зафиксированы. Иду в /skeleton.»
