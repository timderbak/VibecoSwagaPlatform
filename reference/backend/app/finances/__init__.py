"""Finances module (REFERENCE EXAMPLE).

Демонстрирует:
  - cross-module reads (читает User из Profile, Project из Projects)
  - mock-layer для Mode B (isolated development)
  - dependency injection переключатель (см. deps.py)

В реальном проекте этот модуль создаётся через `/module-init` владельцем
финансов, и его внутреннее устройство решает он сам. Это лишь шаблон-пример.
"""
