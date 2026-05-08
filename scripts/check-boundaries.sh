#!/usr/bin/env bash
# check-boundaries.sh — Pre-commit hook, валит коммит при попытке записи в чужую зону
# Симлинкуется в .git/hooks/pre-commit скриптом claim-developer.sh

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
DEV_FILE="$ROOT/DEVELOPER.local.md"

if [ ! -f "$DEV_FILE" ]; then
  echo "❌ DEVELOPER.local.md не найден."
  echo "   Запусти: ./scripts/claim-developer.sh <N> <name>"
  echo "   Или, если ты создатель проекта и ещё не /decompose'нул — пропусти этот hook через"
  echo "   git -c core.hooksPath=/dev/null commit ... (только для первичного skeleton-merge!)"
  exit 1
fi

# Парсим DEVELOPER.local.md — секции 'Мои слайсы' + 'Общие зоны'
ALLOWED=$(awk '
  /^## Мои слайсы/ { mode="allowed"; next }
  /^## Общие зоны/ { mode="allowed"; next }
  /^## / { mode="" }
  mode=="allowed" && /^- / { gsub(/^- /, ""); gsub(/[[:space:]]+←.*/, ""); print }
' "$DEV_FILE")

if [ -z "$ALLOWED" ]; then
  echo "⚠ DEVELOPER.local.md есть, но в нём не нашёл 'Мои слайсы'/'Общие зоны'. Перегенерируй."
  exit 1
fi

# Файлы в текущем коммите
STAGED=$(git diff --cached --name-only --diff-filter=ACMR)

if [ -z "$STAGED" ]; then
  exit 0
fi

VIOLATIONS=()
for FILE in $STAGED; do
  MATCHED=0
  while IFS= read -r PATTERN; do
    [ -z "$PATTERN" ] && continue
    # Сравниваем через bash glob
    case "$FILE" in
      $PATTERN) MATCHED=1; break ;;
    esac
  done <<< "$ALLOWED"
  if [ "$MATCHED" -eq 0 ]; then
    VIOLATIONS+=("$FILE")
  fi
done

if [ ${#VIOLATIONS[@]} -gt 0 ]; then
  echo "❌ Попытка коммита в чужую зону:"
  for F in "${VIOLATIONS[@]}"; do
    echo "   - $F"
  done
  echo ""
  echo "   Эти файлы вне твоей зоны (см. DEVELOPER.local.md)."
  echo "   Если действительно нужно — попроси Claude:"
  echo "     'запроси у <имя_овнера> <что>'"
  echo "   Claude создаст GitHub-issue с тегом cross-zone-request."
  echo ""
  echo "   Если это RFC-PR общей зоны — закоммить ОТДЕЛЬНЫМ PR'ом, не миксуй с фичей."
  echo ""
  echo "   Обходить через --no-verify запрещено (CLAUDE.md §12)."
  exit 1
fi

exit 0
