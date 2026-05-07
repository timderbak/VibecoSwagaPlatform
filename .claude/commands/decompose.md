---
description: Нарезать spec на vertical slices, заполнить docs/plan.md и .github/CODEOWNERS
---

Запусти `playbooks/03-decomposition.md`.

Шаги:
1. Прочитать `docs/spec.md`.
2. Спросить у человека: «Кто в команде? Сколько человек, имена, GitHub-handles?».
3. По эвристике из плейбука нарезать на vertical slices, балансируя по объёму.
4. Заполнить `docs/plan.md` (формат — в плейбуке).
5. Сгенерировать `.github/CODEOWNERS` из плана.
6. Закоммить: `docs: decomposition v1`.
7. Показать распределение человеку, спросить: «Норм или поменять?».
8. После апрува сказать: «Иду в /contracts».
