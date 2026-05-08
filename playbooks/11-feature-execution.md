# Playbook 11 — Feature Execution

Цель: реализовать одну Feature из `docs/plan.md` от первого «погнали» до замёрженного PR.

## Когда запускается
- Когда Dev #N сказал «продолжаем» / «погнали».
- Module-level decompose уже сделан (см. `playbook 03b`), у Feature есть номер и описание.

## Алгоритм

### Шаг 1: Найди текущую Feature

Прочитай `docs/plan.md`. Найди свой модуль, найди первую Feature которая:
- ещё не сделана (нет коммита/PR с её номером)
- не блокирована другими Features из её submodule (см. порядок в плане)

Сообщи Dev'у:
> «Текущая Feature: 1.1.3 — Project list с фильтрами по status, client, owner.
> Перед началом — определимся с уровнем сложности, чтобы выбрать процесс.»

### Шаг 2: Классификация сложности

По `CLAUDE.md §1`:

#### Тривиальная Feature
- ≤ 10 строк кода
- ≤ 2 файла
- Нет архитектурных решений
- Контракт уже зафиксирован

Примеры: «добавь поле `is_archived: bool` в модель», «добавь фильтр по date_from в существующий list endpoint».

→ **Сразу в TDD** (Шаг 4). Пропускаем feature-spec.

#### Средняя Feature
- 1 модуль / папка
- Понятное решение
- Возможно, несколько файлов
- Нет новых публичных контрактов

Примеры: «list endpoint с фильтрами и пагинацией», «detail page с loading/empty states», «cron-job по простому правилу».

→ Skill `superpowers:writing-plans`. Пишем мини-spec в `docs/specs/feature-<id>.md`. Дальше TDD.

#### Крупная Feature
- Архитектурные решения (state machine, retry-policy, новая интеграция)
- Несколько компонентов
- Cross-cutting concerns (auth, audit, side effects)
- Новые публичные контракты или изменение существующих → **RFC-PR**

Примеры: «approval state machine», «Stripe webhook handler с retry», «AI ассистент с context-window management».

→ Полный пайплайн:
1. Skill `superpowers:brainstorming` — обсуждаем варианты, edge cases, риски.
2. Skill `superpowers:writing-plans` — детальная spec + план под-задач.
3. Skill `superpowers:dispatching-parallel-agents` — если есть независимые под-задачи.
4. TDD по каждой под-задаче.
5. Skill `superpowers:verification-before-completion` — финальная проверка.

### Шаг 3: Feature-level intake (для средних/крупных)

Спроси Dev'а — задавай по одному вопросу. Примеры для разных типов:

**Для list page:**
- Какие фильтры на ней? (status, client, owner, date range)
- Сортировка по чему? Default order?
- Пагинация: page/page-size или infinite scroll?
- Что показывать на пустой выдаче?

**Для cron-job:**
- Расписание: каждый час, день, ... ?
- Что считается «обработано»? Какое условие выборки?
- При ошибке: retry, dead-letter, alert?
- Idempotency: что если обработать одну запись дважды?

**Для state-machine:**
- Какие состояния? Какие переходы разрешены?
- Кто может делать какой переход (роли)?
- Что должно произойти как side-effect на каждом переходе (email, log, audit)?
- Что при попытке невалидного перехода — ignore, error, толстый toast?

Записываем ответы. Если Dev не уверен — предлагай дефолт со ссылкой на CLAUDE.md или сам shaping (например, «retry с экспоненциальным backoff x3 — это стандарт, ок?»).

### Шаг 4: Feature spec (для средних/крупных)

Пиши `docs/specs/feature-<X.Y.Z>.md`:

```markdown
# Feature <X.Y.Z> — <название>
Дата: <YYYY-MM-DD>
Module: <module>, Submodule: <submodule>
Owner: Dev #<N>

## Что реализуем
<суть в 2-3 предложениях>

## Под-задачи (порядок)
1. Миграция: добавить поля X, Y
2. Pydantic-схема (RFC если меняет контракт)
3. Backend endpoint POST /...
4. Backend endpoint GET /...
5. Frontend page
6. Integration tests
7. Frontend tests

## Acceptance criteria
- [ ] <конкретное проверяемое утверждение>
- [ ] <ещё одно>

## Edge cases
- Пустой список → ...
- 401/403 → ...
- 422 (валидация) → ...
- Конкуррентность / race condition → ...

## Риски и митигация
- ...
```

Закоммить, попроси Dev'а апрувнуть. Без апрува — не TDD.

### Шаг 5: TDD по под-задачам

Skill `superpowers:test-driven-development`.

Для каждой под-задачи:
```
1. RED:    написать integration test, запустить — должен упасть с ожидаемой ошибкой
2. GREEN:  минимум кода чтобы тест прошёл
3. REFACT: причесать без поломки
4. COMMIT: один коммит на одну под-задачу
   format: feat(<module>): <wp/feature description>
```

В конце каждой под-задачи — прогон **всех тестов своего модуля**, не только нового.

### Шаг 6: Stop-rule (если что-то не работает)

После 3 неудачных попыток фикса (CI / тест / интеграция) — **СТОП**. Применяй `CLAUDE.md §5`:
1. Прочитай официальную документацию через `mcp__plugin_context7_context7__query-docs`.
2. Сформулируй: «Я застрял на X, прочитал Y, гипотеза Z».
3. Зови человека.
4. Не делай 4-ю попытку без явного «продолжай».

### Шаг 7: «отдавай»

Когда все под-задачи закончены и тесты зелёные:
- Запусти агента `.claude/agents/pr-checker.md`.
- Создаст PR с auto-merge.
- Когда CI зелёный + аппрувы CODEOWNERS (если затронута общая зона) → GitHub мержит.

### Шаг 8: Reflexion (после мержа)

Если коммит был `feat:` — `reflexion.yml` workflow запустится автоматически. Findings прилетят issues с тегом `reflexion-finding`. Обработка — на следующее утро («что у нас?»).

### Шаг 9: Следующая Feature

После мержа:
- Обнови статус Feature в `docs/plan.md` (галочка / strikethrough / комментарий).
- Если это была последняя Feature в подмодуле — обнови статус подмодуля.
- Спроси Dev'а: «<X.Y.Z> замержена. Следующая по порядку — <X.Y.Z+1>. Продолжаем или break?»

## Краткая шпаргалка по skill-выбору

| Тип Feature | Skill chain |
|---|---|
| Тривиальная | `test-driven-development` → коммит |
| Средняя | `writing-plans` → `test-driven-development` → коммит/PR |
| Крупная | `brainstorming` → `writing-plans` → `dispatching-parallel-agents` → `test-driven-development` → `verification-before-completion` → PR |

## Принцип

**Не торопись в TDD на сложной Feature.** Час на feature-intake/spec экономит день на переписывании кода, который собран не по тому видению.
