"""
Общая зона.

Сюда идут публичные контракты (Pydantic Read-схемы), общие enum'ы и базовые
типы ответов API. Меняешь — кинь сообщение команде в чат (см. CLAUDE.md §10).

Что здесь живёт:
  - schemas.py    — публичные Read-схемы для общих сущностей (UserRead, ProjectRead, ...)
  - enums.py      — общие enum'ы (Role, ProjectStatus, ...)
  - _common.py    — PaginatedResponse, ErrorResponse и другие базовые типы

Что здесь НЕ живёт:
  - SQLAlchemy-модели — они в `app/<module>/models.py`, частная реализация модуля
  - Бизнес-логика — она в `app/<module>/service.py`
  - Эндпоинты — они в `app/<module>/api.py`

Зачем такая структура:
  - Profile владеет UserRead, но он лежит в shared/ — потому что Finances и AI читают User.
  - Owner модуля решает форму схемы.
  - Reader-модули импортируют только из app.shared.* (не из app.profile.models.*).
"""

from app.shared._common import ErrorResponse, PaginatedResponse
from app.shared.enums import ProjectStatus, Role
from app.shared.schemas import ProjectRead, UserRead

__all__ = [
    "ErrorResponse",
    "PaginatedResponse",
    "ProjectRead",
    "ProjectStatus",
    "Role",
    "UserRead",
]
