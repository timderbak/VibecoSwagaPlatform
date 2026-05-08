"""Общие базовые типы ответов API.

PaginatedResponse и ErrorResponse — обязательная convention для всех модулей.
Не переопределять локально, не делать свои.
"""

from typing import Generic, TypeVar

from pydantic import BaseModel

T = TypeVar("T")


class PaginatedResponse(BaseModel, Generic[T]):
    """Стандартный ответ для list-эндпоинтов."""

    items: list[T]
    total: int
    page: int
    page_size: int


class ErrorResponse(BaseModel):
    """Стандартный ответ для всех ошибок 4xx/5xx.

    Все эндпоинты должны возвращать ErrorResponse в случае ошибки, а не
    произвольный dict или string. Это нужно фронту для единообразной обработки.
    """

    code: str
    message: str
    details: dict | None = None
