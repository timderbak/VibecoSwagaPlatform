# Playbook 04 — Project-level Contracts (shared zone)

Цель: зафиксировать **публичные контракты общей зоны** — Pydantic Read-схемы общих сущностей, общие enum'ы, базовые типы ответов.

## Когда запускается
- После `playbook 03-decomposition.md`.
- На этом шаге фиксируется минимум: User + базовые типы. Остальные общие сущности (Project, Subscription и т.п.) добавляются позже на module-init соответствующего модуля.

## Skill
Кастомная команда `.claude/commands/contracts.md`, агент `contracts-generator`.

## Концепт «общая зона vs модуль-private»

```
backend/app/
├── shared/                  ← ОБЩАЯ ЗОНА (CODEOWNERS = все)
│   ├── schemas.py           ← UserRead, ProjectRead, ... (Pydantic Read)
│   ├── enums.py             ← Role, ProjectStatus, ...
│   └── _common.py           ← PaginatedResponse, ErrorResponse
├── core/                    ← ОБЩАЯ ЗОНА (CODEOWNERS = все)
│   ├── config.py
│   └── db.py
├── profile/                 ← Module-private (Dev #N)
│   ├── models.py            ← SQLAlchemy User
│   ├── service.py           ← public service API модуля
│   └── api.py               ← endpoints
└── ...
```

**Правило:** Pydantic-схема (форма ответа) — общая. SQLAlchemy-модель (форма таблицы в БД) — приватная модулю-владельцу.

## Что писать на этом шаге

### `backend/app/shared/_common.py` (если ещё нет — есть в reference)

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

Минимум — `Role` (для auth). Остальные enum'ы добавляются на module-init модуля-владельца.

```python
class Role(StrEnum):
    USER = "user"
    EXECUTOR = "executor"
    FOUNDER = "founder"
    CLIENT = "client"
    ADMIN = "admin"
```

### `backend/app/shared/schemas.py`

Минимум — `UserRead` (без неё не работает auth). Остальные общие сущности (`ProjectRead`, `SubscriptionRead`, ...) добавляются позже:

```python
class UserRead(BaseModel):
    id: UUID
    email: EmailStr
    role: Role
    created_at: datetime

    class Config:
        from_attributes = True
```

### Регистрация в `backend/app/shared/__init__.py`

```python
from app.shared._common import ErrorResponse, PaginatedResponse
from app.shared.enums import Role
from app.shared.schemas import UserRead
```

### TS-типы

Они появятся после foundation (когда auth-эндпоинты заработают). Запустить `scripts/gen-types.sh` после `playbook 05-foundation.md`.

## Когда сущность из модуля становится общей

Не каждая сущность модуля идёт в `shared/`. Только если **другие модули будут её читать**.

| Сущность              | Где живёт Pydantic-схема              | Почему |
|-----------------------|---------------------------------------|--------|
| `User`                | `app.shared.schemas.UserRead`         | читают все модули |
| `Project`             | `app.shared.schemas.ProjectRead`      | читают Finances, AI |
| `MoneyEntry`          | `app.finances.api.MoneyEntryRead` (приватный) | никто не читает кроме Finances |
| `AuditLog`            | `app.logs.api.AuditLogRead` (приватный) | только Logs показывает |

Решает owner-модуль на module-init: **«какую часть моего модуля видят другие?»**

## Процесс изменения общей зоны

После первичной фиксации **`shared/` это территория RFC-PR**:
1. Owner создаёт PR **только с изменением `shared/schemas.py`** (+ при необходимости миграция).
2. Тегаются все CODEOWNERS общей зоны.
3. Аппрув всех → мерж.
4. Reader-модули могут использовать новое поле/схему.

Не миксовать с фичей. Один RFC-PR = одно изменение.

## После завершения

1. Закоммить `backend/app/shared/*` (commit: `feat: project base contracts (User, common types, enums)`).
2. Сказать: «Базовые контракты зафиксированы. Иду в `/foundation`.»
