# VibecoSwagaTemplate

Шаблон-репозиторий для команды из 3 вайбкодеров. Параллельная разработка без слияния-конфликтов и ручных git-команд.

## Старт нового проекта (одна команда)

```bash
npm i -g @vibecoswaga/cli       # один раз в жизни
vibeco init my-new-project      # создаёт репо, ставит окружение, запускает Claude
```

Дальше — описываешь идею Claude в свободной форме. Он сам ведёт через Superpowers конвейер: intake → spec → decompose → contracts → skeleton.

## Подключение к существующему проекту

```bash
vibeco join git@github.com:user/project.git    # одна команда
```

Claude спрашивает «кто из них ты? (1) Тим (2) Влад (3) Стас», ставит границы, запускается в режиме твоего слайса.

## Auto-pilot режим

Человек никогда не пишет git/gh-команды. Только короткие фразы:

| Фраза | Что делает Claude |
|---|---|
| `что у нас?` | сводный отчёт: ветка, PR'ы, входящие cross-zone, reflexion findings |
| `продолжаем` | следующий WP из плана через TDD |
| `отдавай` | pre-PR check + push + PR + auto-merge |
| `аппрув N` | аппрувнуть PR #N |
| `стоп` | прервать текущее действие |
| `откати последний` | git revert HEAD |
| `запроси у X Y` | request-cross-zone |

## Что внутри шаблона

- **`reference/`** — готовый эталон FastAPI + Next.js + Supabase + Docker Compose
- **`playbooks/`** — стек-агностичные инструкции для Claude (intake/spec/decompose/contracts/skeleton/parallel-work)
- **`.claude/`** — слэш-команды и агенты
- **`scripts/`** — `init-project.sh`, `claim-developer.sh`, `check-boundaries.sh`
- **`docs/onboarding/`** — для людей, на случай если что-то пошло не по плану
- **`cli/`** — исходники npm-пакета `@vibecoswaga/cli`

## Документация

- [`docs/onboarding/start-here.md`](docs/onboarding/start-here.md) — для новичка
- [`docs/onboarding/troubleshooting.md`](docs/onboarding/troubleshooting.md) — если что-то не так
- [`docs/onboarding/glossary.md`](docs/onboarding/glossary.md) — что такое слайс, контракт, общая зона
- [`docs/superpowers/specs/2026-05-07-vibeco-template-design.md`](docs/superpowers/specs/2026-05-07-vibeco-template-design.md) — полная спека дизайна

## Лицензия

MIT.
