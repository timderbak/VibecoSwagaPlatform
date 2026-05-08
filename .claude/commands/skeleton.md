---
description: Собрать каркас проекта со всеми stub'ами и зелёным CI
---

Запусти `playbooks/05-skeleton.md`.

Используй агента `skeleton-generator` (`.claude/agents/skeleton-generator.md`).

Шаги:
1. Создать placeholder-страницы для каждого слайса в `frontend/app/<slice>/page.tsx`.
2. Убедиться, что роутеры в `backend/app/api/__init__.py` собирают все слайсы.
3. Создать `backend/tests/integration/test_health.py` (тест /health).
4. Локально: `docker compose -f docker-compose.test.yml up -d && pytest`. Должны быть зелёными.
5. Коммит: `feat: skeleton — all stubs in place, CI green`.
6. Push в main (через PR; auto-merge).
7. Сказать команде: «Скелет собран. Каждый дев теперь делает `git clone <repo> && cd <repo> && claude` и говорит "я <N>-й, погнали".»
