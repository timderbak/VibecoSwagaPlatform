---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  section { font-size: 28px; padding: 60px 80px; }
  h1 { font-size: 48px; }
  h2 { font-size: 38px; color: #0EA5E9; }
  code { background: #f1f5f9; padding: 2px 6px; border-radius: 4px; }
  pre { font-size: 22px; }
  table { font-size: 24px; }
  .small { font-size: 22px; color: #64748b; }
  .accent { color: #0EA5E9; font-weight: 600; }
---

# VibecoSwagaTemplate

## Flow: жирный init → автономная разработка

<br>

<span class="small">Шаблон-репозиторий для команды из 2-3 вайбкодеров.<br>
Workflow на двух плагинах: **GSD** + **superpowers**. Без CODEOWNERS, RFC-PR, ceremony.</span>

---

## Два столба workflow

| Плагин | Что делает | Где живёт |
|---|---|---|
| **GSD** (npx) | Фазовая структура проекта: PROJECT → ROADMAP → SPEC → PLAN → EXECUTE | артефакты в `.planning/` |
| **superpowers** | Дисциплина одной задачи: brainstorming, writing-plans, TDD, debugging | внутри сессии |

<br>

<span class="small">Доп. плагины: <code>frontend-design</code> для дизайн-системы, <code>claude-mem</code> для памяти, <code>context7</code> для свежих доков, <code>context-mode</code> для больших выводов, <code>github</code> для git/gh.</span>

---

## Flow целиком

```
┌─ INIT (жирный, GSD-фаза "Foundation") ────────────────────┐
│   gsd-new-project → PROJECT.md + ROADMAP.md               │
│   DEVELOPERS.md   → кто за какой модуль                   │
│   business-flows  → golden path                           │
│   gsd-spec-phase  → SPEC.md (что строим в foundation)     │
│   gsd-plan-phase  → PLAN.md (задачи foundation)           │
│   gsd-execute-phase:                                      │
│     • frontend-design → дизайн-система, токены, UI-kit    │
│     • shared контракты (UserRead, базовые типы)           │
│     • auth-base + AppShell                                │
│   ОДИН большой PR "foundation готов"                      │
└────────────────────────────────────────────────────────────┘
                          ↓
┌─ После init: каждый Dev автономно ────────────────────────┐
│   читает свою строку в DEVELOPERS.md                      │
│   идёт в свой модуль, кодит фичу за фичей                 │
│   PR + auto-merge когда готов (без cross-approve)         │
└────────────────────────────────────────────────────────────┘
```

---

## Шаг 1 — `gsd-new-project`

Глубокое интервью. Создаёт `.planning/PROJECT.md` и `ROADMAP.md`.

В **PROJECT.md** — что за продукт, ценность, аудитория, тех. ограничения.
В **ROADMAP.md** — milestones; **первая фаза всегда «Foundation»**.

<br>

<span class="small">Это не «опросник на 5 минут» — это full-fledged context gathering.<br>
Без качественного PROJECT.md дальше всё разваливается, поэтому не пропускается.</span>

---

## Шаг 2 — `DEVELOPERS.md`

Единственное назначение файла — **кто за какой модуль**.

```markdown
| # | Имя | GitHub  | Модули     |
|---|-----|---------|-----------|
| 1 | Тим | @tim    | projects  |
| 2 | Влад| @vlad   | finances  |
| 3 | Стас| @stas   | profile, logs, ai |
```

<br>

<span class="accent">Никаких pre-commit hooks, CODEOWNERS, формального enforcement.</span>
Договорная дисциплина: знаешь свой модуль → пишешь в нём; нужен чужой → GitHub-issue с assignee.

---

## Шаг 3 — `gsd-spec-phase` + `gsd-plan-phase`

Фиксируем **что** делаем в Foundation (`SPEC.md`) и **как** (`PLAN.md`):

- дизайн-система (палитра, токены, базовые UI)
- shared контракты (`UserRead`, базовые типы, enum'ы)
- auth-base (`backend/app/profile/`: User, JWT, login)
- AppShell (`frontend/components/layout/`)

<br>

<span class="small">Артефакты в <code>.planning/phases/&lt;date&gt;-foundation/</code>. Можно паузить, возобновлять, передавать.</span>

---

## Шаг 4 — `gsd-execute-phase`

GSD исполняет `PLAN.md` по задачам. Внутри каждой задачи Claude сам подтягивает нужный superpowers-скилл:

- **`frontend-design`** генерирует дизайн-систему → не каждый Dev пишет свой Button
- **`superpowers:test-driven-development`** для auth-base
- **`superpowers:brainstorming`** если развилка по архитектуре

<br>

Результат: один большой PR **«foundation готов, разбирайте»**.

---

## После init — автономия

Каждый Dev:

```
1. git clone, читает DEVELOPERS.md, видит свой модуль
2. gsd-new-milestone / gsd-spec-phase для модуля
3. ./scripts/scaffold-module.sh <module> <Entity>  →  каркас
4. Для фич — два пути на выбор (следующий слайд)
5. PR → auto-merge когда готов
```

<br>

<span class="accent">Никто никого не блокирует.</span>
Cross-approve не нужен. Verification + code review — опциональны. **Reflexion после крупной фичи — обязательна.**

---

## Два пути для фичи

| Путь | Когда | Артефакты |
|---|---|---|
| **GSD** | хочешь паузить/возобновлять, нужен SPEC/PLAN на диске | `.planning/phases/<date>-<slug>/` |
| **superpowers** | фича умещается в одну сессию | нет, только git-история |
| **Edit напрямую** | тривиальная (≤10 строк, опечатка, лог) | — |

<br>

GSD-цикл: `gsd-spec-phase` → `gsd-plan-phase` → `gsd-execute-phase`
Superpowers-цикл: `writing-plans` → `test-driven-development` → PR

---

## Shared zone — без церемонии

```
backend/app/shared/        ← публичные Pydantic-схемы, enums
backend/app/core/          ← config, db, auth utils
frontend/components/ui/    ← Button, Input, Card, ...
tailwind.config.ts         ← design tokens
```

<br>

**Защита = качество init-документации.** На Foundation зафиксированы зоны, owner'ы, контракты, cross-module карта. Все следуют.

<span class="small">Если кто-то нарушит — не катастрофа, поправим вместе. Принимаем риск ради скорости.</span>

---

## Auto-pilot — человек не пишет git

| Фраза | Действие |
|---|---|
| `что у нас?` | `gsd-progress` (ветка, PR'ы, фаза) |
| `продолжаем` | следующая задача из фазы |
| `отдавай` | push → PR → auto-merge |
| `стоп` | прерви, отчитайся |
| `откати последний` | `git revert HEAD` или `gsd-undo` |
| `запроси у X Y` | GitHub-issue с assignee |

<br>

<span class="small">Claude сам делает: rebase main, commit после тестов, push, PR, auto-merge.<br>
Cross-approve выкинут — каждый сам мержит свой PR через auto-merge.</span>

---

## Что внутри шаблона

```
.
├── CLAUDE.md, README.md
├── .claude-plugins.json         # 7 плагинов
├── docs/templates/              # шаблоны для init-project.sh
├── playbooks/04-contracts.md    # единственный survived playbook
├── reference/                   # FastAPI 3.12 + Next.js 15 + Postgres
└── scripts/
    ├── init-project.sh          # распаковка reference + templates
    └── scaffold-module.sh       # каркас нового модуля
```

<br>

<span class="accent">Минимум кастома. Максимум — community-плагины.</span>

---

# Дальше

1. На GitHub: «Use this template» → свой репо
2. `git clone <repo>` → `cd <repo>` → `claude`
3. Скажи: «хочу <твоя идея>»
4. Claude сам всё делает: init-project.sh, gsd-new-project, Foundation, PR

<br>

<span class="accent">Никаких ручных команд от человека.</span>

<span class="small">Только при первом запуске — поставить плагины (см. README §1).<br>
CLAUDE.md — полные правила. playbooks/04-contracts.md — shared zone.</span>
