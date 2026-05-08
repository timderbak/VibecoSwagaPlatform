---
description: Module-level intake/spec/decompose/contracts для текущего владельца
---

Запусти `playbooks/03b-module-decomposition.md` для модуля текущего разработчика.

Шаги:
1. Прочитай `DEVELOPER.local.md` — определи свои модули.
2. Если несколько модулей — спроси, какой инициализируем сейчас.
3. Проверь, нет ли уже `docs/specs/module-<slug>.md` — если есть, спроси, перезапускать ли.
4. Module intake — `superpowers:brainstorming`. Задай вопросы по сущностям, сценариям, edge cases (см. плейбук). Запиши `docs/intake-modules/<slug>.md`.
5. Module spec — `superpowers:writing-plans`. Запиши `docs/specs/module-<slug>.md` по шаблону из плейбука. Жди апрува.
6. Module decompose — обнови `docs/plan.md`, расписав Features внутри Submodules для этого модуля. Зафиксируй порядок разработки.
7. Module contracts — RFC-PR (отдельный PR в общую зону): Pydantic-модели + роутеры со stub'ами + регенерация TS-типов через `scripts/gen-types.sh`. Жди мержа RFC-PR.
8. После завершения — переходим к `playbooks/11-feature-execution.md` по первой Feature.
