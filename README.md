# VibecoSwagaTemplate

Шаблон-репозиторий для команды из 3 вайбкодеров. Параллельная разработка без слияния-конфликтов и ручных git-команд.

## Старт нового проекта

```bash
# 1. На GitHub: жми "Use this template" на этом репо → создаёшь свой проект.
# 2. В терминале:
git clone git@github.com:<you>/<your-project>.git
cd <your-project>
claude
> погнали
```

Дальше Claude:
- Распакует FastAPI+Next.js скелет (если выбран этот стек)
- Проведёт интервью (intake)
- Напишет спеку
- Распределит работу на тебя и коллег
- Зафиксирует API-контракты
- Соберёт скелет с зелёным CI

Ты только говоришь идею в чат. Никакой git/gh не пишешь руками.

## Подключение к существующему проекту

```bash
git clone git@github.com:<owner>/<project>.git
cd <project>
claude
> я второй разработчик, погнали
```

Claude найдёт `docs/plan.md`, спросит «кто из них ты?», поставит границы зоны и pre-commit hook, создаст ветку `dev/N/<slice>`, и поедет.

## Auto-pilot режим

Человек никогда не пишет git/gh-команды. Только короткие фразы:

| Скажи Claude | Что произойдёт |
|---|---|
| `что у нас?` | покажет ветку, PR'ы, входящие запросы |
| `продолжаем` | возьмёт следующую задачу из плана и сделает через TDD |
| `отдавай` | прогонит тесты, запушит, откроет PR, включит auto-merge |
| `аппрув N` | аппрувнет PR номер N (от коллеги) |
| `стоп` | прервёт текущее действие |
| `откати последний` | откатит последний коммит (revert, не force) |
| `запроси у X Y` | создаст GitHub-issue с просьбой к коллеге |

## Что внутри шаблона

- **`reference/`** — готовый эталон FastAPI 3.12 + Next.js 15 + Postgres + Docker Compose + GitHub Actions
- **`playbooks/`** — стек-агностичные инструкции для Claude (intake/spec/decompose/contracts/skeleton/parallel-work)
- **`.claude/`** — слэш-команды и агенты, активируются автоматически
- **`scripts/`** — `init-project.sh`, `claim-developer.sh`, `check-boundaries.sh` (запускаются Claude'ом)
- **`docs/onboarding/`** — для людей, на случай если что-то пошло не по плану

## Документация

- [`docs/onboarding/start-here.md`](docs/onboarding/start-here.md) — для новичка
- [`docs/onboarding/troubleshooting.md`](docs/onboarding/troubleshooting.md) — если что-то не так
- [`docs/onboarding/glossary.md`](docs/onboarding/glossary.md) — что такое слайс, контракт, общая зона
- [`docs/superpowers/specs/2026-05-07-vibeco-template-design.md`](docs/superpowers/specs/2026-05-07-vibeco-template-design.md) — полная спека дизайна

## Prerequisites

- `git`
- `gh` (GitHub CLI), авторизован: `gh auth login`
- `docker` (Docker Desktop запущен)
- `claude` (Claude Code установлен глобально)

Подробнее в [`docs/onboarding/install.md`](docs/onboarding/install.md).

## Лицензия

MIT.
