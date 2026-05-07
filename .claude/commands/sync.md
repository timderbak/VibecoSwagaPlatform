---
description: Агрегат для еженедельного созвона — статус по всем девам
---

Запусти `vibeco sync-summary`.

Если CLI недоступен — сделай вручную:
1. Прочитай `docs/plan.md`, перечисли всех Dev #N.
2. Для каждого — `gh api repos/{owner}/{repo}/branches/dev/<N>/<slice>` → последний коммит, его дата.
3. Для каждого — `gh pr list --author @<handle> --state all --limit 5`.
4. Для каждого — пройдись по WP в плане, отметь статус (готов / в работе / pending) на основании коммитов и PR.

Формат таблицы:
```
| Dev | Slice | Last commit | Open PR | WPs done | WPs in flight |
|-----|-------|-------------|---------|----------|---------------|
| #1 Тим | projects | 2h ago | #42 (CI green) | 3/8 | WP-1.4 |
| #2 Влад | billing | 1d ago | — | 1/6 | WP-2.2 |
...
```

Этот summary человек скопирует в общий чат.
