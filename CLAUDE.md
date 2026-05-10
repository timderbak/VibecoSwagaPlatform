# CLAUDE.md

Универсальные правила работы в репозиториях, созданных из VibecoSwagaTemplate. Читать до начала любой задачи.

Шаблон **не пишет своих скиллов и слэш-команд**. Он опирается на установленные плагины (`.claude-plugins.json`) и явно указывает, какой скилл использовать на каждом шаге.

---

## 0. Язык

- **Документация, комментарии в README, ADR, спецификации** — на русском.
- **Код, имена переменных, docstrings, git-коммиты, PR-описания, логи** — на английском.
- **Общение в чате с пользователем** — на русском.

---

## 1. Масштаб задачи определяет процесс

Иерархия 4 уровня:
```
Project → Module → Submodule → Feature → Sub-task
```

Перед любым действием классифицируй задачу и выбери скилл:

### Project-level — новый репозиторий, ещё нет PROJECT.md / spec
1. `gsd-new-project` — задаёт глубокие вопросы, создаёт PROJECT.md, ROADMAP.md, выбирает первый milestone.
2. **Дизайн-система** через `frontend-design` (или `ui-ux-pro-max`): палитра, типографика, design tokens в `tailwind.config.ts`/`globals.css`, базовые компоненты (`Button`, `Input`, `Card`, `EmptyState`, `Skeleton`) в `frontend/components/ui/`. Это нужно сделать **до** того, как кодеры разойдутся по модулям — иначе каждый напишет свой `Button`.
3. После того как roadmap зафиксирован — `playbook 04-contracts.md` (наша shared-зона: User, базовые типы, enums).
4. Дальше — foundation (auth-base, AppShell, дизайн-система зафиксирована из шага 2) одним PR. Это просто крупная Feature: `superpowers:writing-plans` → `superpowers:test-driven-development` → PR.
5. После foundation — каждый Dev берёт свой модуль и идёт в Module-level.

### Module-level — новый модуль внутри проекта
1. `gsd-new-milestone` (если модуль = milestone) **или** `gsd-spec-phase` для spec модуля.
2. `gsd-plan-phase` — план модуля с Submodules / Features.
3. `playbook 04-contracts.md` снова — добавить публичную Read-схему модуля в `shared/` через **RFC-PR** (см. §17).
4. `./scripts/scaffold-module.sh <module> <Entity>` — каркас файлов.
5. Дальше — Feature-level.

### Feature-level — конкретная фича из плана модуля
- **Тривиальная sub-task** (≤ 10 строк, ≤ 2 файла, нет новой логики) — Edit/Write напрямую, без скиллов. Примеры: переименовать переменную, добавить лог, поправить опечатку.
- **Средняя Feature** (день работы, понятное решение):
  1. `gsd-spec-phase` или `superpowers:writing-plans` — короткий план в `.planning/phases/<date>-<slug>/PLAN.md`.
  2. `superpowers:test-driven-development` — RED → GREEN → REFACTOR → COMMIT.
  3. `superpowers:verification-before-completion` перед PR.
- **Крупная Feature** (архитектурные решения, state machine, новые контракты, cross-cutting):
  1. `superpowers:brainstorming` — варианты, edge cases, риски.
  2. `superpowers:writing-plans` — подробный план.
  3. `superpowers:dispatching-parallel-agents` (если под-задачи независимы) или `superpowers:executing-plans`.
  4. `superpowers:test-driven-development` по каждой под-задаче.
  5. `superpowers:verification-before-completion`.
  6. Если меняет публичный контракт shared/ — отдельный RFC-PR (§17).

### При сомнениях
- Между тривиальной и средней — делать как среднюю.
- Между средней и крупной — **спросить пользователя**.
- Если фича в новом модуле — сначала Module-level, потом фича.

### Признаки крупной задачи
- Новый модуль / новая внешняя зависимость / state machine / изменение auth-permissions / изменение публичного API.

---

## 2. Docker — единственная среда выполнения

- **Все тесты, запуски, проверки — только в Docker-контейнерах.** Никогда не запускать локально.
- Если поменял код — сам пересобери/перезапусти контейнер. **Не проси пользователя.**
- `docker compose` предпочтительнее одиночных `docker run`.
- Для каждого сервиса — свой `Dockerfile`; для связки — `docker-compose.yml` в корне.
- Тестовый стенд — отдельный `docker-compose.test.yml` с изолированной БД.

---

## 3. Тесты

Уровень тестирования зависит от типа проекта.

### Проекты с БД и/или HTTP API
- **На каждый endpoint — integration-тест в Docker** с реальной БД (не mock).
- Минимум для CRUD: `create → get → verify`. Для сложной логики — отдельные сценарии.
- Проверять не только happy path, но и: 401/403, 404, 422, tenancy.

### Скрипты, утилиты, либы
- Unit-тесты на ключевую логику. Моки допустимы.

### Общие правила
- Тесты пишутся **вместе с кодом**, не после. Без теста — фича не готова.
- TDD цикл (`superpowers:test-driven-development`): RED → GREEN → REFACTOR → COMMIT.
- После любой реализации — прогнать всю тестовую пачку. Красный тест = работа не завершена.
- Перед PR — `superpowers:verification-before-completion`.

---

## 4. Business Flow обязателен

Для любого продукта в `docs/business-flows.md` должны быть описаны **реальные пользовательские сценарии от начала до конца**, а не просто список фич.

Каждая новая фича сверяется с business flow: как она встраивается в реальный путь пользователя.

---

## 5. Stop rule: три провала — стоп и читать доки

Если **три раза подряд** не можешь решить одну проблему:

1. **Остановиться.** Не пробовать четвёртый раз наугад.
2. Найти официальную документацию через `mcp__plugin_context7_context7__resolve-library-id` + `query-docs`, или web-search.
3. Прочитать релевантный раздел целиком.
4. Сформулировать в чате: «Я застрял на X, прочитал Y, гипотеза Z».
5. **Только тогда** — новая попытка.

В auto-pilot режиме (см. §16) ты обязан сам выйти из retry-цикла после 3-го фейла и позвать человека. Бездумный retry loop — главный антипаттерн.

Если уперся в баг — `superpowers:systematic-debugging`.

---

## 6. Impact analysis при изменениях

Перед изменением любого модуля:

- Найти все места, которые его используют (`grep` / `rg`).
- В спецификации перечислить, что потенциально ломается.
- После реализации проверить, что связанные части работают (их тесты тоже гоняем).

---

## 7. Документация после крупных изменений

После завершения крупной фичи обязательно обновить:

- `docs/tech-stack.md` — текущий стек, версии, зависимости.
- `docs/features.md` — список реализованных фич.
- `docs/changelog.md` — что изменилось, дата, ссылка на спеку.
- `docs/architecture.md` — если поменялась архитектура.

Цель: новый разработчик за 15 минут понимает, что есть и как устроено.

---

## 8. Reflexion после крупных фич

После имплементации крупной фичи запустить `reflexion:critique` **автоматически** (вручную, без CI-обвязки) и пройтись по findings вместе с пользователем.

---

## 9. Структура проекта

```
├── CLAUDE.md
├── README.md
├── DEVELOPERS.md                # команда + зоны ответственности (см. §15)
├── docker-compose.yml
├── docker-compose.test.yml
├── deploy.sh
├── .env.example
├── .claude-plugins.json         # требуемые плагины (superpowers, gsd, claude-mem, context-mode, context7, reflexion, github)
├── .planning/                   # GSD: контекст проекта + roadmap + фазы
│   ├── PROJECT.md
│   ├── ROADMAP.md
│   └── phases/
│       └── <YYYY-MM-DD>-<slug>/
│           ├── SPEC.md, PLAN.md, REVIEW.md, VERIFICATION.md
├── docs/
│   ├── business-flows.md
│   ├── tech-stack.md
│   ├── features.md
│   ├── architecture.md
│   ├── changelog.md
│   └── contracts/               # Pydantic + сгенерённые OpenAPI/TS
├── backend/                     # FastAPI (или другой бэкенд)
├── frontend/                    # Next.js (или другой фронтенд)
├── playbooks/                   # уникальные для шаблона процедуры
│   ├── 04-contracts.md          # shared zone
│   ├── 12-isolated-development.md  # Mode B
│   └── 13-integration-day.md
├── scripts/
│   ├── init-project.sh
│   ├── scaffold-module.sh
│   ├── mock-mode.sh
│   └── check-imports.sh         # pre-commit: запрет приватных межмодульных импортов
└── .github/
    └── workflows/
```

Документация только в `docs/`. Спеки фаз — в `.planning/phases/`. Код — только в `backend/` и `frontend/`.

---

## 10. Деплой

Если проект деплоится — обязательно `deploy.sh` в корне:

- Идемпотентный (можно запустить дважды).
- Проверяет пререквизиты (Docker, .env, доступ).
- Откатывается при ошибке или явно сообщает «всё сломалось».

Никаких «зайди по ssh и скопируй руками».

---

## 11. Секреты и конфиги

- Никогда не хардкодить ключи, пароли, токены, продакшн-URL.
- Всё через `.env` + `.env.example` (плейсхолдеры без значений).
- `.env` — в `.gitignore`. Всегда.
- Секреты в коммите = немедленный откат + ротация ключа.

---

## 12. Git-гигиена

- Коммит после каждой завершённой подзадачи.
- Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Сообщение на английском, императив: `feat: add JWT refresh endpoint`.
- Перед коммитом — тесты зелёные в контейнере.
- **Никаких `--no-verify`, `--force`, ручного мержа в обход auto-merge** (см. §16).

---

## 13. Автономность vs согласование

**Claude делает сам:**
- Пересобирает контейнеры.
- Запускает тесты.
- Читает документацию через `context7`, когда застрял (§5).
- Обновляет `docs/` после крупных фич.
- Делает коммиты по подзадачам.
- Делает `git pull && rebase`, `git push`, `gh pr create`, `gh pr merge --auto` (см. §16).

**Claude спрашивает пользователя:**
- Перед выбором между архитектурными вариантами (на этапе brainstorm).
- После reflexion — что из findings чинить.
- Перед изменением общей зоны (контракты, core, ui, docker-compose).

---

## 14. Чек-лист перед сдачей крупной фичи

- [ ] Пройден полный пайплайн (`brainstorming` → `writing-plans` → `executing-plans` или `dispatching-parallel-agents` → TDD → `verification-before-completion`).
- [ ] Все тесты зелёные в Docker.
- [ ] Integration-тесты покрывают все новые endpoint'ы.
- [ ] Impact на связанные модули проверен.
- [ ] `docs/` обновлены.
- [ ] Business flow обновлён, если нужно.
- [ ] Секреты не утекли в код.
- [ ] `deploy.sh` обновлён, если нужно.
- [ ] `reflexion:critique` запущен и findings обсуждены.

---

## 15. Multi-developer mode

В этом репо работают несколько вайбкодеров параллельно. **Зон-ownership на уровне CODEOWNERS / pre-commit hook нет** — это сознательный отказ от жёсткого enforcement в пользу договорной дисциплины.

### Базовая конвенция

- **Источник правды по зонам — `DEVELOPERS.md` в корне.** Кто dev1/dev2/dev3, какие модули его, какой префикс ветки.
- **Каждый кодер автономен:** свой PR создаёт сам и сам же мержит через auto-merge. Cross-approve не используется — коллеги не блокируют друг друга.
- В чужой модуль не пишешь без согласования с owner'ом. Хочешь? Создай GitHub-issue с assignee на него.
- Изменения в общей зоне (`backend/app/shared/`, `backend/app/core/`, `frontend/components/ui/`, `frontend/components/layout/`, `frontend/app/globals.css`, `tailwind.config.ts`) — **отдельным RFC-PR** (см. §17), не смешивать с фичей. Команду уведомить в чате/PR-комменте, но approve не блокирующий.
- Конфликты разруливаются на еженедельном Integration Day (см. `playbooks/13-integration-day.md`).

### Что осталось как мягкий enforcement
- `scripts/check-imports.sh` — pre-commit hook, валит коммит при попытке импорта приватных модулей друг у друга (`from app.profile.models import User` из `app/finances/` запрещено). Это правило об инкапсуляции модулей, а не о зонах. Не пытайся обойти `--no-verify`.

---

## 16. Auto-pilot mode (никаких git-команд от человека)

Человек печатает короткие русские фразы. Ты выполняешь git/gh.

> **Внутренний движок:** для большинства фраз ниже под капотом вызывается `/gsd-progress` — unified situational командa GSD, которая сама понимает «check progress / advance workflow / freeform intent» по фразе. Не дублируй её логику — делегируй.

### Словарь команд

| Фраза человека | Действие |
|---|---|
| `что у нас?` | `/gsd-progress` (покажет: ветку, PR'ы, текущую фазу, незавершённые задачи) |
| `продолжаем` | `/gsd-progress` (продолжает текущую фазу) или `/gsd-execute-phase` если уже есть PLAN.md; для тривиальной — TDD напрямую |
| `отдавай` | `superpowers:verification-before-completion` → `git push` → `gh pr create` → `gh pr merge --auto --squash`; для крупной фазы — `/gsd-ship` |
| `стоп` | Прерви текущее действие, отчитайся |
| `откати последний` | `git revert HEAD` (БЕЗ force); для отката всей фазы — `/gsd-undo` |
| `запроси у <имя> <что>` | `gh issue create --title "[<module>] ..." --assignee <owner>` |

> **Cross-approve между кодерами не используется.** Каждый автономно мержит свои PR через auto-merge — нужен только зелёный CI. Никаких «аппрув N»: команда vibe-кодеров не блокирует друг друга на ревью.

### Что Claude делает автоматически (без спроса)

- `git pull && git rebase main` — на старте сессии и перед PR.
- `git add && git commit` — после успешных тестов.
- `git push` — после каждого коммита в свою ветку.
- `gh pr create` + `gh pr merge --auto --squash` — на «отдавай» или после завершения Feature.
- Прогон тестов в Docker.
- Фикс CI-фейла — ≤3 попытки, потом stop-rule (§5).
- `reflexion:critique` после мержа крупной фичи.

### Что Claude НЕ делает без человека

- Force-push.
- Изменение `backend/app/shared/`, `frontend/components/ui/`, `tailwind.config.ts` без RFC-PR (см. §17).
- Удаление чужой ветки.
- `gh pr merge` в обход auto-merge.
- Аппрув или мерж **чужого** PR (vibe-кодер работает только в своей зоне; чужие PR — не его дело).

### При красном CI
1. Анализируй вывод теста.
2. Гипотеза → фикс → запуск.
3. Если не помогло — ещё гипотеза → фикс → запуск.
4. Если не помогло третий раз — **СТОП**. `superpowers:systematic-debugging` + `context7`. Дальше зови человека.

---

## 17. Контракты, общая зона и cross-module reads — святое

### Что лежит в общей зоне

```
backend/app/shared/        ← публичные Pydantic Read-схемы (UserRead, ProjectRead, ...),
                             enum'ы (Role, ProjectStatus), общие типы (PaginatedResponse, ErrorResponse).
                             RFC-PR при изменении.
backend/app/core/          ← config, db, base. RFC-PR при изменении.
frontend/components/ui/    ← дизайн-система: Button, Input, Card, EmptyState, Skeleton.
                             Все модули используют ТОЛЬКО эти компоненты.
frontend/components/layout/ ← AppShell с навигацией. RFC-PR при изменении.
frontend/lib/api/          ← клиент API + автогенерённые TS-типы.
frontend/app/globals.css   ← design tokens (цвета, типографика). RFC-PR при изменении.
tailwind.config.ts         ← токены. RFC-PR при изменении.
```

### Owner / Readers модель

Каждая сущность в `backend/app/shared/schemas.py` имеет **одного owner-модуля** и любое число **reader-модулей**:

| Сущность   | Owner          | Readers (примеры)              |
|------------|----------------|-------------------------------|
| User       | Profile        | Finances, Logs, AI, Projects   |
| Project    | Projects       | Finances, AI                   |
| Subscription | Profile      | Finances                       |

- **Owner** делает CRUD (create/update/delete + БД-модель в своём модуле).
- **Readers** только читают через публичный сервис другого модуля.

### Правила импортов между модулями

```python
# ✅ РАЗРЕШЕНО:
from app.shared.schemas import UserRead, ProjectRead     # public schemas
from app.shared.enums import Role                        # public enums
from app.profile.service import get_user_by_id           # public service of another module
from app.profile.dependencies import get_current_user    # public dependencies
from app.core.db import get_db                            # core utility

# ❌ ЗАПРЕЩЕНО (нарушение module-инкапсуляции):
from app.profile.models import User                # private model of another module
from app.profile._password import hash_password    # private util (_xxx)
from app.profile.api import router                 # api.* импортируется только в main.py
```

`scripts/check-imports.sh` (pre-commit) валит коммит при таком импорте.

### Когда менять общую зону

- При первичной фиксации (см. `playbooks/04-contracts.md`).
- Когда новый модуль публикует свою Read-схему.
- Только через **RFC-PR**: отдельный PR только с изменением общей зоны, в чате/PR-комменте просим approve остальных Dev'ов.

### Если фича требует изменить контракт или общий компонент

Остановись и спроси пользователя:
> «Эта фича меняет публичную форму X в общей зоне (схема / UI-компонент / дизайн-токен). Создаём RFC-PR? (y/n)»

Если `y` — создай отдельный PR только с этим изменением, попроси approve. Дождись мержа. Только тогда продолжай фичу.

### Никогда не меняй общую зону «попутно»

Даже если кажется маленьким. Один контракт / один UI-компонент = один RFC-PR.

### Cross-module запрос данных (для reader-модулей)

```python
# В backend/app/finances/service.py (Dev #2):
from app.profile.service import get_user_by_id    # public read
from app.shared.schemas import UserRead

async def calc_payout(user_id, db):
    user = await get_user_by_id(user_id, db)
    return UserRead.model_validate(user)
```

Если нужного метода в чужом сервисе нет — обычный GitHub-issue с assignee на owner'а.

### Дизайн-конвенция (фронт)

- **Только токены, не хардкоды.** `bg-primary` ✅, `bg-[#0EA5E9]` ❌.
- **Только компоненты из `components/ui/`**, не свои Button/Input/Card. Если нужного нет — RFC-PR в общую зону.
- **AppShell** оборачивает все страницы (через `app/layout.tsx`). Менять навигацию — RFC-PR.
- **Для генерации/правки UI** используй `frontend-design` (стандарт) или `ui-ux-pro-max` (если нужна палитра/типографика/чарты на выбор). Не пиши Tailwind «на глаз» — это даёт generic AI aesthetic.
- **Дизайн-система фиксируется ОДИН РАЗ в foundation** (см. §1). Дальше каждый кодер использует готовые токены и компоненты. Расширение дизайн-системы — отдельный RFC-PR в `tailwind.config.ts`/`globals.css`/`components/ui/`.

### CRUD convention (бэк)

Все CRUD-эндпоинты пишутся по одному шаблону:

```
POST   /<entity>           201, body, returns <Entity>Read
GET    /<entity>           PaginatedResponse[<Entity>Read]
GET    /<entity>/{id}      <Entity>Read | 404
PATCH  /<entity>/{id}      <Entity>Read | 404
DELETE /<entity>/{id}      204 | 404
```

Все ошибки → `ErrorResponse {code, message, details}`. Все списки → `PaginatedResponse {items, total, page, page_size}`.

Для быстрого старта нового модуля — `./scripts/scaffold-module.sh <module> <Entity>` создаёт скелет.

---

## 18. Onboarding на старте сессии

При запуске Claude в репозитории, созданном из шаблона:

### Если репо новый (нет `.planning/PROJECT.md` или он не заполнен)
Не предлагай задачи. Запусти `/gsd-new-project` — он соберёт глубокий контекст и создаст `.planning/PROJECT.md` и `.planning/ROADMAP.md`.

### Если репо живой
1. Прочитай `DEVELOPERS.md` — спроси, кто из перечисленных ты (если непонятно из git config).
2. Прочитай `.planning/PROJECT.md` и `.planning/ROADMAP.md` — текущий контекст и фазы.
3. Прочитай `docs/changelog.md` (если есть) — что менялось последним.
4. `claude-mem:mem-search` — есть ли релевантные наблюдения из прошлых сессий.
5. `/gsd-progress` или `/gsd-resume-work` — чем заняться дальше.

---

## 19. Стиль работы Dev'а — Mode A vs Mode B

Два разрешённых стиля. Выбор — по размеру задачи.

### Mode A — PR-flow (по умолчанию)
Каждая Feature → PR → auto-merge в main. Подходит для:
- Тривиальных sub-task (≤10 строк, фикс)
- Средних Features (день работы)
- Любого изменения в общую зону (RFC-PR — всегда Mode A)

Цикл: `superpowers:writing-plans` → `superpowers:test-driven-development` → `superpowers:verification-before-completion` → PR.

### Mode B — isolated development (длинная ветка)
Dev уходит в `dev/<N>/<submodule>` на дни/недели. Один большой PR в конце. Подходит для:
- Большого Submodule (неделя+)
- Целого Module
- Когда нужен flow-state без отвлечений

Включает **mock-режим** для cross-module reads — модуль работает на фейковых данных, не упираясь в коллег. См. `playbooks/12-isolated-development.md`.

### Когда какой выбрать

| Размер | Mode | Куда коммитим |
|---|---|---|
| Тривиальная sub-task | A | прямо в main через PR |
| Средняя Feature | A | прямо в main через PR |
| Большой Submodule | B | в `dev/<N>/<submodule>`, в main одним PR |
| Целый Module | B | в `dev/<N>/<module>`, в main одним PR |
| Изменение общей зоны | A (RFC-PR) | всегда отдельным PR в main |

### Mock-режим (Mode B)

В каждом модуле, который **читает** данные других модулей, должен быть:
- `app/<module>/_mocks.py` — mock-функции с теми же сигнатурами, что и реальные сервисы.
- `app/<module>/deps.py` — dependency injection переключатель `get_<entity>_lookup()`.

Пример: `reference/backend/app/finances/`.

Включить mock: `./scripts/mock-mode.sh on` (выставит `MOCK_CROSS_MODULES=true` в `.env.local`).

### Integration Day (раз в неделю)

Каждую пятницу команда собирается:
1. Готовые PR'ы из Mode B мержим в main.
2. Auto-deploy на staging.
3. End-to-end smoke втроём.
4. Договорённости на следующую неделю.

См. `playbooks/13-integration-day.md`.

### Правила Mode B

- ❌ Не менять общую зону (`shared/`, `core/`, `components/ui/`) в долгой ветке. Только Mode A через RFC-PR.
- ❌ Не делать ветку длиннее **2 недель**. Иначе финальный merge будет адом.
- ✅ `git rebase main` раз в 1-2 дня (для подтягивания мелких fixes).
- ✅ Contract test (`pytest tests/integration/test_contracts.py`) запускать регулярно.
- ✅ Перед финальным PR — выключить mock-режим, проверить на реальных зависимостях.

### Что выбирает Claude автоматически

Когда человек говорит «продолжаем» / «погнали»:
1. Прочитать план, найти текущую Feature.
2. Если Submodule **только начинается** или **ещё в разработке**, спросить: «Это часть длинного Submodule. Включить Mode B (длинная ветка + моки) или работать в Mode A (PR в main каждой Feature)?»
3. Действовать по выбору.

Если человек явно сказал «работаем в Mode B» / «уходим в свою пещеру» — переключиться без вопросов.

---

## 20. Контекст и память

- **Большой вывод (тесты, логи, git log, find)** — через `mcp__plugin_context-mode_context-mode__ctx_batch_execute` или `ctx_execute`, не через Bash напрямую. Так raw output не съедает контекст.
- **Память между сессиями** — `claude-mem:mem-search` («это уже решали?», «как делали в прошлый раз?»).
- **Документация библиотек** — `mcp__plugin_context7_context7__resolve-library-id` + `query-docs`. Не выдумывать API из памяти.

---

## Если правило конфликтует с запросом в чате

**Сначала уточнить у пользователя.** Не игнорировать правило молча. Не «обойти ради скорости».
