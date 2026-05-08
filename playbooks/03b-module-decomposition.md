# Playbook 03b — Module-level Decomposition

Цель: когда Dev #N начинает работу над **своим модулем**, он рекурсивно проходит мини-цикл intake → spec → decompose → contracts для этого модуля.

## Когда запускается
- Когда Dev #N выбрал свой модуль из `docs/plan.md` для старта работы.
- Если для модуля ещё нет `docs/specs/module-<slug>.md` — запускается **обязательно перед началом фичей**.
- Вручную: `/module-init`.

## Зачем это нужно

Project-level декомпозиция (`playbook 03`) дала только Module + Submodule заголовки и порядок. Этого **недостаточно** для прямого начала кодинга:
- Какие именно сущности в модуле? Какие поля?
- Какие сценарии пользователя? Что делать на edge cases?
- Какие endpoints внутри подмодуля?
- Какие страницы во фронте?

Module-level intake — это **decentralized planning**: каждый Dev сам думает про свой модуль глубоко, а не Тим всё расписывает за всех.

## Этапы (рекурсивный мини-цикл)

### Этап 1: Module intake (Dev один с Claude)
Skill: `superpowers:brainstorming`. Длительность: ~30-60 минут.

Claude задаёт тебе вопросы по модулю:
- Какие сущности (entity model)?
- Какие связи между ними?
- Какие пользовательские сценарии (3-5 штук)?
- Какие edge cases (что если ошибка / пустой список / уже существует)?
- Какие внешние зависимости (другой модуль / внешний API)?
- Какие нефункциональные требования модуля (latency, нагрузка)?

Записываем в `docs/intake-modules/<slug>.md`.

### Этап 2: Module spec
Skill: `superpowers:writing-plans` (часть про spec). Длительность: ~30 минут.

Claude из intake пишет `docs/specs/module-<slug>.md`:

```markdown
# Module Spec — Projects (Dev #1)
Дата: <YYYY-MM-DD>

## Цель
<одно предложение>

## Сущности
### Project
- id, title, client_id, status, owner_id, created_at, updated_at
- relations: has many Milestones, has many Files
- statuses: draft → in_progress → on_hold → completed → cancelled

### Milestone
...

## Сценарии
1. Создание проекта: фаундер выбирает клиента → ...
2. Перевод проекта в статус «on_hold»: ...
3. ...

## Endpoints (high-level)
- POST   /projects
- GET    /projects (с фильтрами status, client, owner)
- GET    /projects/:id
- PATCH  /projects/:id
- DELETE /projects/:id  (soft-delete)
- POST   /projects/:id/milestones
- GET    /projects/:id/milestones
- ...

## Pages (frontend)
- /projects                — список с фильтрами
- /projects/[id]           — детальная (read view)
- /projects/[id]/edit      — форма редактирования
- /projects/new            — форма создания
- /projects/[id]/milestones/...

## Acceptance criteria
- [ ] Создание проекта валидирует обязательные поля (title, client_id)
- [ ] Перевод в cancelled блокирует дальнейшее редактирование
- [ ] При delete — soft-delete, не физическое удаление
- [ ] Tenant-isolation: Dev #1 не видит проекты Dev #2 (если multi-tenant)

## Cross-zone зависимости
- User.role (зона Dev #3) — нужен для проверки прав owner_id
  → создать cross-zone issue ДО начала фичей, если поле ещё не добавлено

## Риски
- ...

## Открытые вопросы
- Bulk update endpoint нужен или нет? — на потом, не в этом модуле
```

Закоммить, спросить апрув.

### Этап 3: Module decompose (расписать Features)

Теперь, имея module spec, расписываем **Features внутри подмодулей**, дополняя `docs/plan.md`. Раньше там было:

```markdown
### Submodule 1.1 — Project core
*Features расписываются на module-level decompose.*
```

Становится:

```markdown
### Submodule 1.1 — Project core
- Feature 1.1.1: Project model + миграция
- Feature 1.1.2: POST /projects + integration test
- Feature 1.1.3: GET /projects (list с фильтрами) + test
- Feature 1.1.4: GET /projects/:id (detail) + test
- Feature 1.1.5: PATCH /projects/:id + test
- Feature 1.1.6: DELETE /projects/:id (soft-delete) + test
- Feature 1.1.7: Project list page (frontend)
- Feature 1.1.8: Project detail page
- Feature 1.1.9: Project create form
- Feature 1.1.10: Project edit form

**Порядок:** 1.1.1 → 1.1.2 → 1.1.3 → 1.1.7 → 1.1.4 → 1.1.8 → ...
```

Каждая Feature — это **один PR**, имеет integration-тест и атомарный коммит.

Не делай features слишком крупными (больше дня работы) или слишком мелкими (одна строка кода).

### Этап 4: Module contracts (RFC-PR)

Если модуль определяет новые публичные эндпоинты или общие схемы:
1. Создать Pydantic-модели в `backend/app/schemas/<module>.py`.
2. Создать роутеры в `backend/app/api/<module>/<submodule>.py` со stub'ами `raise NotImplementedError("WP-X.Y.Z")`.
3. Запустить `scripts/gen-types.sh` для регенерации TS-типов.
4. **RFC-PR** в общую зону — потому что `backend/app/schemas/` это общая зона.
5. После мержа RFC-PR — контракт зафиксирован, дальше его менять только через новый RFC-PR.

## Когда переходить к следующему этапу

После завершения этого плейбука:
- `docs/intake-modules/<slug>.md` готов
- `docs/specs/module-<slug>.md` готов и апрувлен
- `docs/plan.md` дополнен Features внутри Submodules
- `.github/CODEOWNERS` обновлён (если появились новые пути)
- RFC-PR с контрактами модуля замержен

→ Переходи к `playbook 11-feature-execution.md` — реализуй features по порядку.

## Когда **НЕ** запускать этот плейбук

- Если модуль очень мелкий (< 5 features, нет своих сущностей) — можно сразу `playbook 11`. Но это редкость.
- Если `docs/specs/module-<slug>.md` уже есть и актуален.

## Принцип

**Каждый владелец модуля делает мини-инициализацию своего модуля сам.** Это:
- даёт глубину, которую project-level intake физически не может
- закрепляет ownership (Dev владеет архитектурой своего модуля)
- расходится с проектом по времени — Dev #2 может начать свой модуль через 2 недели после Dev #1, и к тому моменту контекст у проекта будет уже другой
