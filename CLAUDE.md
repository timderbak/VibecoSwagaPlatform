# CLAUDE.md

Универсальные правила работы в репозиториях, созданных из VibecoSwagaTemplate. Читать до начала любой задачи.

---

## 0. Язык

- **Документация, комментарии в README, ADR, спецификации** — на русском.
- **Код, имена переменных, docstrings, git-коммиты, PR-описания, логи** — на английском.
- **Общение в чате с пользователем** — на русском.

---

## 1. Масштаб задачи определяет процесс

В этом репо иерархия 4 уровня:
```
Project → Module → Submodule → Feature → Sub-task
```
- **Project-level** (весь репо) — делается один раз вначале (intake → spec → decompose → contracts → skeleton).
- **Module-level** — каждый Dev #N делает мини-цикл для своего модуля (см. `playbooks/03b-module-decomposition.md`).
- **Feature-level** — конкретная фича из плана модуля (см. `playbooks/11-feature-execution.md`).
- **Sub-task** — атомарная TDD-итерация внутри Feature.

Перед любым действием классифицируй текущую задачу:

### Тривиальная Sub-task (≤ 10 строк, ≤ 2 файла, нет новой логики)
- Edit/Write напрямую.
- Скиллы и субагенты НЕ использовать.
- Примеры: переименовать переменную, добавить лог, поправить опечатку.

### Средняя Feature (один модуль, понятное решение, нет архитектурных вопросов)
- **Skip** `superpowers:brainstorming`.
- Обязательно: `superpowers:writing-plans` → `docs/specs/feature-<id>.md` → `superpowers:test-driven-development` по под-задачам → PR.

### Крупная Feature (архитектурные решения, state machine, новые контракты, cross-cutting)
Полный пайплайн:
1. `superpowers:brainstorming` — варианты, edge cases, риски.
2. `superpowers:writing-plans` — `docs/specs/feature-<id>.md` + план под-задач.
3. `superpowers:dispatching-parallel-agents` (если под-задачи независимы) или `superpowers:executing-plans`.
4. `superpowers:test-driven-development` по каждой под-задаче.
5. `superpowers:verification-before-completion`.

Если меняет публичный контракт — **отдельный RFC-PR** в общую зону (см. §17).

### Module init (новый модуль, ещё нет `docs/specs/module-<slug>.md`)
**Перед любыми features** в этом модуле — пройти `playbooks/03b-module-decomposition.md`:
1. Module intake (`brainstorming`) → `docs/intake-modules/<slug>.md`.
2. Module spec (`writing-plans`) → `docs/specs/module-<slug>.md`.
3. Module decompose → дополнить `docs/plan.md` Features внутри Submodules.
4. Module contracts → RFC-PR с Pydantic-моделями модуля.

Без этого нельзя начинать features. Project-level decompose даёт только Module/Submodule заголовки — Feature-уровень делает каждый Dev сам для своего модуля.

### При сомнениях
- Между тривиальной и средней — делать как среднюю.
- Между средней и крупной — **спросить пользователя**.
- Если фича в новом модуле — сначала module init (`03b`), потом фича.

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
- TDD цикл: RED → GREEN → REFACTOR → COMMIT.
- Агент `pr-checker` блокирует PR при отсутствии integration-теста на новые эндпоинты.
- После любой реализации — прогнать всю тестовую пачку. Красный тест = работа не завершена.

---

## 4. Business Flow обязателен

Для любого продукта в `docs/business-flows.md` должны быть описаны **реальные пользовательские сценарии от начала до конца**, а не просто список фич.

Каждая новая фича сверяется с business flow: как она встраивается в реальный путь пользователя.

---

## 5. Stop rule: три провала — стоп и читать доки

Если **три раза подряд** не можешь решить одну проблему (ошибка при том же шаге, неработающая интеграция, не находится API):

1. **Остановиться.** Не пробовать четвёртый раз наугад.
2. Найти официальную документацию через `mcp__plugin_context7_context7__resolve-library-id` + `query-docs`, или web-search.
3. Прочитать релевантный раздел целиком.
4. Сформулировать в чате: «Я застрял на X, прочитал Y, гипотеза Z».
5. **Только тогда** — новая попытка.

**В auto-pilot режиме (см. §16) ты обязан сам выйти из retry-цикла после 3-го фейла и позвать человека.** Бездумный retry loop — главный антипаттерн.

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

После имплементации крупной фичи запустить `reflexion:critique` **автоматически**.

В этом шаблоне это делает GitHub Action `.github/workflows/reflexion.yml` после мержа коммита `feat:` в main. Findings падают issues с тегом `reflexion-finding`, ассайнятся автору.

Reflexion **не блокирует мерж** — работает после.

---

## 9. Структура проекта

```
├── CLAUDE.md
├── README.md
├── DEVELOPER.local.md           # генерится claim-developer.sh, .gitignored
├── docker-compose.yml
├── docker-compose.test.yml
├── deploy.sh
├── .env.example
├── docs/
│   ├── business-flows.md
│   ├── tech-stack.md
│   ├── features.md
│   ├── architecture.md
│   ├── changelog.md
│   ├── intake.md                # из /intake
│   ├── plan.md                  # из /decompose
│   ├── contracts/               # Pydantic + сгенерённые OpenAPI/TS
│   ├── specs/                   # спеки крупных фич
│   └── onboarding/              # для людей
├── backend/                     # FastAPI
├── frontend/                    # Next.js
├── scripts/
└── .github/
    ├── CODEOWNERS               # из /decompose
    └── workflows/
```

Документация только в `docs/`. Код только в `backend/` и `frontend/`.

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
- Читает документацию через Context7, когда застрял.
- Обновляет `docs/` после крупных фич.
- Делает коммиты по подзадачам.
- Делает `git pull && rebase`, `git push`, `gh pr create`, `gh pr merge --auto` (см. §16).

**Claude спрашивает пользователя:**
- Перед выбором между архитектурными вариантами (на этапе brainstorm).
- После Reflexion — что из findings чинить.
- Перед изменением общих зон (контракты, core, ui, docker-compose).

---

## 14. Чек-лист перед сдачей крупной фичи

- [ ] Пройден полный пайплайн (brainstorming → writing-plans → executing/subagent-driven → verification).
- [ ] Все тесты зелёные в Docker.
- [ ] Integration-тесты покрывают все новые endpoint'ы.
- [ ] Impact на связанные модули проверен.
- [ ] `docs/` обновлены.
- [ ] Business flow обновлён, если нужно.
- [ ] Секреты не утекли в код.
- [ ] `deploy.sh` обновлён, если нужно.
- [ ] Reflexion запустится автоматически после мержа в main.

---

## 15. Multi-developer mode

В этом репо работают несколько вайбкодеров параллельно. Каждый — в своей зоне.

### Перед ЛЮБЫМ Edit/Write проверь путь файла против `DEVELOPER.local.md`:

- **Своя зона** (`Мои слайсы`) → пиши свободно.
- **Общая зона** (`Общие зоны (READ-ONLY)`) → НЕ пиши. Скажи: «нужен RFC-PR с аппрувом всех CODEOWNERS».
- **Чужая зона** (`Чужие зоны`) → НЕ пиши. Скажи: «это зона Dev #N, создаю cross-zone-issue» (через `gh issue create --label cross-zone-request --assignee <owner>`).

### Если `DEVELOPER.local.md` отсутствует
Не начинай работу. Запусти onboarding-агента (`.claude/agents/onboarding.md`) — он спросит у пользователя, кто из Dev #N, и сам выполнит `./scripts/claim-developer.sh <N> <name>`.

### Pre-commit hook
`scripts/check-boundaries.sh` валит коммит при попытке записи в чужую зону. **Не пытайся обойти `--no-verify`** — это запрещено §12.

### Cross-zone запрос
Если для своей фичи нужно что-то в чужой зоне — попроси Claude «запроси у <имя_овнера> <что>». Claude создаст GitHub-issue (`gh issue create --label cross-zone-request --assignee <owner>`). Жди, не делай сам.

---

## 16. Auto-pilot mode (никаких git-команд от человека)

Человек печатает короткие русские фразы. Ты выполняешь git/gh.

### Словарь команд

| Фраза человека | Действие (Claude выполняет напрямую через Bash/gh) |
|---|---|
| `что у нас?` | Сводный отчёт: `git status -sb`, `gh pr list --author @me --state open`, `gh issue list --label cross-zone-request --assignee @me`, `gh issue list --label reflexion-finding --assignee @me`, текущий WP из `docs/plan.md` |
| `продолжаем` | Следующий WP из `docs/plan.md` через TDD цикл |
| `отдавай` | Запуск агента `pr-checker`: pre-PR check → `git push` → `gh pr create` → `gh pr merge --auto --squash` |
| `аппрув N` | `gh pr review --approve <N>` |
| `стоп` | Прерви текущее действие, отчитайся |
| `откати последний` | `git revert HEAD` (БЕЗ force) |
| `запроси у <имя> <что>` | `gh issue create --title "[cross-zone] ..." --label cross-zone-request --assignee <owner>` (см. `playbooks/07-cross-zone.md`) |
| `синк-апдейт` | Агрегат через `gh` для еженедельного созвона (см. `.claude/commands/sync.md`) |

### Что Claude делает автоматически (без спроса)

- `git pull && git rebase main` — на старте сессии и перед PR.
- `git add && git commit` — после успешных тестов.
- `git push` — после каждого коммита в свою ветку.
- `gh pr create` + `gh pr merge --auto --squash` — на «отдавай» или после завершения WP. Использовать агента `.claude/agents/pr-checker.md`.
- Прогон тестов в Docker.
- Фикс CI-фейла — ≤3 попытки, потом stop-rule (§5).
- `Reflexion:critique` после мержа крупной фичи (через GitHub Action).

### Что Claude НЕ делает без человека

- Аппрув чужого PR (только по команде «аппрув N»).
- Force-push.
- Изменение `docs/contracts/` без RFC-PR (см. §17).
- Удаление чужой ветки.
- `gh pr merge` в обход auto-merge (только GitHub сам мержит).
- Изменение `CODEOWNERS` / branch protection.

### При красном CI
1. Анализируй вывод теста.
2. Гипотеза → фикс → запуск.
3. Если не помогло — ещё гипотеза → фикс → запуск.
4. Если не помогло третий раз — **СТОП**. Применяй §5 (Context7 + формулировка). Дальше зови человека.

---

## 17. Контракты, общая зона и cross-module reads — святое

### Что лежит в общей зоне

```
backend/app/shared/        ← публичные Pydantic Read-схемы (UserRead, ProjectRead, ...),
                             enum'ы (Role, ProjectStatus), общие типы (PaginatedResponse, ErrorResponse).
                             CODEOWNERS = ВСЕ. Менять только через RFC-PR.
backend/app/core/          ← config, db, base. CODEOWNERS = ВСЕ.
frontend/components/ui/    ← дизайн-система: Button, Input, Card, EmptyState, Skeleton, AppShell.
                             CODEOWNERS = ВСЕ. Все модули используют ТОЛЬКО эти компоненты.
frontend/components/layout/ ← AppShell с навигацией. CODEOWNERS = ВСЕ.
frontend/lib/api/          ← клиент API + автогенерённые TS-типы.
frontend/app/globals.css   ← design tokens (цвета, типографика). CODEOWNERS = ВСЕ.
tailwind.config.ts         ← токены. CODEOWNERS = ВСЕ.
```

### Owner / Readers модель для общих сущностей

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

`scripts/check-imports.sh` (часть pre-commit hook) валит коммит при попытке такого импорта.

### Когда менять общую зону

- На шаге `/contracts` (первичная фиксация после `/decompose`).
- На шаге `/module-init` (когда новый модуль публикует свои Read-схемы).
- Через **RFC-PR**: отдельный PR только с изменением общей зоны, тегаются все CODEOWNERS общей зоны, требуется аппрув всех.

### Если фича требует изменить контракт или общий компонент

Остановись и спроси пользователя:
> «Эта фича меняет публичную форму X в общей зоне (схема / UI-компонент / дизайн-токен). Создаём RFC-PR? (y/n)»

Если `y` — создай отдельный PR только с этим изменением, тегни всех CODEOWNERS общей зоны. Дождись мержа. Только тогда продолжай фичу.

### Никогда не меняй общую зону «попутно»

Даже если кажется маленьким. Один контракт / один UI-компонент = один RFC-PR.

### Cross-module запрос данных (для reader-модулей)

Если фича твоего модуля нуждается в данных другого модуля:

```python
# В backend/app/finances/service.py (Dev #2):
from app.profile.service import get_user_by_id    # public read
from app.shared.schemas import UserRead

async def calc_payout(user_id, db):
    user = await get_user_by_id(user_id, db)
    return UserRead.model_validate(user)
```

Если нужного метода в чужом сервисе нет — **cross-zone request** к owner'у:
> «запроси у Стаса добавить get_users_by_role в profile.service»

### Дизайн-конвенция (фронт)

- **Только токены, не хардкоды.** `bg-primary` ✅, `bg-[#0EA5E9]` ❌.
- **Только компоненты из `components/ui/`**, не свои Button/Input/Card. Если нужного нет — RFC-PR в общую зону.
- **AppShell** оборачивает все страницы (через `app/layout.tsx`). Менять навигацию (добавить/убрать ссылку на модуль) — RFC-PR.

### CRUD convention (бэк)

Все CRUD-эндпоинты пишутся по одному шаблону (см. `backend/app/profile/api.py` и `backend/app/projects/api.py` как референс):

```
POST   /<entity>           201, body, returns <Entity>Read
GET    /<entity>           PaginatedResponse[<Entity>Read]
GET    /<entity>/{id}      <Entity>Read | 404
PATCH  /<entity>/{id}      <Entity>Read | 404
DELETE /<entity>/{id}      204 | 404
```

Все ошибки → `ErrorResponse {code, message, details}`. Все списки → `PaginatedResponse {items, total, page, page_size}`.

Для быстрого старта нового модуля — `./scripts/scaffold-module.sh <module> <Entity>` создаёт скелет (models / service / api / routes).

---

## 18. Onboarding на старте сессии

При запуске Claude в репозитории, созданном из шаблона:

### Если это первый запуск (нет `.claude/.session-started`)
SessionStart-hook запускает агента `onboarding`. Он:

- Представляется.
- Если есть `DEVELOPER.local.md` — показывает роль («Ты Dev #N, твоя зона — X»).
- Если нет — предлагает `./scripts/claim-developer.sh N <name>` или сообщает «не вижу claim, ты создатель проекта?».
- Показывает статус ветки и открытых PR'ов.
- Спрашивает «что делаем».
- Создаёт `.claude/.session-started`.

### Если репо новый (нет `docs/spec.md`)
Не предлагай WP. Запусти конвейер:

1. Сначала `superpowers:brainstorming` для intake.
2. Потом `superpowers:writing-plans` для spec + plan.
3. Потом `/decompose` для распределения на N девов.
4. Потом `/contracts` для фиксации Pydantic-моделей.
5. Потом `/skeleton` для каркаса с зелёным CI.

Следуй `playbooks/01..05` шаг за шагом.

---

## Если правило конфликтует с запросом в чате

**Сначала уточнить у пользователя.** Не игнорировать правило молча. Не «обойти ради скорости».
