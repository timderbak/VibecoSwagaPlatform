# Glossary

Термины, которые встречаются в шаблоне.

## Slice (вертикальный срез)

Самодостаточный кусок продукта, включающий все слои:
- backend (модели, схемы, сервис, API)
- frontend (страницы, компоненты, хуки)
- тесты обоих сторон
- миграции БД (если нужно)

Пример слайса: `billing.subscriptions` = всё, что нужно для управления подписками. Один слайс = один владелец = одна папка в каждом из `backend/app/` и `frontend/app/`.

## Контракт

Pydantic-модель в `backend/app/schemas/<slice>.py`. Из неё:
- автоматически собирается OpenAPI-схема FastAPI
- генерится `frontend/lib/api/types.ts` через `scripts/gen-types.sh`

Контракт — это **код**, не markdown. Его нельзя менять «по-быстрому». Только через RFC-PR с аппрувом всех CODEOWNERS общей зоны.

## CODEOWNERS

Файл `.github/CODEOWNERS`, который GitHub использует для определения, кто должен аппрувать PR на каждый путь. В нашей схеме:

- путь твоей зоны → один owner (ты)
- путь общей зоны → три owner'а (вся команда)

С включённым branch protection «Require review from Code Owners» — мерж в main без аппрува овнера физически невозможен.

## Общая зона (shared zone)

Файлы, которые редактируются совместно:
- `docs/contracts/`, `backend/app/schemas/`, `backend/app/core/`
- `frontend/components/ui/`, `frontend/lib/api/`
- `docker-compose*.yml`, `.env.example`, `.github/CODEOWNERS`

Изменения только через RFC-PR с аппрувом всей команды.

## Чужая зона

Слайс другого разработчика. Указан в `DEVELOPER.local.md` как «Чужие зоны». Туда ты **не пишешь**. Если очень нужно — попроси Claude «запроси у <имя> <что>» (он создаст GitHub-issue).

## Cross-zone request

Просьба к овнеру чужой зоны внести изменение, нужное для твоей фичи.

Скажи Claude:
> «запроси у Стаса добавить is_billable: bool в backend/app/auth/models/user.py»

Claude найдёт овнера через `.github/CODEOWNERS` и создаст:
```bash
gh issue create --title "[cross-zone] ..." --label cross-zone-request --assignee <owner>
```

## RFC-PR

Pull Request, изменяющий **только** общую зону (контракт, core, ui-kit и т.п.). Требует аппрува всех CODEOWNERS общей зоны.

Правило: **не миксовать в одном PR изменение своей зоны и общей.** Один RFC-PR = одно изменение общей зоны.

## DEVELOPER.local.md

Локальный файл (в `.gitignore`), в котором записано:
- Я — Dev #N (имя)
- Мои слайсы (READ + WRITE)
- Общие зоны (READ-ONLY)
- Чужие зоны (NO-GO)
- Моя ветка

Генерируется `./scripts/claim-developer.sh N name` (запускается onboarding-агентом Claude автоматически).

## Pre-commit hook

Скрипт `scripts/check-boundaries.sh`, который запускается перед каждым `git commit`. Парсит `DEVELOPER.local.md`, валит коммит при попытке записи в чужую зону.

Обходить через `--no-verify` запрещено.

## TDD цикл

RED → GREEN → REFACTOR → COMMIT.

1. **RED:** написать failing test (он должен упасть, проверить что так).
2. **GREEN:** написать минимум кода, чтобы тест прошёл.
3. **REFACTOR:** причесать код, не сломав тесты.
4. **COMMIT:** один коммит на one logical change.

## WP (work package)

Атомарная задача из `docs/plan.md`. Например, WP-2.3 «implement subscription renewal cron».

Каждый WP проходит TDD цикл и заканчивается отдельным коммитом.

## Stop-rule

После **3 неудачных попыток** решить одну проблему (CI красный, тест падает, интеграция не работает) — стоп. Читать документацию через Context7. Сформулировать гипотезу в чат. Только потом 4-я попытка.

См. CLAUDE.md §5.

## Reflexion

Автоматическая саморевизия после мержа крупной фичи в main. Запускается GitHub Action'ом, выкатывает findings как issues с тегом `reflexion-finding`.

Не блокирует мерж — это пост-фактум.

## Auto-pilot режим

Стиль работы, где человек печатает короткие русские фразы (`что у нас?`, `продолжаем`, `отдавай`), а Claude выполняет git/gh-команды. Подробнее — CLAUDE.md §16.

## Vertical slices vs microservices

В этом шаблоне — **vertical slices в монорепе**. Не микросервисы.

Слайс — это организация кода и владения, а не отдельный сервис. Все слайсы живут в одном FastAPI-приложении и одной БД.

Микросервисы (отдельные deploys, gRPC, version-skew) — для нашей команды (3-5 человек) убийца скорости. Не для нас.
