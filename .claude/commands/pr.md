---
description: Pre-PR check + push + создать PR + auto-merge
---

Запусти агента `.claude/agents/pr-checker.md`. Он сделает:

1. Pre-PR check (тесты, линтер, rebase, контракты, границы).
2. `git push` (или `--force-with-lease` если был rebase).
3. `gh pr create` с авто-генерёнными title и body из коммитов.
4. `gh pr merge --auto --squash` — GitHub сам мержит, когда CI зелёный + аппрувы CODEOWNERS.

См. `playbooks/06-parallel-work.md` секция «Отдача на ревью».
