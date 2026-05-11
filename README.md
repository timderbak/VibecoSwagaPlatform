# VibecoSwagaTemplate

Шаблон-репозиторий для команды из 2-3 вайбкодеров. Жирный init на GSD + минимум формализма после.

Шаблон **не пишет своих скиллов и слэш-команд**. Workflow держится на двух плагинах: **GSD** для фазовой структуры проекта и **superpowers** для дисциплины одной задачи. Никакого CODEOWNERS, RFC-PR, cross-approve, mock-layer, Integration Day — только то, что реально нужно команде.

---

## 1. Что нужно установить (один раз)

### CLI и инструменты
```bash
brew install git gh docker
gh auth login
# Claude Code: https://claude.com/claude-code
```

### Плагины Claude Code
```bash
# Внутри Claude Code:
/plugin install superpowers@claude-plugins-official       # дисциплина процесса (TDD, brainstorm, plans, debug)
/plugin install frontend-design@claude-plugins-official    # генерация дизайн-системы и UI-кода
/plugin install context7@claude-plugins-official           # свежие доки библиотек
/plugin install github@claude-plugins-official             # git/gh из чата
/plugin install claude-mem@thedotmack                      # память между сессиями
/plugin install reflexion@context-engineering-kit          # обязательная критика после крупных фич
/plugin marketplace add mksglu/context-mode
/plugin install context-mode@context-mode                  # экономия контекстного окна
/reload-plugins

# В терминале (GSD — npm-утилита, не плагин):
npx get-shit-done-cc --claude --global                     # фазовый workflow проекта
```

| Плагин | Когда |
|---|---|
| `gsd` (npx) | Жирный init, фазы, ROADMAP, артефакты в `.planning/` |
| `superpowers` | Дисциплина одной задачи: brainstorm → writing-plans → TDD |
| `frontend-design` | Foundation: генерация дизайн-системы; любой UI |
| `context7` | Когда упёрся в баг библиотеки — читать свежие доки |
| `claude-mem` | «Это уже решали?», «как делали в прошлый раз?» |
| `reflexion` | **Обязательная** критика после крупной фичи — единственная обязательная проверка качества |
| `context-mode` | Автоматически перехватывает большие выводы команд |
| `github` | Все git/gh операции из чата |

---

## 2. Старт нового проекта

```bash
# 1. На GitHub: жми "Use this template" → создаёшь свой репо.
# 2. В терминале:
git clone git@github.com:<you>/<your-project>.git
cd <your-project>

# 3. Распакуй reference/ в корень + создай docs/ и .planning/ из шаблонов:
./scripts/init-project.sh fastapi   # или 'blank' если свой стек

# 4. Запусти Claude и скажи «погнали»:
claude
> погнали
```

Дальше Claude **не позволит начать фичи, пока не закончен init**. Init — одна большая GSD-фаза «Foundation»:
1. `gsd-new-project` — глубокое интервью → `.planning/PROJECT.md` + `ROADMAP.md`.
2. `DEVELOPERS.md` — распределение модулей между dev1/dev2/dev3 (единственное назначение файла).
3. `docs/business-flows.md` — golden path.
4. `gsd-spec-phase` + `gsd-plan-phase` для Foundation.
5. `gsd-execute-phase`:
   - дизайн-система через `frontend-design`,
   - shared контракты (`UserRead`, базовые типы),
   - auth-base, AppShell, базовые UI-компоненты.
6. Один большой PR «foundation готов».

После мержа каждый Dev клонирует, читает свою строку в `DEVELOPERS.md` и сразу идёт в свой модуль. Никаких дополнительных настроек.

---

## 3. После init — каждый автономно

Каждый Dev:
1. Читает свою строку в `DEVELOPERS.md` → находит свой модуль.
2. Для модуля: `gsd-new-milestone` / `gsd-spec-phase` → `gsd-plan-phase`.
3. Для каждой фичи: либо GSD-цикл (`gsd-spec-phase` → `gsd-plan-phase` → `gsd-execute-phase`), либо `superpowers:writing-plans` + TDD.
4. PR → auto-merge когда готов.

Никакого cross-approve, никакого CODEOWNERS, никакой обязательной verification-фазы перед мержем. Каждый отвечает за свою зону. **Reflexion после крупной фичи обязательна** — единственная обязательная проверка качества.

В чужой модуль — через GitHub-issue с assignee на owner'а. Общая зона (`backend/app/shared/`, `frontend/components/ui/`, `tailwind.config.ts`) защищается **качеством init-документации**, а не процессом: на Foundation-фазе зоны/контракты/API зафиксированы, и все им следуют. Если кто-то нарушит — не катастрофа, поправим вместе.

---

## 4. Auto-pilot режим

Человек не пишет git/gh — только короткие фразы:

| Скажи Claude | Что произойдёт |
|---|---|
| `что у нас?` | `gsd-progress` — ветка, PR'ы, текущая фаза |
| `продолжаем` | следующая задача из текущей фазы (через GSD или TDD напрямую) |
| `отдавай` | `git push` → `gh pr create` → `gh pr merge --auto --squash` |
| `стоп` | прервёт действие |
| `откати последний` | `git revert HEAD`; для отката фазы — `gsd-undo` |
| `запроси у X Y` | создаст GitHub-issue с assignee на коллегу |

См. `CLAUDE.md §9`.

---

## 5. Что внутри шаблона

```
.
├── CLAUDE.md                  # правила работы (~11 секций)
├── README.md                  # этот файл
├── .claude-plugins.json       # требуемые плагины
├── docs/templates/            # шаблоны для init-project.sh (DEVELOPERS, .planning, business-flows, ...)
├── playbooks/
│   └── 04-contracts.md        # единственный survived playbook — shared zone и owner/readers модель
├── reference/                 # FastAPI 3.12 + Next.js 15 + Postgres эталон
└── scripts/
    ├── init-project.sh        # распаковка reference + копирование templates
    └── scaffold-module.sh     # каркас нового модуля
```

После `./scripts/init-project.sh fastapi`:
```
.
├── backend/, frontend/        # код из reference/
├── docker-compose*.yml, deploy.sh, .env.example
├── DEVELOPERS.md              # из docs/templates/
├── .planning/                 # PROJECT.md, ROADMAP.md, phases/ (для GSD)
├── docs/                      # business-flows, tech-stack, features, architecture, changelog
└── .github/workflows/         # из reference/
```

---

## 6. Стек

`reference/` — один готовый стек: **FastAPI 3.12 + Next.js 15 + PostgreSQL + Docker Compose + GitHub Actions**.

CLAUDE.md написан стек-нейтрально — правила (Docker, integration-тесты, общая зона) применимы к любому стеку. Если нужен другой — `./scripts/init-project.sh blank` и положи свой стек руками.

---

## Лицензия

MIT.
