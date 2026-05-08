---
description: Собрать project foundation — shared zone + auth-base + AppShell + design system + CRUD convention
---

Запусти `playbooks/05-foundation.md`.

Используй агента `foundation-builder` (`.claude/agents/foundation-builder.md`).

Что должно быть к концу:
- `backend/app/shared/` — публичные схемы и enum'ы зафиксированы
- `backend/app/profile/` — auth-base работает (login/logout, get_current_user)
- `backend/app/main.py` регистрирует роутеры всех известных модулей
- `frontend/components/ui/` — базовый shadcn-набор (Button, Input, Card, EmptyState, Skeleton)
- `frontend/components/layout/AppShell.tsx` — AppShell с навигацией на все модули из `docs/plan.md`
- `frontend/app/globals.css` + `tailwind.config.ts` — design tokens
- Миграция users применена, `docker compose up` поднимает всё, `/health` отвечает 200
- CI зелёный
- `.github/CODEOWNERS` обновлён под общую зону

Один большой PR в main: `feat: project foundation`. После мержа — каждый Dev делает `/module-init`.
