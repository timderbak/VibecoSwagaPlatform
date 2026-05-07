# VibecoSwagaTemplate — Design Specification

**Дата:** 2026-05-07
**Автор:** Claude (брейнсторм с Тимом)
**Статус:** черновик, ожидает ревью

---

## 1. Цель

Создать **шаблон-репозиторий** `VibecoSwagaTemplate` и **CLI-обёртку `vibeco`**, которые позволяют команде из 3 вайбкодеров за минуты запускать новый проект и параллельно его разрабатывать **без слияния-конфликтов, разъезда дизайна и накопления тех-долга**, при этом не запоминая команд git/gh.

**Идеальный пользовательский опыт:**

```
git clone <new-project>     # один раз
claude                      # запуск
> погнали                   # одна фраза
```

Дальше человек только **надиктовывает идею фич**. Всё остальное — Claude: декомпозиция, контракты, скелет, тесты, коммиты, PR, мерж, Reflexion.

## 2. Целевая аудитория

3 вайбкодера команды SwagaSec (Тим — фаундер + Dev #1, плюс ещё двое). Beta-разработчики: знают код, не любят инфра-накладные расходы, ценят скорость и автономность.

## 3. Не цели (out of scope)

- Поддержка более чем одного эталонного стека на старте (FastAPI+Next.js достаточно).
- Замена GitHub другими VCS-хостингами (GitLab/Gitea — позже).
- Поддержка команд > 5 человек (CODEOWNERS-схема не масштабируется без иерархии).
- Микросервисы/мульти-репо.
- Замена SwagaSec Platform — это отдельный продукт, VibecoSwaga только инструмент для **новых** проектов.

## 4. Принципы дизайна

1. **Одна команда на старте.** `vibeco init` или `vibeco join` — больше человек ничего не печатает руками.
2. **Auto-pilot git/gh.** Человек никогда не пишет git/gh-команды напрямую.
3. **Контракты как код.** `docs/contracts/` — не markdown, а исполнимый Pydantic + сгенерённый OpenAPI/TS.
4. **Vertical slices с владельцами.** Каждая фича — UI+API+DB+тесты в одном слайсе, владелец один человек.
5. **3 слоя защиты границ.** `DEVELOPER.local.md` (Claude), pre-commit hook (git), CODEOWNERS (GitHub merge).
6. **Все инструкции в репе.** Claude никогда не «придумывает» поведение — читает CLAUDE.md/playbooks.
7. **Дисциплина важнее скорости.** TDD, stop-rule после 3 фейлов, Superpowers конвейер, Reflexion после фич — обязательны и в auto-pilot.
8. **Гибрид: универсальное ядро + эталонная имплементация.** Плейбуки работают на любом стеке; `reference/` — готовый FastAPI+Next.js.

## 5. Архитектура шаблон-репо

```
VibecoSwagaTemplate/
├── README.md                           # для людей: одна команда start
├── CLAUDE.md                           # для Claude: все правила
├── DEVELOPER.local.md.example          # шаблон файла «я Dev #N»
├── .claude-plugins.json                # список плагинов для автоустановки
│
├── .claude/
│   ├── settings.json                   # SessionStart hook + permissions
│   ├── commands/                       # /intake /spec /decompose /contracts /skeleton /claim /status /sync /pr
│   └── agents/                         # onboarding, contracts-generator, skeleton-generator, pr-checker, conflict-resolver, reflexion-runner
│
├── playbooks/                          # УНИВЕРСАЛЬНОЕ ЯДРО (стек-агностичное)
│   ├── 01-intake.md                    # как вести интервью
│   ├── 02-spec.md                      # шаблон спеки + чек-лист
│   ├── 03-decomposition.md             # эвристика vertical slices
│   ├── 04-contracts.md                 # Pydantic→OpenAPI→TS
│   ├── 05-skeleton.md                  # как собрать каркас с зелёным CI
│   ├── 06-parallel-work.md             # auto-pilot цикл, словарь команд
│   ├── 07-cross-zone.md                # как делать request-cross-zone
│   ├── 08-merge-conflict.md            # rebase-конфликт
│   ├── 09-ci-debug.md                  # типовые причины красного CI + Context7
│   └── 10-reflexion.md                 # как запустить Reflexion и интерпретировать findings
│
├── reference/                          # ЭТАЛОННАЯ ИМПЛЕМЕНТАЦИЯ (FastAPI+Next.js)
│   ├── backend/
│   │   ├── app/{core,schemas,api,models,main.py}
│   │   ├── alembic/
│   │   ├── tests/
│   │   ├── pyproject.toml              # ruff line=100, py312, pytest-asyncio
│   │   └── Dockerfile
│   ├── frontend/
│   │   ├── app/                        # Next.js App Router
│   │   ├── components/ui/              # дизайн-система (общая зона)
│   │   ├── lib/api/                    # автогенерённый TS-клиент
│   │   ├── package.json
│   │   └── Dockerfile
│   ├── docker-compose.yml
│   ├── docker-compose.test.yml
│   ├── deploy.sh
│   ├── .env.example
│   └── .github/
│       ├── CODEOWNERS                  # шаблон, заполняется на /decompose
│       └── workflows/{ci,auto-merge,reflexion}.yml
│
├── docs/
│   ├── onboarding/                     # ДЛЯ ЛЮДЕЙ
│   │   ├── start-here.md               # 1 экран
│   │   ├── install.md                  # на случай поломки автоустановки
│   │   ├── troubleshooting.md
│   │   └── glossary.md
│   └── (templates: business-flows, tech-stack, features, architecture, changelog, specs/)
│
├── scripts/
│   ├── init-project.sh                 # fastapi|blank — распаковывает reference/
│   ├── claim-developer.sh              # N name — генерит DEVELOPER.local.md, ставит pre-commit
│   └── check-boundaries.sh             # pre-commit hook
│
└── cli/                                # vibeco — npm-пакет
    ├── package.json                    # @vibecoswaga/cli
    ├── bin/vibeco
    └── src/{init,join,status,pr,request-cross-zone,sync-summary,reflect}.js
```

## 6. CLI `vibeco`

Глобальный npm-пакет `@vibecoswaga/cli`. Установка один раз:

```bash
npm i -g @vibecoswaga/cli
```

### Команды

| Команда | Что делает |
|---|---|
| `vibeco init <name>` | Создаёт GitHub-репо из шаблона, клонит, ставит Claude+плагины, копирует reference, пушит первый коммит, запускает claude. ~2 минуты. |
| `vibeco join <repo-url>` | Клонит репо, ставит окружение, читает `docs/plan.md`, спрашивает «кто из них ты?», запускает `claim-developer`, создаёт ветку `dev/N/<slice>`, ставит pre-commit, запускает claude. ~1 минута. |
| `vibeco status` | Локальный summary: ветка, незакоммиченные изменения, открытые PR'ы, входящие cross-zone-запросы, reflexion findings. |
| `vibeco pr` | Pre-PR check (тесты, контракты, rebase) → push → `gh pr create` → `gh pr merge --auto`. |
| `vibeco request-cross-zone <path> <reason>` | Создаёт GitHub-issue с тегом ответственного. |
| `vibeco sync-summary` | Агрегирует статус всех веток для еженедельного созвона. |
| `vibeco reflect <commit>` | Headless Claude с `reflexion:critique` на дельту коммита (вызывается из GitHub Action). |

## 7. Onboarding workflow

### Создание нового проекта (Тим)

1. `vibeco init swagasec-jarvis-v2`
2. Открывается Claude. SessionStart-hook запускает агент `onboarding`:
   > «Привет! У нас пустой репозиторий. Расскажи, что строим?»
3. Тим описывает идею в свободной форме.
4. Claude автоматически идёт по конвейеру (через Superpowers + кастомные команды):
   - `superpowers:brainstorming` → `docs/intake.md`
   - `superpowers:writing-plans` (часть про spec) → `docs/specs/<topic>.md`
   - `/decompose` → `docs/plan.md` + `.github/CODEOWNERS`
   - `/contracts` → Pydantic + Alembic + OpenAPI + TS-types
   - `/skeleton` → stub'ы с раскраской CI

### Подключение второго/третьего разработчика (Влад / Стас)

1. `vibeco join git@github.com:tim/swagasec-jarvis-v2.git`
2. Claude в onboarding: «Ты Dev #2 (Влад). Твоя зона — биллинг. Готов начать?»
3. «Да» → Claude предлагает первый WP из плана через TDD.

## 8. Auto-pilot контракт

### Что Claude делает автоматически

- `git pull && rebase main` (на старте сессии и перед PR)
- `git add && commit` (после успешных тестов в Docker)
- `git push`
- `gh pr create` + `gh pr merge --auto --squash`
- Прогон тестов в Docker
- Фикс CI-фейла (≤3 попытки, потом Context7 + остановка)
- `vibeco request-cross-zone` (когда нужно тронуть чужую зону)
- `Reflexion:critique` после мержа крупной фичи

### Что Claude НЕ делает без человека

- Аппрув чужого PR (только по команде «аппрув N»)
- Force-push
- Изменение `docs/contracts/` без всеобщего консенсуса (RFC-PR)
- Удаление чужой ветки
- `gh pr merge` в обход auto-merge
- Изменение `CODEOWNERS` / branch protection

### Словарь команд человека → действия

| Фраза человека | Действие Claude |
|---|---|
| «что у нас?» | `vibeco status` + сводный отчёт |
| «продолжаем» | Следующий WP из плана через TDD |
| «отдавай» | `vibeco pr` |
| «аппрув N» | `gh pr review --approve <N>` |
| «стоп» | Прерви текущее действие |
| «откати последний» | `git revert HEAD` |
| «запроси у X Y» | `vibeco request-cross-zone` |
| «синк-апдейт» | `vibeco sync-summary` |

## 9. Защита границ — 3 слоя

### Слой 1: `DEVELOPER.local.md`

Локальный файл (в `.gitignore`), генерится `claim-developer.sh`. Содержит:

- **Свою зону** (READ+WRITE) — пути из `docs/plan.md`
- **Общую зону** (READ-ONLY, через RFC-PR) — `docs/contracts/`, `core/`, `components/ui/`, `docker-compose*.yml`
- **Чужие зоны** (NO-GO) — слайсы других девов

CLAUDE.md шаблона предписывает: **перед каждым Edit/Write проверь путь**.

### Слой 2: pre-commit hook `scripts/check-boundaries.sh`

Парсит `DEVELOPER.local.md`, валит коммит при попытке записи в чужую зону. `--no-verify` запрещён правилами CLAUDE.md.

### Слой 3: `.github/CODEOWNERS` + branch protection

Генерится автоматически на `/decompose`. Branch protection «Require review from Code Owners» включается в `vibeco init`. GitHub физически не даст мерж без аппрува овнера.

## 10. Контракты

### Что такое контракт

Pydantic-модель в `backend/app/schemas/<slice>.py`. Из неё:

- FastAPI генерит OpenAPI-схему автоматически
- Скрипт `scripts/gen-types.sh` генерит TS-типы в `frontend/lib/api/types.ts`
- Опционально — мок-сервер для фронта (через Prism CLI)

### Жизненный цикл

1. На шаге `/contracts` Claude пишет все Pydantic-модели + Alembic-миграцию + регенерит TS.
2. Эндпоинты создаются с `raise NotImplementedError`.
3. Один коммит: `feat: define contracts`.
4. Начиная с этого момента **изменения контрактов — только через RFC-PR с аппрувом всех CODEOWNERS общей зоны**.

## 11. Vertical slices: как режем

### Эвристика декомпозиции (`playbooks/03-decomposition.md`)

1. Из спеки выделить **главные сущности** (User, Project, Subscription, ...).
2. Каждой сущности соответствует слайс: `<entity>` модуль с CRUD + бизнес-логикой + UI + тестами.
3. Слайсы балансируются по объёму между девами (по числу эндпоинтов / страниц).
4. **Общая зона** (`core/`, `schemas/`, `components/ui/`) — на всех.
5. Если слайс слишком большой — режем на под-слайсы (например, `billing` → `billing.subscriptions` + `billing.invoices` + `billing.webhooks`).

### Пример распределения

```
Dev #1 (Тим): projects, users
Dev #2 (Влад): billing.subscriptions, billing.invoices
Dev #3 (Стас): auth, billing.webhooks
Общая (все): core/, schemas/, components/ui/, docker-compose
```

Файл `docs/plan.md` фиксирует это в формате, который читают и Claude, и `claim-developer.sh`.

## 12. CLAUDE.md шаблона

База — `CLAUDE.md` из SwagaSec Platform **без изменений** (§§1-14):

- §1 классификация задач (мелкая/средняя/крупная)
- §2 Docker-only
- §3 integration-тесты
- §4 business flow
- §5 stop-rule
- §6 impact analysis
- §7 docs после крупных
- §8 Reflexion
- §9 структура проекта
- §10 deploy.sh
- §11 секреты
- §12 git-гигиена
- §13 автономность
- §14 чек-лист крупной фичи

**Новые разделы для VibecoSwaga:**

- §15 Multi-developer mode (DEVELOPER.local.md, перед Edit/Write проверь путь)
- §16 Auto-pilot mode (словарь команд → действия, никаких git руками)
- §17 Контракты — святое (только через RFC-PR)
- §18 Onboarding на старте сессии (SessionStart hook агент)

Также в §1 расширяется маппинг «уровень задачи → какие Superpowers скиллы вызывать»; в §5 явно прописано, что в auto-pilot после 3-го фейла Claude **сам** выходит из retry-цикла и зовёт человека.

## 13. Жёсткие правила (наследие SwagaSec, не отменяются auto-pilot'ом)

| Правило | Реализация в шаблоне |
|---|---|
| TDD цикл при каждом WP | `superpowers:test-driven-development` обязателен; `vibeco pr` блокирует PR без integration-теста |
| Stop-rule + Context7 | После 3 фейлов — `mcp__plugin_context7_context7__query-docs`; формулировка гипотезы в чат |
| Superpowers по уровню | Мелкая — без скилов; средняя — `writing-plans`+TDD; крупная — `brainstorming`→`writing-plans`→`executing-plans`/`subagent-driven-development`→`verification-before-completion` |
| Субагенты для крупных | `superpowers:dispatching-parallel-agents` для независимых WP |
| Reflexion после мержа | `.github/workflows/reflexion.yml` запускает `reflexion:critique` на коммитах `feat:` в main |

## 14. GitHub workflows

- **`ci.yml`** — на PR: lint (ruff, eslint), tests (pytest in docker, jest), build. Должно быть зелёное для auto-merge.
- **`auto-merge.yml`** — следит за статусом PR, автоматически добавляет тег `automerge` при создании, если включён auto-merge режим. (По факту GitHub auto-merge native — этот workflow только для UI/удобства.)
- **`reflexion.yml`** — на push в main: если коммит `feat:` — запускает `vibeco reflect <sha>`, выкидывает findings issues с ассайном автору.

## 15. Что предустановлено в Claude

`.claude-plugins.json`:

```json
{
  "plugins": [
    "superpowers",
    "claude-mem",
    "context7",
    "reflexion",
    "github"
  ]
}
```

`vibeco init` устанавливает их через `claude plugin install`. Если автоустановка не сработала — `docs/onboarding/install.md` даёт пошаговую инструкцию.

## 16. Тестирование самого шаблона

Перед публикацией:

1. Прогнать `vibeco init test-project` на чистой машине → должно завершиться зелёным CI.
2. Прогнать `vibeco join` от двух фейковых девов → проверить границы, pre-commit, CODEOWNERS.
3. Сделать одну реальную фичу втроём (тестовый «hello world» с auth + один CRUD-эндпоинт + UI-страница) — убедиться что мерж в main происходит без ручного вмешательства.

## 17. План имплементации (high-level)

Детальный план — через `superpowers:writing-plans`. Высокоуровневые этапы:

1. **Skeleton шаблон-репо** — структура папок, CLAUDE.md, README, базовые playbooks.
2. **Scripts** — init-project.sh, claim-developer.sh, check-boundaries.sh.
3. **`.claude/`** — settings.json, commands, agents.
4. **`reference/backend`** — FastAPI с примером /health и /users.
5. **`reference/frontend`** — Next.js с примером /login.
6. **`reference/.github`** — workflows.
7. **`vibeco` CLI** — npm-пакет.
8. **`docs/onboarding`** — для людей.
9. **End-to-end тест** на чистой машине.
10. **Публикация** на GitHub как template-repo + npm publish.

## 18. Открытые вопросы / решения по умолчанию

| Вопрос | Дефолт |
|---|---|
| Где публиковать `@vibecoswaga/cli`? | npm public; имя организации `vibecoswaga` (нужно зарегистрировать). |
| Какая лицензия шаблона? | MIT (для будущей публичности). |
| Что делать с языком по умолчанию (RU vs EN в чате)? | RU в чате, EN в коммитах/коде — наследие SwagaSec. |
| Поддержка > 3 разработчиков? | Не блокировать архитектурно, но `claim-developer.sh` оптимизирован под 3-5; CODEOWNERS схема ломается на 8+. |
| Поддержка не-FastAPI стеков? | Только через `vibeco init <name> --stack blank` — копируются playbooks без reference. Полноценный второй reference (например, gRPC+Go) — отдельный feature request. |

---

## Приложение A — Маппинг секций брейнсторма к разделам спеки

| Брейнсторм | Спека |
|---|---|
| Секция 1 (структура) | §5 |
| Секция 2 (vibeco init/join, никаких слэшей) | §6, §7 |
| Секция 3 (3-слойная защита) | §9 |
| Секция 4 (auto-pilot) | §8 |
| Секция 5 (содержимое шаблона) | §5, §12, §15 |
| Секция 5.1 (жёсткие правила) | §13 |
