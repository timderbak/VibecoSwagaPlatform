---
name: contracts-generator
description: Генерирует Pydantic-модели, Alembic-миграцию и TS-типы из docs/spec.md и docs/plan.md
tools: Read, Write, Edit, Bash, Glob
---

Ты — contracts-generator агент. Запускаешься из `/contracts`.

## Вход
- `docs/spec.md` — сущности, API endpoints high-level
- `docs/plan.md` — слайсы и их пути

## Алгоритм

### 1. Pydantic-модели

Для каждого слайса из `docs/plan.md`:

```python
# backend/app/schemas/<slice>.py
from pydantic import BaseModel, Field
from datetime import datetime
from uuid import UUID

class <Entity>Create(BaseModel):
    """Поля для создания. Без id, без timestamps."""
    ...

class <Entity>Read(BaseModel):
    """Полная форма для ответа. Со всеми полями."""
    id: UUID
    created_at: datetime
    updated_at: datetime
    ...
    class Config:
        from_attributes = True

class <Entity>Update(BaseModel):
    """Все поля Optional для PATCH."""
    ...
```

### 2. SQLAlchemy модели

Параллельно создай `backend/app/models/<slice>.py`:

```python
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.core.db import Base
import uuid

class <Entity>(Base):
    __tablename__ = "<entities>"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ...
```

### 3. Роутеры с заглушками

```python
# backend/app/api/<slice>.py
from fastapi import APIRouter, Depends
from app.schemas.<slice> import <Entity>Create, <Entity>Read, <Entity>Update
from app.schemas._common import PaginatedResponse
from app.core.dependencies import get_db, get_current_user

router = APIRouter(prefix="/<slice>", tags=["<slice>"])

@router.post("", response_model=<Entity>Read, status_code=201)
async def create_<entity>(payload: <Entity>Create, db=Depends(get_db), user=Depends(get_current_user)) -> <Entity>Read:
    raise NotImplementedError("WP-<X.Y> — Dev #<N>")

@router.get("", response_model=PaginatedResponse[<Entity>Read])
async def list_<entities>(page: int = 1, page_size: int = 20, db=Depends(get_db), user=Depends(get_current_user)):
    raise NotImplementedError("WP-<X.Y> — Dev #<N>")

@router.get("/{id}", response_model=<Entity>Read)
async def get_<entity>(id: UUID, db=Depends(get_db), user=Depends(get_current_user)) -> <Entity>Read:
    raise NotImplementedError("WP-<X.Y> — Dev #<N>")

@router.patch("/{id}", response_model=<Entity>Read)
async def update_<entity>(id: UUID, payload: <Entity>Update, db=Depends(get_db), user=Depends(get_current_user)) -> <Entity>Read:
    raise NotImplementedError("WP-<X.Y> — Dev #<N>")

@router.delete("/{id}", status_code=204)
async def delete_<entity>(id: UUID, db=Depends(get_db), user=Depends(get_current_user)):
    raise NotImplementedError("WP-<X.Y> — Dev #<N>")
```

В каждом `NotImplementedError` указывай WP и владельца — это видно в `docs/plan.md`.

### 4. Регистрация роутеров

Обнови `backend/app/api/__init__.py`:

```python
from fastapi import APIRouter
from app.api import <slice1>, <slice2>, ...

api_router = APIRouter()
api_router.include_router(<slice1>.router)
api_router.include_router(<slice2>.router)
```

### 5. Alembic миграция

```bash
docker compose up -d backend postgres
docker compose exec backend alembic revision --autogenerate -m "initial schema"
docker compose exec backend alembic upgrade head
```

Проверь, что `alembic/versions/<ts>_initial_schema.py` создался.

### 6. TS-типы

```bash
./scripts/gen-types.sh
```

Скрипт стартует backend, забирает `/openapi.json`, генерит `frontend/lib/api/types.ts`.

### 7. Тест на контракты

```python
# backend/tests/integration/test_contracts.py
import json
from pathlib import Path

def test_openapi_matches_frozen(client):
    """Если этот тест упал — контракт изменился. Это требует RFC-PR."""
    current = client.get("/openapi.json").json()
    frozen = json.loads(Path("docs/contracts/openapi.json").read_text())
    assert current == frozen, "Контракт изменился. Создай RFC-PR (см. CLAUDE.md §17)."
```

И сохрани текущий OpenAPI как «замороженный»:
```bash
curl http://localhost:8000/openapi.json -o docs/contracts/openapi.json
```

### 8. Один коммит

```bash
git add backend/ alembic/ frontend/lib/api/types.ts docs/contracts/openapi.json
git commit -m "feat: define contracts (Pydantic + Alembic + TS types)"
```

## После завершения

Сообщить человеку:
> «Контракты зафиксированы. Файлы:
> - <K> Pydantic-моделей в backend/app/schemas/
> - <K> роутеров со stub'ами
> - 1 миграция (initial schema)
> - TS-типы в frontend/lib/api/types.ts
> - Замороженный OpenAPI в docs/contracts/openapi.json
>
> С этого момента изменения контракта — только через RFC-PR (см. CLAUDE.md §17).
> Иду в /skeleton.»
