# VibecoSwagaTemplate

Шаблон-репозиторий для команды из 2-3 вайбкодеров. Параллельная разработка с минимумом git-команд от человека.

Шаблон **не пишет своих скиллов и слэш-команд**. Он опирается на установленные плагины Claude Code и в `CLAUDE.md` явно указывает, какой скилл использовать на каждом шаге.

## Старт нового проекта

```bash
# 1. На GitHub: жми "Use this template" → создаёшь свой репо.
# 2. В терминале:
git clone git@github.com:<you>/<your-project>.git
cd <your-project>
claude
> погнали
```

Дальше Claude:
- Запустит `gsd-new-project` — соберёт глубокий контекст, создаст PROJECT.md / ROADMAP.md.
- Распакует FastAPI+Next.js эталон через `./scripts/init-project.sh fastapi`.
- Зафиксирует базовые контракты (`playbooks/04-contracts.md`).
- Поднимет foundation (auth-base, AppShell, design tokens) одним PR.

Дальше каждый Dev берёт свой модуль и идёт в Module-level (см. `CLAUDE.md §1`).

## Подключение к существующему проекту

```bash
git clone git@github.com:<owner>/<project>.git
cd <project>
claude
> что у нас?
```

Claude посмотрит `git status`, открытые PR'ы, текущий план и спросит, что делаем.

## Auto-pilot режим

Человек никогда не пишет git/gh-команды. Только короткие фразы:

| Скажи Claude | Что произойдёт |
|---|---|
| `что у нас?` | покажет ветку, PR'ы, открытые issues, текущую Feature |
| `продолжаем` | возьмёт следующую задачу через `superpowers:writing-plans` + TDD |
| `отдавай` | прогонит `superpowers:verification-before-completion`, запушит, откроет PR, включит auto-merge |
| `аппрув N` | аппрувнет PR номер N |
| `стоп` | прервёт текущее действие |
| `откати последний` | `git revert HEAD` (без force) |
| `запроси у X Y` | создаст GitHub-issue с assignee на коллегу |

См. `CLAUDE.md §16`.

## Что внутри шаблона

- **`reference/`** — готовый эталон FastAPI 3.12 + Next.js 15 + Postgres + Docker Compose + GitHub Actions.
- **`playbooks/`** — три уникальные процедуры, которых нет в community-скиллах:
  - `04-contracts.md` — shared zone и owner/readers модель.
  - `12-isolated-development.md` — Mode B с mock-слоем.
  - `13-integration-day.md` — еженедельный sync для Mode B.
- **`scripts/`**:
  - `init-project.sh` — распаковать reference/ в корень.
  - `scaffold-module.sh <module> <Entity>` — каркас нового модуля.
  - `mock-mode.sh on|off` — переключатель Mode B mock-слоя.
  - `check-imports.sh` — pre-commit hook против приватных межмодульных импортов.
- **`.claude-plugins.json`** — список требуемых плагинов: `superpowers`, `gsd`, `claude-mem`, `context-mode`, `context7`, `reflexion`, `github`.

Всё остальное (планирование, разработка фич, ревью, дебаг) — community-скиллы:
- **superpowers** — `brainstorming`, `writing-plans`, `executing-plans`, `dispatching-parallel-agents`, `test-driven-development`, `verification-before-completion`, `systematic-debugging`.
- **gsd** — `gsd-new-project`, `gsd-new-milestone`, `gsd-spec-phase`, `gsd-plan-phase`, `gsd-execute-phase`, `gsd-verify-work`, `gsd-ship`.
- **claude-mem** — `mem-search`, `make-plan`, `do`.
- **context-mode** — `ctx_batch_execute`, `ctx_execute` для больших выводов.
- **reflexion** — `reflexion:critique` после крупных фич.

## Multi-developer режим без CODEOWNERS

В шаблоне нет CODEOWNERS, pre-commit hook'а на зоны и DEVELOPER.local.md. Договорная дисциплина:
- Каждый Dev знает свои модули (зафиксировано в `docs/architecture.md` или roadmap).
- В чужой модуль — через GitHub-issue с assignee на owner'а.
- Изменения в общей зоне (`backend/app/shared/`, `frontend/components/ui/`, `tailwind.config.ts`, ...) — только через **RFC-PR** с явным approve остальных Dev'ов.
- Конфликты разруливаются на еженедельном Integration Day (`playbooks/13-integration-day.md`).
- Единственный мягкий enforcement — `scripts/check-imports.sh` запрещает импорт приватных модулей друг у друга.

См. `CLAUDE.md §15` и `§17`.

## Prerequisites

- `git`
- `gh` (GitHub CLI), авторизован: `gh auth login`
- `docker` (Docker Desktop запущен)
- `claude` (Claude Code установлен)
- Установленные плагины из `.claude-plugins.json`

## Лицензия

MIT.
