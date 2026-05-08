---
description: Сводный отчёт — ветка, PR, входящие cross-zone, reflexion findings
---

Сформируй сводный отчёт человеку через прямые `git`/`gh`-команды.

1. `git status -sb && git log --oneline -5`
2. `gh pr list --author @me --state open --json number,title,statusCheckRollup`
3. `gh issue list --label cross-zone-request --assignee @me --json number,title`
4. `gh issue list --label reflexion-finding --assignee @me --json number,title`
5. Прочитай `docs/plan.md`, найди свои WP, определи текущий (первый незавершённый).

Формат отчёта:
```
Роль:           Dev #N (имя) — slice <slice>
Ветка:          <branch> (<commits ahead of main>)
Незакоммичено:  <count>
Открытых PR:    <count> [список с номерами и статусом CI]
Входящих cross-zone: <count> [список]
Reflexion findings: <count>
Текущий WP:     <WP-X.Y «название»>
```
