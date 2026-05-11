# CLAUDE.md

Универсальные правила работы в репозиториях, созданных из VibecoSwagaTemplate.

Шаблон **не пишет своих скиллов и слэш-команд**. Workflow держится на двух плагинах:
- **GSD** — фазовая структура проекта в `.planning/` (карта проекта).
- **superpowers** — дисциплина одной задачи (TDD, brainstorming, writing-plans).

Дополнительно: `frontend-design` для дизайн-системы, `claude-mem` для памяти, `context7` для свежих доков, `context-mode` для больших выводов, `github` для git-операций.

---

## 0. Язык

- Документация, ADR, спецификации — на русском.
- Код, имена, docstrings, git-коммиты, PR-описания, логи — на английском.
- Чат с пользователем — на русском.

---

## 1. Жирный init — всегда первым

В новом репозитории (нет `.planning/PROJECT.md` или он пустой) — **никаких фич, пока init не закончен**. Init = одна большая GSD-фаза «Foundation», которая на выходе даёт всё, что нужно команде, чтобы дальше каждый автономно кодил свой модуль.

### Что делает Claude сам в свежем репо

Пользователь только клонирует и описывает идею. **Никаких ручных команд от него не ждать.**

> ⚠️ **КРИТИЧНО: brainstorming НЕ перехватывает init**
>
> Если `.planning/PROJECT.md` отсутствует или пуст — описание продукта от пользователя обрабатывается **только через `/gsd-new-project`**.
>
> ❌ Не вызывать `superpowers:brainstorming` на первое описание продукта, даже если оно звучит как «опиши/обсуди/набросаем фичу». В пустом репо это инициация, а не creative work.
> ❌ Не писать спеку продукта в `docs/superpowers/specs/` — она должна быть в `.planning/PROJECT.md`.
> ✅ Сначала `/gsd-new-project` → `.planning/PROJECT.md` + `ROADMAP.md`. Только после этого `brainstorming` снова доступен для отдельных фич.
>
> Это override приоритет: правила CLAUDE.md выше скилл-описаний superpowers.

В первой сессии Claude:
1. Видит `reference/` и нет `backend/` → сам выполняет `./scripts/init-project.sh fastapi` (или `blank`, если человек явно сказал «свой стек»).
2. Видит пустой/отсутствующий `.planning/PROJECT.md` → запускает `gsd-new-project` для интервью. Опирается на то, что человек уже сказал в чате — не задаёт повторно вопросы, на которые ответ известен.
3. После интервью идёт по «Порядку init» ниже **без подтверждений** — только финальный PR требует «отдавай».
4. Если плагины не установлены (нет `superpowers`, `gsd`, `frontend-design`, `claude-mem`, `reflexion`, `context-mode`, `context7`, `github`) — выводит **один раз** список команд установки из `README §1` и продолжает работу. Не блокирует, но напоминает.

### Порядок init

1. **`gsd-new-project`** — глубокое интервью, создаёт:
   - `.planning/PROJECT.md` — что за продукт, ценность, аудитория, технические ограничения.
   - `.planning/ROADMAP.md` — milestones, первая фаза = «Foundation».
2. **`docs/business-flows.md`** — хотя бы один сквозной пользовательский путь (golden path).
3. **`DEVELOPERS.md`** — кто dev1/dev2/dev3, какие модули каждого. Это **единственное** назначение файла: распределение задач. Никаких pre-commit hooks, никакого CODEOWNERS, никакого формального enforcement.
4. **`gsd-spec-phase`** для фазы Foundation → `.planning/phases/<date>-foundation/SPEC.md` с явным списком: дизайн-система, shared контракты, auth-base, AppShell.
5. **`gsd-plan-phase`** → `PLAN.md` с задачами Foundation.
6. **`gsd-execute-phase`** делает Foundation:
   - **Дизайн-система** через `frontend-design` (палитра, типографика, design tokens в `tailwind.config.ts` + `globals.css`, базовые компоненты Button/Input/Card/EmptyState/Skeleton в `frontend/components/ui/`). Делается **до** того, как кодеры разойдутся — иначе каждый напишет свой Button.
   - **Shared контракты** (см. `playbooks/04-contracts.md`): `UserRead`, базовые типы, enum'ы.
   - **Auth-base** в `backend/app/profile/`: модель User, bcrypt, JWT-зависимость, login/me-эндпоинты.
   - **AppShell** в `frontend/components/layout/`.
7. **Один большой PR «foundation готов»**. После мержа каждый Dev клонирует, читает свою строку в `DEVELOPERS.md` и сразу идёт в свой модуль.

Init не пропускается, не ускоряется, не разбивается на много мелких PR. Это инвестиция, которая окупается тем, что потом никто не блокирует никого.

---

## 2. После init — каждый автономно

Каждый Dev читает свою строку в `DEVELOPERS.md`, идёт в свой модуль и работает там без согласований.

### Для модуля
1. `gsd-new-milestone` (если модуль = новый milestone) **или** `gsd-spec-phase` сразу для модуля.
2. `gsd-plan-phase` — план модуля.
3. `./scripts/scaffold-module.sh <module> <Entity>` — каркас файлов.
4. Дальше фичи.

### Для фичи внутри модуля
- **Тривиальная** (≤ 10 строк, ≤ 2 файла, переименовать/добавить лог) — Edit/Write напрямую, без скиллов.
- **Обычная фича** — два пути на выбор:
  - **GSD-путь** (если хочешь артефакты в `.planning/phases/`): `gsd-spec-phase` → `gsd-plan-phase` → `gsd-execute-phase`. Внутри execute Claude сам берёт `superpowers:test-driven-development` для бизнес-логики, `brainstorming` если развилка.
  - **Прямой путь** (если фича умещается в одну сессию): `superpowers:writing-plans` → `superpowers:test-driven-development` → PR.
- **PR + auto-merge** когда фича готова. Verification-skill и code-review skill — опциональны. **`reflexion:critique` после крупной фичи — обязательно**, см. §4a.

### Когда какой путь
- Артефакт нужен в `.planning/` (можно паузить, возобновить, передать) — GSD.
- Локальная задача за одну сессию — superpowers напрямую.
- Совсем мелкое — Edit без всего.

---

## 3. Docker — единственная среда выполнения

- Все тесты, запуски, проверки — только в Docker-контейнерах. Локально не запускать.
- Поменял код — сам пересобери/перезапусти контейнер. Не проси пользователя.
- `docker compose` предпочтительнее одиночных `docker run`.
- Тестовый стенд — `docker-compose.test.yml` с изолированной БД.

---

## 4. Тесты

- Проекты с HTTP API: на каждый endpoint — integration-тест в Docker с реальной БД (не mock). Минимум для CRUD: `create → get → verify`.
- Тесты пишутся вместе с кодом, не после.
- TDD цикл: RED → GREEN → REFACTOR → COMMIT.
- Красный тест = работа не завершена.

---

## 4a. Reflexion после крупной фичи — обязательно

После имплементации крупной фичи (см. определение в §1) запустить `reflexion:critique` **автоматически**. Пройтись по findings вместе с пользователем — что чинить сейчас, что в issue, что игнорировать.

Это не блокирует merge, но **не пропускается**. Reflexion — единственная обязательная проверка качества в шаблоне; verification skill и code review остаются опциональными.

---

## 5. Stop rule: три провала — стоп и читать доки

Если три раза подряд не можешь решить одну проблему:
1. Остановись. Не пробуй четвёртый раз наугад.
2. **Архитектурная проблема** (что выбрать, как масштабировать, где узкое место) → сначала `docs/system-design-patterns.md` (шпаргалка по Alex Xu, Vol. 1), потом `context7` если нужны детали.
3. **Баг библиотеки** → `mcp__plugin_context7_context7__resolve-library-id` + `query-docs`, или `superpowers:systematic-debugging`.
4. Сформулируй в чате: «застрял на X, прочитал Y, гипотеза Z».

В auto-pilot режиме — сам выходи из retry-цикла после 3-го фейла и зови человека.

---

## 6. Документация после крупных изменений

После завершения крупной фичи обновить:
- `docs/tech-stack.md` — стек, версии.
- `docs/features.md` — реализованные фичи.
- `docs/changelog.md` — что изменилось, дата.
- `docs/architecture.md` — если поменялась архитектура.

---

## 7. Структура проекта

```
├── CLAUDE.md, README.md
├── DEVELOPERS.md                # кто за какой модуль
├── docker-compose.yml, docker-compose.test.yml, deploy.sh, .env.example
├── .claude-plugins.json
├── .planning/                   # GSD
│   ├── PROJECT.md, ROADMAP.md
│   └── phases/<date>-<slug>/{SPEC,PLAN,REVIEW,VERIFICATION}.md
├── docs/                        # business-flows, tech-stack, features, architecture, changelog
├── backend/, frontend/
├── playbooks/04-contracts.md    # единственный survived playbook — shared zone
└── scripts/init-project.sh, scaffold-module.sh
```

---

## 8. Секреты, конфиги, git

- Никогда не хардкодить секреты. Всё через `.env` + `.env.example`. `.env` в `.gitignore`.
- Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`. На английском, императив.
- Никаких `--no-verify`, `--force` без явной просьбы пользователя.
- Коммит после каждой завершённой подзадачи.

---

## 9. Auto-pilot mode

Человек печатает короткие русские фразы — Claude выполняет git/gh.

| Фраза | Действие |
|---|---|
| `что у нас?` | `gsd-progress` (ветка, PR'ы, текущая фаза) |
| `продолжаем` | следующая задача из текущей фазы (`gsd-execute-phase` или TDD напрямую) |
| `отдавай` | `git push` → `gh pr create` → `gh pr merge --auto --squash` |
| `стоп` | прерви действие, отчитайся |
| `откати последний` | `git revert HEAD`; для отката фазы — `gsd-undo` |
| `запроси у X Y` | `gh issue create --title "[<module>] ..." --assignee <owner>` |

### Что Claude делает сам
- `git pull && git rebase main` — на старте сессии и перед PR.
- `git add && git commit` — после успешных тестов.
- `git push`, `gh pr create`, `gh pr merge --auto --squash` — на «отдавай».
- Прогон тестов в Docker.
- Фикс CI-фейла — ≤3 попытки, потом stop-rule (§5).

### Cross-approve между кодерами не используется
Каждый автономно мержит свои PR через auto-merge. Никаких «аппрув N». Команда вайб-кодеров не блокирует друг друга на ревью.

---

## 10. Контракты и общая зона

### Что в общей зоне
```
backend/app/shared/        ← публичные Pydantic Read-схемы, enums, базовые типы
backend/app/core/          ← config, db, auth utilities
frontend/components/ui/    ← Button, Input, Card, EmptyState, Skeleton
frontend/components/layout/ ← AppShell
frontend/lib/api/          ← API-клиент, TS-типы
tailwind.config.ts, frontend/app/globals.css ← design tokens
```

### Owner / Readers модель
Каждая публичная сущность в `backend/app/shared/schemas.py` имеет одного **owner-модуля** (делает CRUD + БД-модель) и любое число **reader-модулей** (только читают через публичный сервис другого модуля).

### Правила импортов между модулями
```python
# ✅ РАЗРЕШЕНО:
from app.shared.schemas import UserRead       # public schema
from app.shared.enums import Role             # public enum
from app.profile.service import get_user_by_id  # public service другого модуля
from app.core.db import get_db                # core utility

# ❌ ЗАПРЕЩЕНО (нарушает инкапсуляцию):
from app.profile.models import User           # private model
from app.profile._password import hash_password  # private util (_xxx)
from app.profile.api import router            # api.* — только в main.py
```

Без pre-commit hook'а — это просто правило, которое все знают и соблюдают.

### Изменение общей зоны

**Защита = качество init-документации**, а не процесс. На Foundation-фазе зафиксированы: зоны, owner'ы, публичные схемы, cross-module карта, API-конвенции. Все следуют этому документу.

Если кто-то всё же поменял общую зону «попутно» — не катастрофа, поправим вместе в следующей итерации. Никаких pre-commit hooks, никаких обязательных аппрувов, никаких сообщений в чат. Принимаем риск — выбираем скорость.

Принцип гигиены: одна осмысленная единица изменения = один PR (не смешивать с фичей).

### Дизайн-конвенция (фронт)
- Только токены, не хардкоды. `bg-primary` ✅, `bg-[#0EA5E9]` ❌.
- Только компоненты из `components/ui/`. Если нужного нет — добавь.
- AppShell оборачивает все страницы (`app/layout.tsx`).
- Для новой UI — `frontend-design`. Не пиши Tailwind «на глаз».

### CRUD convention (бэк)
```
POST   /<entity>           201, returns <Entity>Read
GET    /<entity>           PaginatedResponse[<Entity>Read]
GET    /<entity>/{id}      <Entity>Read | 404
PATCH  /<entity>/{id}      <Entity>Read | 404
DELETE /<entity>/{id}      204 | 404
```
Все ошибки → `ErrorResponse {code, message, details}`. Все списки → `PaginatedResponse {items, total, page, page_size}`.

Скаффолд нового модуля — `./scripts/scaffold-module.sh <module> <Entity>`.

---

## 11. Контекст и память

- **Большой вывод (тесты, логи, git log, find)** — через `mcp__plugin_context-mode_context-mode__ctx_batch_execute` или `ctx_execute`, не через Bash напрямую.
- **Память между сессиями** — `claude-mem:mem-search` («это уже решали?»).
- **Документация библиотек** — `mcp__plugin_context7_context7__resolve-library-id` + `query-docs`. Не выдумывать API из памяти.

---

## Если правило конфликтует с запросом

Сначала уточнить у пользователя. Не игнорировать молча. Не «обходить ради скорости».
