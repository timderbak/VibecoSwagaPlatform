"""Общие enum'ы — публичные значения, которые видят несколько модулей.

Менять — только через RFC-PR.
"""

from enum import StrEnum


class Role(StrEnum):
    """Роли пользователей. Owner: Profile-модуль."""

    USER = "user"
    EXECUTOR = "executor"
    FOUNDER = "founder"
    CLIENT = "client"
    ADMIN = "admin"


class ProjectStatus(StrEnum):
    """Статусы проекта. Owner: Projects-модуль."""

    DRAFT = "draft"
    IN_PROGRESS = "in_progress"
    ON_HOLD = "on_hold"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
