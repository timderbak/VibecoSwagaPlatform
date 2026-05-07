---
description: Сводный отчёт — ветка, PR, входящие cross-zone, reflexion findings
---

Запусти `vibeco status` и сформируй сводный отчёт человеку.

Если CLI недоступен — сделай вручную:
1. `git status -sb && git log --oneline -5`
2. `gh pr list --author @me --state open`
3. `gh issue list --label cross-zone-request --assignee @me`
4. `gh issue list --label reflexion-finding --assignee @me`
5. Прочитай `docs/plan.md`, найди свои WP, определи текущий (первый незавершённый).

Формат отчёта:
```
Ветка: <branch> (<commits ahead of main>)
Незакоммиченных: <count>
Открытых PR: <count> [список с номерами и статусом CI]
Входящих cross-zone: <count> [список]
Reflexion findings: <count>
Текущий WP: <WP-X.Y «название»>
```
