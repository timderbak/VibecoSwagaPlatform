---
description: Зафиксировать API-контракты — Pydantic-модели, Alembic-миграция, TS-типы
---

Запусти `playbooks/04-contracts.md`.

Используй агента `contracts-generator` (`.claude/agents/contracts-generator.md`).

Шаги:
1. По `docs/spec.md` создать Pydantic-модели в `backend/app/schemas/<slice>.py` для каждого слайса из `docs/plan.md`.
2. Создать роутеры в `backend/app/api/<slice>.py` с эндпоинтами, каждый с `raise NotImplementedError("WP-X.Y — Dev #N")`.
3. Зарегистрировать роутеры в `backend/app/api/__init__.py` и `backend/app/main.py`.
4. Сгенерировать Alembic-миграцию: `docker compose exec backend alembic revision --autogenerate -m "initial schema"`.
5. Запустить `scripts/gen-types.sh` для регенерации TS-типов.
6. Создать `tests/integration/test_contracts.py` — тест который сравнивает текущий OpenAPI с замороженным `docs/contracts/openapi.json`.
7. Один коммит: `feat: define contracts (Pydantic + Alembic + TS types)`.
8. Сказать человеку: «Контракты зафиксированы. Меняются только через RFC-PR. Иду в /skeleton.»
