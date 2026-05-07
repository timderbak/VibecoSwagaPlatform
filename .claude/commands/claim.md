---
description: Заявить «я Dev #N» — генерация DEVELOPER.local.md и установка pre-commit hook
argument-hint: <N> <name>
---

Запусти `./scripts/claim-developer.sh $1 $2`.

Скрипт:
1. Прочитает `docs/plan.md`, найдёт строку «Dev #$1 — ...».
2. Сгенерит `DEVELOPER.local.md` с твоими/чужими/общими зонами.
3. Установит pre-commit hook (`.git/hooks/pre-commit` → симлинк на `scripts/check-boundaries.sh`).
4. Создаст ветку `dev/$1/<slice>` и переключится на неё.

После завершения сообщи человеку: «Ты Dev #$1. Зона: <slice>. Ветка: dev/$1/<slice>. Готов начать?».
