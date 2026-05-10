---
marp: true
theme: default
paginate: true
size: 16:9
header: 'VibecoSwaga · Шаблон для команды из 3 вайбкодеров'
style: |
  section { font-family: -apple-system, system-ui, sans-serif; }
  h1 { color: #0284c7; }
  h2 { color: #0369a1; }
  code { background: #f0f9ff; padding: 2px 6px; border-radius: 4px; }
  pre { background: #0c4a6e; color: #f0f9ff; }
  table { font-size: 0.85em; }
  .accent { color: #0284c7; font-weight: bold; }
  .muted { color: #64748b; font-size: 0.9em; }
---

# VibecoSwaga
## Шаблон для команды из 3 вайбкодеров

Параллельная разработка без слияния-конфликтов
и ручных git-команд

<br>

<span class="muted">Pitch для партнёров · 2026</span>

---

## Проблема

<br>

**3 вайбкодера** садятся пилить большой проект.

Через неделю:
- 🔥 Мерж не идёт — везде конфликты
- 🎨 Каждый сделал свой `Button` — UI разъехался
- 📋 Контракты API разошлись — фронт и бэк не стыкуются
- 🔄 Auth, схемы, layout — каждый изобрёл своё
- 🐛 Reflexion-чеков нет, баги копятся

**Проигрываем неделю на интеграцию вместо разработки.**

---

## Идея

<br>

**Шаблон-репозиторий**, который:

1. **Захватывает** идею проекта через intake-интервью с Claude
2. **Режет** на модули и распределяет по разработчикам
3. **Строит общий каркас** один раз перед расхождением
4. **Защищает границы** так, чтобы случайно не сломать чужое
5. **Автоматизирует git/gh** — никаких ручных команд

<br>

Каждый Dev говорит Claude **«погнали»** и кодит свой модуль.

---

## Старт за одну команду

<br>

```bash
# Создатель проекта
gh repo create my-project --template VibecoSwagaTemplate --clone
cd my-project && claude
> погнали
```

```bash
# Подключение второго / третьего
git clone <repo> && cd <project> && claude
> я второй разработчик, погнали
```

<br>

**Никаких npm, никаких CLI-обёрток.** GitHub template + git clone + Claude.

Claude **сам** распакует скелет, поставит зависимости, проведёт интервью, разрежет проект и зафиксирует контракты.

---

## 4-уровневая иерархия

<br>

```
Project ─▶ Module ─▶ Submodule ─▶ Feature ─▶ Sub-task
```

<br>

| Уровень | Что | Кто |
|---|---|---|
| **Project** | Весь репо, общая спека | Все вместе |
| **Module** | `Projects`, `Finances`, `AI` | Один Dev |
| **Submodule** | Логический кусок модуля | Owner |
| **Feature** | Один PR, один integration-тест | Owner |
| **Sub-task** | Атомарный TDD-цикл | Claude |

---

## Пример распределения

<br>

```
Dev #1  Тим    →  Module: Projects
Dev #2  Влад   →  Module: Finances
Dev #3  Стас   →  Modules: Profile + Logs + AI
```

<br>

Каждый владеет своим модулем целиком: модели, эндпоинты, страницы, тесты.

**Cross-module зависимости** явно прописаны. Если Finance нужно что-то от Profile — отдельный issue с label `cross-zone-request`.

---

## Project Foundation — общий каркас

<br>

**Делается ОДИН раз** перед расхождением по модулям.

Что в нём:
- 🏛 **Shared schemas** — `UserRead`, `ProjectRead` (публичные контракты)
- 🔑 **Auth-base** — login/logout, JWT, `get_current_user`
- 🎨 **Design tokens** + **shadcn UI kit** — Button, Input, Card, AppShell
- 🧩 **CRUD convention** — все эндпоинты по одному шаблону
- 🚀 **Docker Compose + CI зелёный**

<br>

Принцип **«займ-код минимум»**: только то, что используют все модули.

---

## Защита границ — 3 слоя

<br>

| Слой | Что делает | Когда срабатывает |
|---|---|---|
| 1️⃣ `DEVELOPER.local.md` | Claude знает свою/чужие зоны | Перед каждым Edit/Write |
| 2️⃣ `pre-commit` | Валит коммит в чужую зону | На `git commit` |
| 3️⃣ `CODEOWNERS` + branch protection | Блокирует merge без аппрува | На GitHub merge |

<br>

**Дополнительно**: `check-imports.sh` запрещает импорт приватных модулей друг у друга.

```python
✅ from app.profile.service import get_user_by_id
❌ from app.profile.models import User       # private
```

---

## Auto-pilot — никакого git/gh руками

<br>

8 русских фраз — всё остальное Claude делает сам.

| Фраза | Что Claude делает |
|---|---|
| `что у нас?` | git + gh статус, входящие, reflexion |
| `продолжаем` | следующая Feature через TDD |
| `отдавай` | pre-PR check + push + PR + auto-merge |
| `аппрув N` | `gh pr review --approve N` |
| `запроси у X Y` | cross-zone issue к коллеге |
| `откати последний` | `git revert HEAD` |
| `стоп` | прерви действие |
| `синк-апдейт` | сводка для созвона |

---

## Жёсткие правила (не отменяются auto-pilot'ом)

<br>

- 🐳 **Docker-only** — все тесты и запуски только в контейнерах
- 🧪 **TDD обязателен** — без integration-теста PR не создаётся
- 🛑 **Stop-rule** — после 3 фейлов: Context7, гипотеза, потом 4-я попытка
- 🪞 **Reflexion после мержа** — автоматическая критика крупных фич
- 🧠 **Superpowers конвейер** — `brainstorming → writing-plans → TDD → verification`
- 📜 **Контракты — святое** — RFC-PR с аппрувом всех

<br>

Всё прописано в `CLAUDE.md`. Claude не «забудет» и не «срежет угол».

---

## Рекурсивный планинг

<br>

Один и тот же цикл повторяется на каждом уровне:

```
Project init:    intake → spec → decompose → contracts → foundation
Module init:     intake → spec → decompose → contracts (RFC-PR)
Feature exec:    writing-plans → TDD по под-задачам → PR
```

<br>

**Грубый план сверху, детали — каждый сам для своего модуля.**
Claude не пытается фантазировать на маленьком intake.

---

## Что в коробке

<br>

- 📚 **10 плейбуков** для Claude (intake, spec, decompose, foundation, parallel-work, cross-zone, ci-debug, reflexion, …)
- 🤖 **6 агентов** (onboarding, foundation-builder, pr-checker, contracts-generator, conflict-resolver, reflexion-runner)
- 💻 **Reference**: FastAPI + Next.js 15 + Postgres + Docker + GitHub Actions
- 🧰 **Скрипты**: scaffold-module, claim-developer, check-boundaries, check-imports, gen-types
- 📖 **Onboarding** для людей: start-here, install, troubleshooting, glossary
- 📐 **CLAUDE.md** на 18 разделов — единый источник правды

---

## Day 0 — что человек реально делает

<br>

```
11:00  Тим: gh repo create + claude → погнали
11:00–12:30  Intake-интервью втроём (Claude задаёт вопросы)
12:30–13:30  Spec написан, апрувнут
14:00–15:00  Decompose: распределили модули, CODEOWNERS готов
15:00–17:00  Contracts + Foundation (auth + AppShell + UI kit)
─────────────────────────────────────────────
17:00  ✅ Каркас работает, CI зелёный.
       Влад и Стас делают git clone и → /module-init.
```

**За день** — от идеи до готовой основы для параллельной работы.

---

## Бонусы

<br>

- 🧠 **Память между сессиями** через `claude-mem` — Claude помнит решения
- 📚 **Context7** — актуальные доки библиотек, не выдумки LLM
- 🪞 **Reflexion** — после крупных фич автоматический ревью
- 🔄 **Auto-merge** — мерж сам, когда CI зелёный + аппрувы
- ⚡ **Scaffold** — `./scripts/scaffold-module.sh billing Subscription` за секунду создаёт модульный скелет

---

## Что дальше

<br>

1. ✅ Локальный шаблон готов (4 коммита, 110+ файлов)
2. 🚀 Push на GitHub как **template repository**
3. 🔬 Smoke-test на чистой машине: `gh repo create --template` → `claude` → проверить полный цикл
4. 🎯 **Первый реальный проект** — обкатать в бою
5. 📈 Доработка на основе live-фидбека

<br>

Готов запустить. Партнёры?

---

# 🤝

## Вопросы?

<br>

<span class="muted">github.com/timderbak/VibecoSwagaPlatform</span>
