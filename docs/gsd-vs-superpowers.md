# GSD vs superpowers — как они сосуществуют

Шаблон держится на двух плагинах с пересекающейся функциональностью.
У обоих есть «спека», «план» и «исполнение», и это сбивает с толку.
Этот документ объясняет, кто за что отвечает и как они работают вместе.

> Аудитория: Claude Code и разработчики, которым нужно понять,
> когда вызывать GSD-команду, а когда — superpowers-скилл.

---

## TL;DR

- **GSD = карта проекта.** Макро-уровень. Фазы, milestones, артефакты в `.planning/`.
- **superpowers = инструменты на задачу.** Микро-уровень. TDD, debugging, brainstorming, plan-execute.
- **Они не конкурируют.** GSD сверху, superpowers внутри. `gsd-execute-phase` под капотом сам активирует TDD/debugging/verification.
- **superpowers без GSD** — для задач, которые умещаются в одну сессию и не требуют артефакта в `.planning/`.

---

## Параллельные функции — где пересечение

| Функция | GSD | superpowers |
|---|---|---|
| Спека | `gsd-spec-phase` → `.planning/phases/<phase>/SPEC.md` | `brainstorming` → `docs/superpowers/specs/<date>-<topic>-design.md` |
| План | `gsd-plan-phase` → `PLAN.md` рядом со SPEC.md | `writing-plans` → `docs/superpowers/plans/<date>-<topic>-plan.md` |
| Исполнение | `gsd-execute-phase` → агент `gsd-executor` | `executing-plans` + `subagent-driven-development` |
| Параллельность | wave-based внутри `gsd-executor` | `dispatching-parallel-agents` |
| Verification | встроенная verification-петля в `gsd-execute-phase` + `VERIFICATION.md` | `verification-before-completion` перед коммитом |
| Pause/resume | `gsd-pause-work` + `gsd-resume-work` (через `.planning/`) | нет — superpowers работает внутри одной сессии |

Это и сбивает с толку. **Они не дубликаты — они на разных масштабах.**

---

## Разные масштабы

```
МАКРО (GSD)                          МИКРО (superpowers)
─────────────                        ──────────────────────
"фаза chat:                          "одна задача:
 8 эндпоинтов, polling,               polling с маскингом
 маскинг, фронт chat UI,              контактов, 4 часа"
 интеграция с profile"

→ .planning/phases/.../SPEC.md       → docs/superpowers/specs/...-design.md
→ PLAN.md с 8 задачами               → plans/...-plan.md
→ ETA: 1-2 недели                    → ETA: 1 сессия
→ артефакт переживёт /clear          → артефакт нужен реже
→ команда видит roadmap              → личный контекст

GSD-задача может быть СОСТАВНОЙ:
"задача 4 из PLAN.md = большая, требует своего плана"
   └─→ внутри `gsd-executor` активирует superpowers:writing-plans
       → пишет под-план
       → активирует test-driven-development
       → коммитит, переходит к задаче 5
```

---

## Кто реально пишет код

Оба плагина используют субагентов Claude — но разных:

### `gsd-executor` (GSD)
- Знает про `.planning/`, `PLAN.md`, манифесты, фазы.
- Делает **атомарные коммиты** на каждую завершённую задачу.
- Поддерживает **wave-based параллелизм**: независимые задачи идут вместе.
- Сохраняет **чекпойнты** в `.planning/state/`, чтобы фаза не сгорела при сбое.
- Финализирует фазу с `VERIFICATION.md`.

### Субагенты superpowers
- Знают про TDD-цикл, RED/GREEN/REFACTOR, систематический дебаг.
- Берут одну конкретную задачу и доводят до конца с верификацией.
- Используются либо самостоятельно (через `executing-plans`),
  либо **вызываются изнутри** `gsd-executor` для сложных задач.

> **Под капотом — Claude-агенты. Разница только в обвязке.**

---

## Правило выбора (одной фразой на кейс)

| Что делаю | Что брать | Почему |
|---|---|---|
| Новый проект, пустой `.planning/PROJECT.md` | <span style="color:#dc2626">`/gsd-new-project`</span> (см. CLAUDE.md §1 — brainstorming заблокирован) | нужен фундамент проекта в `.planning/` |
| Новая большая фаза (модуль, milestone) | `gsd-spec-phase` → `plan-phase` → `execute-phase` | артефакт в `.planning/`, команда видит roadmap |
| Фича на одну сессию | `superpowers:writing-plans` + `test-driven-development` | GSD-фаза для 4 часов работы — оверкилл |
| Тривиальная правка (≤10 строк, ≤2 файла) | Edit/Write напрямую | даже superpowers лишний |
| Упал тест, не понимаю почему | `superpowers:systematic-debugging` | баг не фаза, спека не нужна |
| Сложная задача внутри `execute-phase` | `gsd-executor` сам подтягивает `writing-plans` + TDD | вложенный детальный уровень |
| Перед claim «готово» | `superpowers:verification-before-completion` | проверка перед лажей |
| Параллельные независимые задачи | `superpowers:dispatching-parallel-agents` (или wave внутри `gsd-executor`) | оркестрация |
| Возвращаюсь через неделю | `gsd-resume-work` | superpowers контекст не хранит |
| Передаю работу коллеге | `gsd-pause-work` | хэндофф через артефакт |
| После крупной фичи | <span style="color:#dc2626">`reflexion:critique` (обязательно)</span> | единственная обязательная проверка качества |

---

## Реальный пример: один модуль с одной сложной фичей

```
1. Решил пилить модуль chat — отдельная крупная фича на 2-3 PR

2. /gsd-spec-phase chat
   → .planning/phases/2026-05-12-chat/SPEC.md
   → "8 эндпоинтов, polling, маскинг контактов, чат UI, интеграция profile"

3. /gsd-plan-phase
   → PLAN.md:
      ├─ 1. модели + миграция (S)
      ├─ 2. сервис create_thread + add_message (S)
      ├─ 3. эндпоинты GET/POST /chat/* (S)
      ├─ 4. polling логика на бэке (M)
      ├─ 5. маскинг контактов (regex + тесты) (M) ← сложная
      ├─ 6. фронт chat UI (M)
      ├─ 7. интеграция с profile.service (S)
      └─ 8. e2e Playwright (M)

4. /gsd-execute-phase
   ├─ ВОЛНА 1: задачи 1, 2, 3 параллельно (gsd-executor)
   │     └─ внутри каждой: TDD-цикл через superpowers:test-driven-development
   │
   ├─ ВОЛНА 2: задача 4 (зависит от 2)
   │
   ├─ ВОЛНА 3: задача 5 (зависит от 2, СЛОЖНАЯ)
   │     └─ gsd-executor видит сложность, активирует:
   │         ├─ superpowers:writing-plans (под-план маскинга)
   │         │     → docs/superpowers/plans/2026-05-12-mask-regex.md
   │         ├─ TDD: RED тест на "+7 999..." → GREEN regex → REFACTOR
   │         └─ commit с conventional message
   │
   ├─ ВОЛНА 4: задачи 6, 7 параллельно (зависят от 3, 4, 5)
   │
   └─ ВОЛНА 5: задача 8 (e2e, после всего)

5. /gsd-execute-phase финализирует:
   → .planning/phases/2026-05-12-chat/VERIFICATION.md
   → "цели SPEC.md достигнуты, все задачи PLAN.md закрыты"

6. /reflexion:critique  (⚠️ ОБЯЗАТЕЛЬНО для крупной фичи)
   → пройтись по findings, решить что чинить сейчас

7. /gsd-ship
   → gh pr create + auto-merge
```

---

## Где они конфликтуют на практике

**Одно место — старт проекта.** Если `.planning/PROJECT.md` пуст,
`superpowers:brainstorming` срабатывает автотриггером на «опиши идею»
и пишет спеку в `docs/superpowers/specs/` вместо `.planning/PROJECT.md`.

**Решение:** CLAUDE.md §1 содержит явный override-блок, который запрещает
`brainstorming` на этапе пустого `PROJECT.md`. Описание продукта идёт
только через `/gsd-new-project`.

В остальном плагины не конкурируют.

---

## Запомни три фразы

1. **GSD сверху, superpowers внутри.** Один не вытесняет другого.
2. **Нужен файл в `.planning/`?** → GSD. **Нет?** → superpowers или Edit.
3. **На пустом проекте сначала `gsd-new-project`**, потом всё остальное.
