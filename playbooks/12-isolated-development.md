# Playbook 12 — Isolated Development (Mode B)

Цель: Dev #N может уйти в свой модуль на дни/недели и работать локально, не упираясь в прогресс коллег и не делая ежедневных мержей в main.

## Когда использовать

| Размер задачи | Стиль | Куда |
|---|---|---|
| Тривиальная sub-task (≤10 строк, фикс) | **A** — PR + auto-merge | прямо в main |
| Средняя Feature (день работы) | **A** — PR + auto-merge | прямо в main |
| **Большой Submodule (неделя+)** | **B** — длинная ветка | один PR в конце |
| **Целый Module** | **B** — длинная ветка | один большой PR |

Плейбук про **Mode B**. Для Mode A (PR-flow) — обычный цикл `superpowers:writing-plans` → TDD → `superpowers:verification-before-completion` → PR.

## Конфликт с CLAUDE.md §12 (git-гигиена)?

CLAUDE.md говорит «коммит после каждой завершённой подзадачи». Это **не отменяется** — ты коммитишь часто **в свою ветку**. Просто **не пушишь в main каждый раз** — ветка `dev/N/<submodule>` живёт долго, а в main приходит один раз батчем.

## Предусловия

1. Foundation готов и зафиксирован (auth-base, shared/, AppShell, design tokens — см. `playbook 04-contracts.md`).
2. Контракты твоего модуля в `shared/` зафиксированы отдельным RFC-PR.
3. Cross-module зависимости явно прописаны в spec модуля (раздел «Cross-zone зависимости»).

## Шаги

### 1. Создай долгую ветку

```bash
git checkout main
git pull origin main
git checkout -b dev/<N>/<submodule>      # например dev/2/billing-subscriptions
```

Эта ветка будет жить **дни/недели**. Не путать с обычными feature-branches которые живут часы.

### 2. Включи mock-режим для cross-module reads

Если твой модуль читает данные других модулей (User из Profile, Project из Projects), но они ещё не реализованы (или ты не хочешь от них зависеть):

```bash
./scripts/mock-mode.sh on
```

Это устанавливает `MOCK_CROSS_MODULES=true` в `.env.local` и переподнимает docker-compose. Все cross-module-вызовы идут на моки из `app/<module>/_mocks.py`.

### 3. Локальный цикл разработки

Работай как обычно — для каждой Feature: `superpowers:writing-plans` → `superpowers:test-driven-development` → коммит в `dev/<N>/<submodule>`. **НЕ создавай PR в main** на каждую Feature — батчем потом.

### 4. Регулярная синхронизация с main (раз в день/два)

Чтобы избежать разъезда:

```bash
git fetch origin main
git rebase origin/main
```

Если конфликт — разруливаешь руками (или зови `general-purpose` агента с конкретным diff'ом). На свежем foundation это редко, потому что общая зона стабильна.

### 5. Contract tests (запускай регулярно)

```bash
docker compose exec backend pytest tests/integration/test_contracts.py -v
```

Этот тест сравнивает текущий OpenAPI с замороженным `docs/contracts/openapi.json`. Если контракт чужого модуля изменился — узнаешь сразу, а не через неделю.

### 6. End-of-Submodule: финальный PR

Когда все Features из Submodule готовы:

```bash
# Отключи mock-режим — проверь, что на реальных зависимостях работает
./scripts/mock-mode.sh off
docker compose down -v && docker compose up -d
docker compose exec backend pytest -v   # должны пройти

# Создай большой PR
git push origin dev/<N>/<submodule>
gh pr create --title "feat(<module>): submodule <name> — full implementation" \
             --body "$(cat <<EOF
## Что включено
- Submodule <name> целиком (Features X.Y.1 - X.Y.K)
- <K> новых эндпоинтов
- <M> новых страниц
- <N> миграций
- Все integration-тесты зелёные

## Cross-module зависимости
- <module>.<entity> — на момент мержа: <статус>

## Полный список Features
- [x] X.Y.1 ...
- [x] X.Y.2 ...

🤖 Mode B (isolated development) submission
EOF
)"
gh pr merge --auto --squash
```

### 7. После мержа — обновить статус в plan.md

Отметь все Features этого Submodule как done в `docs/plan.md`.

## Mock-layer: как работает

В каждом модуле, который **читает** чужие данные, есть `_mocks.py`:

```python
# app/finances/_mocks.py
"""Mock-реализации cross-module читателей. Активны при MOCK_CROSS_MODULES=true."""
from uuid import UUID
from app.profile.models import User   # тип, не реальная модель в работе

async def mock_get_user_by_id(user_id: UUID, db) -> User:
    return User(
        id=user_id,
        email=f"mock-{user_id}@test.local",
        password_hash="",
        role="user",
    )
```

И `deps.py` который выбирает реальный или mock:

```python
# app/finances/deps.py
from app.core.config import settings
from app.profile.service import get_user_by_id as real_get_user
from app.finances._mocks import mock_get_user_by_id

def get_user_lookup():
    if settings.MOCK_CROSS_MODULES:
        return mock_get_user_by_id
    return real_get_user
```

В сервисе:
```python
# app/finances/service.py
from app.finances.deps import get_user_lookup

async def calc_payout(user_id, db):
    get_user = get_user_lookup()
    user = await get_user(user_id, db)
    ...
```

При `MOCK_CROSS_MODULES=true` Finance работает на моках. При `false` — на реальном Profile.

## Что НЕЛЬЗЯ в Mode B

- ❌ Не менять общую зону (`shared/`, `core/`, `components/ui/`) в долгой ветке. Если нужно — отдельный RFC-PR в main, потом rebase своей ветки.
- ❌ Не делать ветку длиннее 2 недель. Накапливается слишком большая дельта. После 2 недель — финальный PR, иначе риск интеграционного ада.
- ❌ Не пропускать Contract tests — иначе словишь расхождение слишком поздно.
- ❌ Не игнорировать `git rebase main` — раз в 1-2 дня обязательно.

## Что обязательно перед финальным PR

- [ ] Mock-режим выключен, всё работает на реальных модулях
- [ ] Все integration-тесты зелёные
- [ ] Contract test проходит (нет дрейфа)
- [ ] Rebase на свежий main без конфликтов
- [ ] `docs/plan.md` обновлён со статусами Features

## Связь с Integration Day

Раз в неделю команда собирается на Integration Day (`playbook 13-integration-day.md`). К этому дню Dev #N либо **закрывает текущий Submodule** одним PR, либо демонстрирует промежуточный прогресс на staging.
