# Troubleshooting

Типовые проблемы и быстрые фиксы.

## `vibeco: command not found`

```bash
npm i -g @vibecoswaga/cli
```

Если всё равно не найден — `npm config get prefix` и проверь, что `<prefix>/bin` в `$PATH`.

## `vibeco init` падает на `gh: not authenticated`

```bash
gh auth login
```

И повтори init.

## `docker: command not found`

Установи Docker Desktop, **запусти его** (иконка в трее), повтори.

## `pre-commit hook failed: вне твоей зоны`

Это норма — ты пытаешься тронуть чужую/общую зону. Варианты:

1. **Если случайно** — откатить: `git restore <file>` для нестейджнутого, `git reset HEAD <file>` для стейджнутого.
2. **Если намеренно (cross-zone)** — выйти из коммита, запустить `vibeco request-cross-zone <path> <reason>`.
3. **Если это RFC-PR общей зоны** — сделать **отдельный** PR только с изменением общей зоны (не миксовать с фичей).
4. **Никогда не использовать** `--no-verify` — это запрещено CLAUDE.md §12.

## `git rebase` словил конфликт

См. `playbooks/08-merge-conflict.md`. Кратко:

- Конфликт в **общей зоне** (docker-compose, package.json deps) — обычно простой, разруливаем вручную.
- Конфликт в **твоей зоне** — аномалия, зови команду.
- Конфликт в **контрактах** — нарушение §17, разбираемся кто менял без RFC-PR.

## CI красный, не понимаю что чинить

См. `playbooks/09-ci-debug.md`. Кратко:

1. `gh run view <run-id> --log-failed`
2. Воспроизведи локально: `docker compose -f docker-compose.test.yml exec backend pytest <test>`
3. Гипотеза → фикс → тест.
4. **Если не помогло 3 раза** — стоп, читай доки через Context7 (`mcp__plugin_context7_context7__query-docs`).
5. После 3-го фейла **никогда** не пробуй наугад в 4-й раз — это бездумный retry.

## Auto-merge не сработал, PR висит

Возможные причины:
1. **CI не прошёл** — открой Actions tab, разбирайся.
2. **CODEOWNERS не аппрувнули** — `gh pr view <N>` покажет, кто требуется.
3. **mergeable=false (конфликт с main)** — `git rebase main && git push --force-with-lease`.
4. **Branch protection нарушено** — например, требуется signed commit. Включи signing.

## Claude не знает, что делать

Если Claude растерялся:
1. Перечитай `CLAUDE.md` — все правила там.
2. Скажи Claude: «прочитай playbooks/06-parallel-work.md и продолжай».
3. Если репо новый и ничего не сделано — `playbook 01-intake.md` (или `/intake`).

## Pre-commit hook сломан / не запускается

Удалить и переустановить:

```bash
rm -f .git/hooks/pre-commit
./scripts/claim-developer.sh <N> <name>     # пересоздаст
```

## Контракт изменился случайно — `test_contracts.py` падает

1. Откатить изменение схемы: `git restore backend/app/schemas/<file>.py`.
2. Если действительно нужно изменить — отдельный RFC-PR (см. CLAUDE.md §17).

## DEVELOPER.local.md потерялся

```bash
./scripts/claim-developer.sh <N> <name>
```

Перегенерит из `docs/plan.md`.

## Я не знаю свой номер Dev #N

Открой `docs/plan.md` — там перечислены все Dev #1, Dev #2, Dev #3 с именами.

## Всё совсем плохо, хочу начать заново

Опасно, но если решился:

```bash
git stash                    # сохраним любые изменения
rm DEVELOPER.local.md
rm .git/hooks/pre-commit
./scripts/claim-developer.sh <N> <name>
git stash pop                # вернём изменения
```

Если надо снести проект целиком — `cd .. && rm -rf project-folder && vibeco init project-folder`.
