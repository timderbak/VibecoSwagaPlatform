# VibecoSwagaTemplate

Шаблон-репозиторий для команды из 2-3 вайбкодеров. Параллельная разработка с минимумом git-команд от человека.

Шаблон **не пишет своих скиллов и слэш-команд**. Он опирается на установленные плагины Claude Code и в `CLAUDE.md` явно указывает, какой скилл/команду использовать на каждом шаге.

---

## 1. Что нужно установить (один раз)

### CLI и инструменты
```bash
brew install git gh docker
gh auth login
# Claude Code: https://claude.com/claude-code
```

### Плагины Claude Code

Список — в `.claude-plugins.json`. Команды установки:

```bash
# Внутри Claude Code:
/plugin install superpowers@claude-plugins-official       # дисциплина процесса (TDD, brainstorm, plans, debug)
/plugin install frontend-design@claude-plugins-official    # генерация дизайн-системы и UI-кода
/plugin install context7@claude-plugins-official           # свежие доки библиотек
/plugin install github@claude-plugins-official             # git/gh из чата
/plugin install reflexion@context-engineering-kit          # критика после крупных фич
/plugin install claude-mem@thedotmack                      # память между сессиями
/plugin marketplace add mksglu/context-mode
/plugin install context-mode@context-mode                  # экономия контекстного окна
/reload-plugins

# Опционально — для глубокой UI/UX проработки:
/plugin install ui-ux-pro-max@<marketplace>                # 67 стилей, 96 палитр, 57 шрифтовых пар

# В терминале (GSD — npm-утилита, не плагин):
npx get-shit-done-cc --claude --global                     # фазовый workflow проекта
```

**Кратко зачем какой:**

| Плагин | Когда используется |
|---|---|
| `superpowers` | Любая средняя/крупная фича: brainstorm → plan → TDD → verify |
| `frontend-design` | Foundation: генерация дизайн-системы; любая UI-задача |
| `gsd` (npx) | Управление фазами проекта, ROADMAP, parallel work |
| `context7` | Когда упёрся в баг библиотеки — читать свежие доки |
| `reflexion` | После крупной фичи — multi-perspective критика |
| `claude-mem` | «Это уже решали?», «как делали в прошлый раз?» |
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

# 4. Заполни:
#    - DEVELOPERS.md     — кто dev1/dev2/dev3, какие зоны
#    - .planning/PROJECT.md   — что за проект
#    - .planning/ROADMAP.md   — фазы первого milestone
#    - docs/business-flows.md — хотя бы один пользовательский путь

# 5. Запусти Claude и скажи «погнали»:
claude
> погнали
```

Дальше Claude:
- Прочитает `DEVELOPERS.md`, `.planning/PROJECT.md`, `docs/business-flows.md`.
- Если `.planning/PROJECT.md` ещё не заполнен — запустит `/gsd-new-project` для глубокого интервью.
- **Сгенерирует дизайн-систему** через `frontend-design` (или `ui-ux-pro-max`): палитра, типографика, базовые компоненты, design tokens в `tailwind.config.ts` + `globals.css`. Это часть foundation и делается **до** того, как кодеры разъедутся по модулям — иначе каждый напишет свой Button.
- Зафиксирует базовые контракты (см. `playbooks/04-contracts.md`).
- Поднимет foundation (auth-base, AppShell, design system, базовые UI-компоненты) одним PR.

Дальше каждый Dev берёт свой модуль и идёт в Module-level (см. `CLAUDE.md §1`).

---

## 3. Подключение к существующему проекту

```bash
git clone git@github.com:<owner>/<project>.git
cd <project>
claude
> что у нас?
```

Claude вызовет `/gsd-progress` — посмотрит ветку, открытые PR'ы, текущую фазу, и спросит, что делаем.

Если ты подключаешься первый раз — `git checkout -b dev/<N>/onboarding`, и скажи Claude «я новый разработчик». Он прогонит onboarding (см. `DEVELOPERS.md`).

---

## 4. Auto-pilot режим

Человек никогда не пишет git/gh-команды. Только короткие фразы:

| Скажи Claude | Что произойдёт |
|---|---|
| `что у нас?` | `/gsd-progress` — ветка, PR'ы, текущая фаза, незавершённые задачи |
| `продолжаем` | следующая Feature в текущей фазе через TDD |
| `отдавай` | `verification-before-completion` → push → PR → auto-merge; для крупной фазы — `/gsd-ship` |
| `стоп` | прервёт текущее действие |
| `откати последний` | `git revert HEAD`; для отката всей фазы — `/gsd-undo` |
| `запроси у X Y` | создаст GitHub-issue с assignee на коллегу (если нужны их данные) |

**Каждый кодер автономен:** свой PR создаёт сам и сам же мержит через auto-merge (нужен только зелёный CI, не approve коллег). Cross-approve между кодерами не используется — каждый отвечает за свою зону.

См. `CLAUDE.md §16`.

---

## 5. Что внутри шаблона

```
.
├── CLAUDE.md                  # обязательные правила работы
├── README.md                  # этот файл
├── .claude-plugins.json       # список требуемых плагинов
├── .claude/settings.json      # permissions для Bash-команд
├── docs/
│   └── templates/             # пустые шаблоны для init-project.sh
├── playbooks/
│   ├── 04-contracts.md        # shared zone и owner/readers
│   ├── 12-isolated-development.md  # Mode B (длинная ветка + моки)
│   └── 13-integration-day.md  # еженедельный sync
├── reference/                 # FastAPI + Next.js + Postgres эталон
│   ├── backend/  frontend/
│   ├── docker-compose.yml/.test.yml/deploy.sh/.env.example
│   └── .github/workflows/     # ci, auto-merge, reflexion, staging-deploy
└── scripts/
    ├── init-project.sh        # распаковка reference + docs + .planning
    ├── scaffold-module.sh     # каркас нового модуля
    ├── mock-mode.sh           # переключатель Mode B mock-слоя
    └── check-imports.sh       # pre-commit: запрет приватных импортов
```

После `./scripts/init-project.sh fastapi` появится:

```
.
├── backend/  frontend/        # код, перенесён из reference/
├── docker-compose.yml         # перенесено из reference/
├── deploy.sh  .env.example
├── DEVELOPERS.md              # из docs/templates/DEVELOPERS.md.template
├── .planning/
│   ├── PROJECT.md
│   ├── ROADMAP.md
│   └── phases/                # сюда GSD кладёт SPEC/PLAN/REVIEW
├── docs/
│   ├── business-flows.md      # из docs/templates/
│   ├── tech-stack.md
│   ├── features.md
│   ├── architecture.md
│   └── changelog.md
├── playbooks/                 # без изменений
└── .github/workflows/         # перенесено из reference/
```

---

## 6. Multi-developer режим — автономия в своей зоне

В шаблоне **нет CODEOWNERS, нет required reviewers, нет cross-approve.** Каждый кодер автономен:
- Работает в своей ветке (`dev/<N>/<slice>`).
- Открывает свой PR.
- Сам же мержит через auto-merge — нужен только **зелёный CI**.
- Cross-approve между кодерами **не используется**: коллеги не блокируют друг друга.

Договорная дисциплина (без блокировок):

- **Источник правды по зонам — `DEVELOPERS.md`.** Каждый Dev знает свои модули.
- В чужой модуль — через GitHub-issue с assignee на owner'а: «Нужен метод X в твоём сервисе».
- Изменения в общей зоне (`backend/app/shared/`, `frontend/components/ui/`, `tailwind.config.ts`, ...) — отдельный **RFC-PR** (не смешивать с фичей). Аппрувить обязательно не нужно, но **уведомить команду в чате/комментах** — да.
- Раз в неделю — **Integration Day** (`playbooks/13-integration-day.md`): синхронизация Mode B-веток, smoke-тест, ретро.
- Единственный мягкий enforcement — `scripts/check-imports.sh` запрещает импорт приватных модулей друг у друга.

См. `CLAUDE.md §15` и `§17`.

### Mode A vs Mode B

| Размер задачи | Mode | Куда коммитим |
|---|---|---|
| Тривиальная sub-task / Средняя Feature | A | прямо в main через PR |
| Большой Submodule / целый Module (неделя+) | B | в `dev/<N>/<submodule>`, в main одним PR |
| Изменение общей зоны | A (RFC-PR) | всегда отдельным PR в main |

Mode B включает **mock-режим** для cross-module reads — модуль работает на фейках, не упираясь в коллег. См. `playbooks/12-isolated-development.md`.

---

## 7. Стек

`reference/` содержит **один готовый стек**: FastAPI 3.12 + Next.js 15 + PostgreSQL + Docker Compose + GitHub Actions.

**CLAUDE.md и playbooks написаны стек-нейтрально** — правила (Docker как единственная среда, integration-тесты на endpoint, RFC-PR на общую зону) применимы к любому стеку.

Если нужен другой стек:
1. `./scripts/init-project.sh blank` — пропустить распаковку reference/.
2. Положить свой `backend/`, `frontend/`, `docker-compose.yml` руками.
3. Оставить `playbooks/`, `CLAUDE.md`, `.planning/`, `docs/` — они стек-агностичные.

---

## 8. Что делать дальше

- Полные правила работы → `CLAUDE.md`.
- Параллельная разработка → `playbooks/12-isolated-development.md`.
- Контракты и общая зона → `playbooks/04-contracts.md`.
- Integration Day → `playbooks/13-integration-day.md`.

---

## Лицензия

MIT.
