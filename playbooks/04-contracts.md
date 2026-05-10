# Playbook 04 — Shared zone

Цель: зафиксировать, что лежит в общей зоне (`backend/app/shared/`, `backend/app/core/`, `frontend/components/ui/`, токены) и как с ней обращаться.

## Когда запускается

Один раз — на этапе init проекта (Foundation-фаза в GSD-roadmap), вместе с дизайн-системой и auth-base.

## Концепт «общая зона vs модуль-private»

```
backend/app/
├── shared/                  ← общие Pydantic Read-схемы, enum'ы, базовые типы
│   ├── schemas.py           ← UserRead, ProjectRead, ...
│   ├── enums.py             ← Role, ProjectStatus, ...
│   └── _common.py           ← PaginatedResponse, ErrorResponse
├── core/                    ← config, db, auth utilities
│   ├── config.py
│   └── db.py
├── profile/                 ← module-private (owner-Dev)
│   ├── models.py            ← SQLAlchemy User
│   ├── service.py           ← public service API модуля
│   └── api.py               ← endpoints
└── ...
```

Правило: **Pydantic-схема (форма ответа) — общая. SQLAlchemy-модель (форма таблицы) — приватная модулю-владельцу.**

## Что писать на этом шаге

### `backend/app/shared/_common.py`

```python
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

### `backend/app/shared/enums.py`

Минимум — `Role` для auth.

```python
class Role(StrEnum):
    USER = "user"
    EXECUTOR = "executor"
    FOUNDER = "founder"
    CLIENT = "client"
    ADMIN = "admin"
```

### `backend/app/shared/schemas.py`

Минимум — `UserRead` (без неё не работает auth):

```python
class UserRead(BaseModel):
    id: UUID
    email: EmailStr
    role: Role
    created_at: datetime

    class Config:
        from_attributes = True
```

Остальные общие схемы (`ProjectRead`, `SubscriptionRead`, ...) добавляются позже, когда соответствующий модуль-owner их публикует.

### `backend/app/shared/__init__.py`

```python
from app.shared._common import ErrorResponse, PaginatedResponse
from app.shared.enums import Role
from app.shared.schemas import UserRead
```

### TS-типы

Появятся после foundation, когда auth-эндпоинты заработают. Запустить `scripts/gen-types.sh`.

## Когда сущность из модуля становится общей

Не каждая сущность модуля идёт в `shared/`. Только если **другие модули будут её читать**.

| Сущность              | Где живёт Pydantic-схема                       | Почему |
|-----------------------|-----------------------------------------------|--------|
| `User`                | `app.shared.schemas.UserRead`                 | читают все модули |
| `Project`             | `app.shared.schemas.ProjectRead`              | читают Finances, AI |
| `MoneyEntry`          | `app.finances.api.MoneyEntryRead` (приватный) | никто не читает кроме Finances |
| `AuditLog`            | `app.logs.api.AuditLogRead` (приватный)       | только Logs показывает |

Решает owner-модуль перед началом фич: «какую часть моего модуля видят другие?»

## Изменение общей зоны

Можно менять кем угодно — **но кинь сообщение в командный чат**, что меняешь. Без формальной RFC-PR-церемонии, без обязательных аппрувов. Если другой Dev не согласен — обсуждаем в комментах PR'а / в чате, договариваемся.

Принцип: одна осмысленная единица изменения = один PR. Не суй правки общей зоны «попутно» внутрь фичи — сделай отдельный коммит/PR, чтобы было видно.
