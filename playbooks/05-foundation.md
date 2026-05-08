# Playbook 05 — Project Foundation

Цель: собрать **общий каркас** проекта (skeleton + design-system + auth-base + CRUD-конвенция), на котором потом стоят модули. Каждый Dev #N приходит к **готовой основе** и работает только над своим модулем.

## Когда запускается
- После `playbook 04-contracts.md`.
- Делает фаундер/инициатор проекта (либо вся команда вместе на одном созвоне).
- Вручную: `/foundation` (или старая команда `/skeleton`).

## Skill / Агент
Агент `.claude/agents/foundation-builder.md` (бывший `skeleton-generator`).

## Что должно быть готово к концу

```
docker compose up -d
curl http://localhost:8000/health             # {"status": "ok"}
curl http://localhost:8000/api/v1/openapi.json  # OpenAPI с auth + базовыми эндпоинтами
open http://localhost:3000                    # AppShell с навигацией под все модули
docker compose -f docker-compose.test.yml exec -T backend pytest      # green
docker compose -f docker-compose.test.yml exec -T frontend npm test   # green
```

## Принцип: «займ-код минимум»

В foundation идёт **только то, что используют все модули**. Не больше. НЕ:
- ❌ Бизнес-логика модулей
- ❌ Специфичные UI-компоненты (`ProjectCard` — это в Projects-модуле)
- ❌ Сложный RBAC, биллинг — это модули
- ❌ Любая фича, которую использует только один модуль

## Слои foundation

### 1. Backend: shared zone
Сделано в `playbook 04-contracts.md`:
- `app/shared/_common.py` — PaginatedResponse, ErrorResponse
- `app/shared/enums.py` — Role, ProjectStatus
- `app/shared/schemas.py` — UserRead, ProjectRead

### 2. Backend: core
- `app/core/config.py` — Settings (env-vars через pydantic-settings)
- `app/core/db.py` — engine, session, Base

### 3. Backend: Profile foundation (auth-base)
Минимум для auth (без сложного RBAC):
- `app/profile/models.py` — SQLAlchemy `User`
- `app/profile/_password.py` — bcrypt hash/verify
- `app/profile/dependencies.py` — `get_current_user` (JWT decode)
- `app/profile/service.py` — `get_user_by_id`, `get_user_by_email`
- `app/profile/api.py` — `POST /auth/login`, `POST /auth/logout`, CRUD `/users` (с stub'ами на расширения)

### 4. Backend: Alembic + миграция
- `alembic.ini`, `alembic/env.py` (импортирует все модели)
- Первая миграция: создаёт таблицу `users`. Запускается в Docker.

### 5. Backend: Health + main
- `app/main.py` — FastAPI app, регистрация роутеров, `/health`

### 6. Backend: тесты
- `tests/conftest.py` — `client` fixture
- `tests/integration/test_health.py` — health works
- `tests/integration/test_auth.py` — login flow (если auth уже реализован) или скип

### 7. Frontend: design tokens
- `tailwind.config.ts` — токены через CSS-переменные (`--primary`, `--background`, ...)
- `app/globals.css` — определение CSS-переменных в `:root` и `.dark`

### 8. Frontend: UI kit (shadcn-style)
В `components/ui/`:
- `Button.tsx`
- `Input.tsx`
- `Card.tsx` (+ `CardHeader`, `CardTitle`, `CardContent`)
- `EmptyState.tsx`
- `Skeleton.tsx`
- (далее по необходимости — `Dialog`, `Form`, `Table` через `npx shadcn-ui add ...`)

### 9. Frontend: AppShell
В `components/layout/AppShell.tsx` — header + sidebar + main, с навигацией под **все модули** из `docs/plan.md`. Подключается в `app/layout.tsx`.

### 10. Frontend: API client + типы
- `lib/api/client.ts` — fetch-обёртка с обработкой `ErrorResponse`
- `lib/api/types.ts` — placeholder; перегенерится `scripts/gen-types.sh` после поднятия backend
- `lib/utils.ts` — `cn()` (clsx + tailwind-merge)

### 11. Frontend: главная страница и login
- `app/page.tsx` — landing-stub
- `app/login/page.tsx` — placeholder login form (логика появится в Profile-модуле)

### 12. Docker + CI
- `docker-compose.yml`, `docker-compose.test.yml` — есть в reference
- `.github/workflows/ci.yml` — lint + tests + build
- `.github/CODEOWNERS` — обновлён под `shared/`, `core/`, `components/ui/`, `components/layout/`, `lib/api/`, `tailwind.config.ts`, `app/globals.css`

## CRUD convention (обязательно для всех модулей)

Все CRUD-эндпоинты во всех модулях пишутся по одному шаблону. Reference: `backend/app/profile/api.py` и `backend/app/projects/api.py`.

```
POST   /<entity>           201, body, returns <Entity>Read
GET    /<entity>           PaginatedResponse[<Entity>Read]   (с params: page, page_size, фильтры)
GET    /<entity>/{id}      <Entity>Read | 404
PATCH  /<entity>/{id}      <Entity>Read | 404
DELETE /<entity>/{id}      204 | 404 (предпочтительно soft-delete)
```

- Все ошибки → `ErrorResponse` (`{code, message, details}`).
- Все списки → `PaginatedResponse` (`{items, total, page, page_size}`).
- Все защищённые эндпоинты → `Depends(get_current_user)`.

Для быстрого старта: `./scripts/scaffold-module.sh <module> <Entity>` создаёт скелет.

## Дизайн-конвенция (обязательно для всех модулей)

- Только токены, не хардкоды цветов.
- Только компоненты из `components/ui/`. Свои `Button`/`Input` не писать. Если нужного нет — RFC-PR.
- AppShell оборачивает всё через `app/layout.tsx`. Менять навигацию (добавить/убрать ссылку на модуль) — RFC-PR.

## Проверка foundation

Локально:
```bash
docker compose down -v
docker compose up -d
sleep 5
docker compose exec backend alembic upgrade head
curl http://localhost:8000/health                          # {"status": "ok"}
curl http://localhost:8000/api/v1/openapi.json | jq        # OpenAPI с tags: profile, projects
open http://localhost:3000                                 # AppShell с навигацией Projects/Finances/Profile
```

Тесты:
```bash
docker compose -f docker-compose.test.yml up -d
docker compose -f docker-compose.test.yml exec -T backend alembic upgrade head
docker compose -f docker-compose.test.yml exec -T backend pytest
docker compose -f docker-compose.test.yml exec -T frontend npm test
```

Всё зелёное — foundation готов.

## Коммит

Один большой PR в main:
- Title: `feat: project foundation (shared zone + auth + AppShell + design system)`
- Body: список включённого, ссылка на этот плейбук.
- Auto-merge.

После мержа — каждый Dev #N делает `vibeco join` (или `git clone + claude + я <N>-й погнали`) и идёт через `/module-init` для своего модуля.

## После завершения

```
> «Foundation готов. Теперь каждый разработчик:
>   - git clone <repo> + claude
>   - представляется как Dev #N (onboarding-агент сам всё ставит)
>   - запускает /module-init для своего модуля
>   - после module-init — features через /продолжаем (см. playbook 11)»
```
