# Playbook 03 — Decomposition

Цель: из `docs/spec.md` нарезать проект на N вертикальных слайсов под состав команды и зафиксировать в `docs/plan.md` + `.github/CODEOWNERS`.

## Когда запускается
- После апрува спеки.
- Вручную: `/decompose`.

## Skill
Кастомная команда `.claude/commands/decompose.md`

## Что такое vertical slice

Слайс = самодостаточный кусок продукта, который включает **все слои**: UI + API + БД + тесты. Пример:

```
slice "billing.subscriptions":
  backend/app/billing/subscriptions/
    ├── models.py        # SQLAlchemy модели
    ├── schemas.py       # Pydantic
    ├── service.py       # бизнес-логика
    ├── api.py           # FastAPI router
    └── tests/
  frontend/app/billing/subscriptions/
    ├── page.tsx
    ├── components/
    └── __tests__/
  alembic/versions/<ts>_add_subscriptions.py
```

Один слайс = один владелец = одна папка.

## Эвристика нарезки

### Шаг 1: главные сущности → слайсы
Из спеки выписываем главные сущности (User, Project, Subscription, Invoice, ...). Каждая = кандидат на слайс.

### Шаг 2: группируем по доменам
Сущности, которые тесно связаны бизнес-логикой, идут в один слайс:
- `billing` = subscriptions + invoices + payments
- `auth` = users + sessions + roles
- `projects` = projects + milestones + deliverables

### Шаг 3: балансировка
Считаем «вес» слайса — число эндпоинтов + UI-страниц. Распределяем между девами **примерно равномерно**.

Если слайс слишком большой (>15 эндпоинтов или >5 страниц) — режем на под-слайсы:
- `billing` → `billing.subscriptions` + `billing.invoices` + `billing.webhooks`

### Шаг 4: общая зона
Что пишется один раз и не повторяется в каждом слайсе:
- `backend/app/core/` — config, db, dependencies
- `backend/app/schemas/` — общие Pydantic-базы (`PaginatedResponse`, `ErrorResponse`)
- `frontend/components/ui/` — дизайн-система (Button, Modal, ...)
- `frontend/lib/api/` — автогенерённый TS-клиент
- `docker-compose*.yml`, `.env.example`, `.github/`

Эти пути идут в `Общая зона (READ-ONLY)` для всех.

## Структура `docs/plan.md`

```markdown
# Plan — <название проекта>
Дата: <YYYY-MM-DD>

## Состав
- Dev #1 — Тим (@tim)
- Dev #2 — Влад (@vlad)
- Dev #3 — Стас (@stas)

## Слайсы

### Dev #1 — Тим
**Slice: projects**
- Path: `backend/app/projects/**`, `frontend/app/projects/**`
- Endpoints: GET/POST/PATCH/DELETE /projects, GET /projects/:id
- Pages: /projects, /projects/[id]
- WPs:
  - WP-1.1: Project CRUD endpoints
  - WP-1.2: Projects list page
  - WP-1.3: Project detail page
  - WP-1.4: Project create form

**Slice: users**
- ...

### Dev #2 — Влад
**Slice: billing.subscriptions**
- Path: `backend/app/billing/subscriptions/**`, `frontend/app/billing/**`
- Endpoints: ...
- WPs: ...

### Dev #3 — Стас
**Slice: auth**
- Path: `backend/app/auth/**`, `frontend/app/auth/**`
- ...

## Общая зона (все CODEOWNERS)
- backend/app/core/**
- backend/app/schemas/**
- frontend/components/ui/**
- frontend/lib/api/**
- docker-compose*.yml
- .env.example
- .github/CODEOWNERS
```

## Структура `.github/CODEOWNERS`

```
# Dev #1 — Тим
/backend/app/projects/   @tim
/frontend/app/projects/  @tim
/backend/app/users/      @tim
/frontend/app/users/     @tim

# Dev #2 — Влад
/backend/app/billing/    @vlad
/frontend/app/billing/   @vlad

# Dev #3 — Стас
/backend/app/auth/       @stas
/frontend/app/auth/      @stas

# Общая зона — нужен аппрув всех
/backend/app/core/        @tim @vlad @stas
/backend/app/schemas/     @tim @vlad @stas
/frontend/components/ui/  @tim @vlad @stas
/frontend/lib/api/        @tim @vlad @stas
/docker-compose*.yml      @tim @vlad @stas
/.env.example             @tim @vlad @stas
/.github/CODEOWNERS       @tim @vlad @stas
```

## После завершения

1. Закоммить `docs/plan.md` и `.github/CODEOWNERS` (commit: `docs: decomposition v1`).
2. Дать человеку посмотреть. Спросить: «Распределение норм или хочешь поменять — кто что берёт?»
3. После апрува — сказать: «Иду в /contracts».
