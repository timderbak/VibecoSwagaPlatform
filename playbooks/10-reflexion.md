# Playbook 10 — Reflexion

Цель: после мержа крупной фичи запустить критическую саморевизию через `reflexion:critique`, выкатить findings как issues для автора.

## Когда запускается

### Автоматически
GitHub Action `.github/workflows/reflexion.yml` на push в `main` (внутри Action запускается `claude --print` со skill `reflexion:critique`):
- Если коммит содержит `feat:` в заголовке.
- Если изменено > 5 файлов в одном слайсе (heuristic «крупная фича»).

### Вручную
Запусти агента `.claude/agents/reflexion-runner.md` с указанием sha коммита, либо в headless:
```bash
claude --print "Запусти skill reflexion:critique на коммите <commit-sha> (см. .claude/agents/reflexion-runner.md)"
```

## Что делает Reflexion

1. Запускает headless Claude со skill `reflexion:critique`.
2. Передаёт ему: diff коммита, спеку фичи (если есть `docs/specs/<topic>.md`), `docs/plan.md`.
3. Skill анализирует:
   - **Тесты**: достаточно ли покрытия? Edge cases? 4xx/5xx сценарии?
   - **Безопасность**: SQL-injection, XSS, авторизация, утечка данных другого тенанта.
   - **Производительность**: N+1 запросы, отсутствующие индексы, неэффективные fetch.
   - **Архитектура**: SRP, DRY, правильный ли слой держит логику.
   - **Контракты**: соответствует ли реализация Pydantic-модели?
   - **Документация**: обновлены ли `docs/features.md`, `docs/changelog.md`?
4. Возвращает список findings с приоритетами (critical / major / minor).

## Что делать с findings

`reflexion-runner` агент создаёт по одному GitHub-issue на finding:
- Title: `[reflexion] <короткое описание>`
- Label: `reflexion-finding`, `priority:<critical|major|minor>`
- Assignee: автор оригинального коммита
- Body: цитата из критики + ссылка на коммит/файл.

При следующем `что у нас?` Claude напоминает о findings.

## Reflexion НЕ блокирует мерж

Это **пост-фактум** ревью. Мерж уже произошёл. Findings — это бэклог для уточнений, не red gate.

## Решение по findings — за человеком

Claude **не чинит** findings автоматически. Человек решает:
- Чинить сейчас (приоритет critical).
- В бэклог (приоритет major).
- Игнорить (закрыть как `wontfix`).

Никаких «согласен/не согласен» на каждый пункт — только решение.

## Никогда

- Не запускать Reflexion на каждый коммит — будет шум и token burn.
- Не превращать findings в холиварные обсуждения.
- Не использовать Reflexion как замену code review.
