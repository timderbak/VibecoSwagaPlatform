# Playbook 03 — Project-level Decomposition

Цель: из `docs/spec.md` нарезать проект на **модули и подмодули** (без углубления в features) и распределить владельцев. Feature-уровень делается позже каждым Dev отдельно (см. `playbook 03b-module-decomposition.md`).

## Когда запускается
- После апрува `docs/spec.md`.
- Вручную: `/decompose`.

## Skill
Кастомная команда `.claude/commands/decompose.md`

## 4-уровневая иерархия (важно)

```
Module     ← project-level decompose делает ЭТОТ уровень + Submodule
  └── Submodule
        └── Feature   ← module-level decompose делает ЭТОТ уровень (Dev сам, для своего модуля)
              └── Sub-task   ← feature-execution делает ЭТОТ уровень (TDD)
```

На project-level **не пиши Feature-уровень** — у тебя нет столько контекста после intake. Это будет фантазия. Каждый Dev сам делает module-level intake/spec/decompose для своего модуля, когда дойдёт до его разработки.

## Эвристика нарезки на модули

### Шаг 1: главные домены → модули
Из `docs/spec.md` выписываем главные продуктовые домены. Каждый домен = модуль. Примеры:
- `Projects` — учёт клиентских заказов (создание, милестоны, deliverables)
- `Finances` — биллинг, сплиты, отчёты
- `Profile` — auth, users, roles, settings
- `Logs` — audit trail
- `AI` — LLM-интеграция

### Шаг 2: подмодули внутри модуля
Каждый модуль режется на 2-5 подмодулей, которые **развиваются последовательно** (не параллельно — это один владелец):

```
Module: Projects
├── Submodule 1.1: Project core         (база, без неё ничего)
├── Submodule 1.2: Milestones           (зависит от 1.1)
├── Submodule 1.3: Work Packages        (зависит от 1.2)
└── Submodule 1.4: Deliverables + Approvals  (зависит от 1.3)
```

Подмодуль = логически связанный набор фичей с общей сущностью или процессом.

### Шаг 3: распределение модулей по разработчикам
**Один Dev = один или несколько модулей** (в зависимости от размера). Балансируем по объёму:
- Большой модуль (Projects, Finances) — один Dev целиком
- Несколько мелких модулей (Profile + Logs + AI) — один Dev на все

### Шаг 4: cross-module зависимости
Явно перечисляем, какие модули зависят от каких. Это влияет на порядок старта:
- `Profile.auth` обычно нужен **первым** (без него ничего не защищено)
- `Finances.splits` ← `Profile.roles` (нужны роли для распределения)
- `AI` обычно последним (полишинг)

### Шаг 5: общая зона
- `backend/app/core/` — config, db, dependencies
- `backend/app/schemas/_common.py` — общие Pydantic-базы
- `frontend/components/ui/` — дизайн-система
- `frontend/lib/api/` — автогенерённый клиент
- `docker-compose*.yml`, `.env.example`, `.github/`

Эти пути идут в `Общие зоны` для всех разработчиков.

## Структура `docs/plan.md`

```markdown
# Plan — <название>
Дата: <YYYY-MM-DD>

## Состав
- Dev #1 — <имя> (@handle) → Module: Projects
- Dev #2 — <имя> (@handle) → Module: Finances
- Dev #3 — <имя> (@handle) → Modules: Profile + Logs + AI

---

## Module 1 — Projects (Dev #1)
**Цель:** <одно предложение>
**Path:** `backend/app/projects/**`, `frontend/app/projects/**`

### Submodule 1.1 — Project core
База, без которой нет смысла в остальном.
*Features расписываются на module-level decompose.*

### Submodule 1.2 — Milestones
Зависит от 1.1.

### Submodule 1.3 — Work Packages
Зависит от 1.2.

### Submodule 1.4 — Deliverables + Approvals
Самый сложный, последним.

**Порядок разработки:** 1.1 → 1.2 → 1.3 → 1.4

---

## Module 2 — Finances (Dev #2)
**Цель:** <одно предложение>
**Path:** `backend/app/finances/**`, `frontend/app/finances/**`

### Submodule 2.1 — Money entries
### Submodule 2.2 — Splits
Зависит от 2.1 + от Profile.roles (Dev #3).
### Submodule 2.3 — Reports

**Порядок разработки:** 2.1 → 2.2 → 2.3

---

## Module 3 — Profile + Logs + AI (Dev #3)
### Submodule 3.1 — Profile (auth + users + roles)
**ПЕРВЫЙ** во всём проекте — без auth ничего не защищено.

### Submodule 3.2 — Logs

### Submodule 3.3 — AI (Jarvis)

**Порядок:** 3.1 → 3.2 → 3.3

---

## Cross-module dependencies
- 2.2 (Splits) ← 3.1 (Profile.roles)
- ВСЁ ← 3.1.auth (auth должен быть готов первым)
- Cross-zone-issues создаются по мере появления зависимостей

---

## Общие зоны (CODEOWNERS = все)
- backend/app/core/**
- backend/app/schemas/_common.py
- frontend/components/ui/**
- frontend/lib/api/**
- docker-compose*.yml
- .env.example
- .github/CODEOWNERS

---

## Порядок старта проекта (recommended)
1. Dev #3: Submodule 3.1 (auth + users + roles) — все остальные ждут.
2. Параллельно: Dev #1: Submodule 1.1 (Project core) и Dev #2: Submodule 2.1 (Money entries).
3. Дальше каждый по своему порядку.
```

## `.github/CODEOWNERS`

Генерится из плана. На уровне модулей:

```
# Module: Projects → Dev #1
/backend/app/projects/   @user1
/frontend/app/projects/  @user1

# Module: Finances → Dev #2
/backend/app/finances/   @user2
/frontend/app/finances/  @user2

# Modules: Profile + Logs + AI → Dev #3
/backend/app/profile/    @user3
/backend/app/logs/       @user3
/backend/app/ai/         @user3
/frontend/app/profile/   @user3
/frontend/app/logs/      @user3
/frontend/app/ai/        @user3

# Общая зона — нужен аппрув всех
/backend/app/core/        @user1 @user2 @user3
/backend/app/schemas/_common.py  @user1 @user2 @user3
/frontend/components/ui/  @user1 @user2 @user3
/frontend/lib/api/        @user1 @user2 @user3
/docker-compose*.yml      @user1 @user2 @user3
/.env.example             @user1 @user2 @user3
/.github/CODEOWNERS       @user1 @user2 @user3
```

## После завершения

1. Закоммить `docs/plan.md` и `.github/CODEOWNERS` (commit: `docs: project decomposition v1`).
2. Дать команде посмотреть. Спросить: «Распределение норм или поменять?»
3. После апрува — последовательность дальше:
   - `/contracts` — project-level base contracts (User, общие enum'ы, типы ответов в `shared/`)
   - `/foundation` — общий каркас (auth-base, AppShell, design tokens, UI-kit, CRUD convention)
   - После foundation — каждый Dev #N делает `/module-init` для своего модуля
4. Сказать: «Иду в /contracts.»

## Что НЕ делать на этом шаге

- ❌ Не пиши Feature-уровень (типа «WP-1.1.1: create endpoint»). У тебя нет столько контекста.
- ❌ Не пиши конкретные модели/поля сущностей. Это будет на module-level decompose.
- ❌ Не угадывай edge cases. Каждый Dev сделает module-level intake позже и сам разберётся.

На project-level твоя задача — **скелет**: модули + подмодули + порядок + зависимости. Глубже уйдёт каждый Dev в своём модуле.
