#!/usr/bin/env bash
# claim-developer.sh — Заявить «я Dev #N»
#
# Usage:
#   ./scripts/claim-developer.sh 2 vlad
#
# Что делает:
#   1. Парсит docs/plan.md, находит Dev #N и его слайсы
#   2. Генерит DEVELOPER.local.md (в .gitignore)
#   3. Ставит pre-commit hook (симлинк на check-boundaries.sh)
#   4. Создаёт ветку dev/N/<slice> и переключается

set -euo pipefail

DEV_N="${1:?Usage: $0 <N> <name>}"
DEV_NAME="${2:?Usage: $0 <N> <name>}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ ! -f docs/plan.md ]; then
  echo "✗ docs/plan.md not found. Run /decompose first."
  exit 1
fi

# Парсим plan.md — это упрощённый парсер, в реальности vibeco CLI сделает лучше
SLICES=$(awk -v n="### Dev #$DEV_N" '
  $0 ~ n { found=1; next }
  found && /^### Dev #/ { exit }
  found && /^\*\*Slice:/ { print }
' docs/plan.md | sed 's/\*\*Slice: \(.*\)\*\*/\1/' || true)

if [ -z "$SLICES" ]; then
  echo "✗ Dev #$DEV_N не найден в docs/plan.md."
  echo "Доступные:"
  grep -E '^### Dev #' docs/plan.md || echo "(нет)"
  exit 1
fi

PRIMARY_SLICE=$(echo "$SLICES" | head -1)
BRANCH="dev/$DEV_N/$PRIMARY_SLICE"

# Генерим DEVELOPER.local.md
cat > DEVELOPER.local.md <<EOF
# Я — Dev #$DEV_N ($DEV_NAME)

> Сгенерировано $(date "+%Y-%m-%d %H:%M") скриптом ./scripts/claim-developer.sh
> Не редактировать руками — перезапусти скрипт.

## Мои слайсы (READ + WRITE)
EOF

for slice in $SLICES; do
  cat >> DEVELOPER.local.md <<EOF
- backend/app/$slice/**
- frontend/app/$slice/**
- backend/tests/integration/$slice/**
- frontend/tests/$slice/**
EOF
done

cat >> DEVELOPER.local.md <<EOF

## Общие зоны (READ-ONLY, изменения только через RFC-PR)
- docs/contracts/**
- backend/app/core/**
- backend/app/schemas/**
- frontend/components/ui/**
- frontend/lib/api/**
- docker-compose*.yml
- .env.example
- .github/CODEOWNERS

## Чужие зоны (НЕ ТРОГАТЬ)
EOF

# Перечисли всех других девов
awk '/^### Dev #/ { print }' docs/plan.md | while read -r line; do
  OTHER_N=$(echo "$line" | sed -E 's/.*Dev #([0-9]+).*/\1/')
  if [ "$OTHER_N" != "$DEV_N" ]; then
    OTHER_SLICES=$(awk -v n="### Dev #$OTHER_N" '
      $0 ~ n { found=1; next }
      found && /^### Dev #/ { exit }
      found && /^\*\*Slice:/ { print }
    ' docs/plan.md | sed 's/\*\*Slice: \(.*\)\*\*/\1/' || true)
    for s in $OTHER_SLICES; do
      echo "- backend/app/$s/**     ← Dev #$OTHER_N" >> DEVELOPER.local.md
      echo "- frontend/app/$s/**    ← Dev #$OTHER_N" >> DEVELOPER.local.md
    done
  fi
done

cat >> DEVELOPER.local.md <<EOF

## Моя ветка
$BRANCH
EOF

echo "✓ DEVELOPER.local.md сгенерирован."

# Pre-commit hook
mkdir -p .git/hooks
ln -sf "$ROOT/scripts/check-boundaries.sh" .git/hooks/pre-commit
chmod +x scripts/check-boundaries.sh
echo "✓ Pre-commit hook установлен."

# Ветка
if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  git checkout "$BRANCH"
else
  git checkout -b "$BRANCH"
fi
echo "✓ Ветка $BRANCH активна."

echo ""
echo "Готово. Ты Dev #$DEV_N ($DEV_NAME)."
echo "Слайс: $PRIMARY_SLICE"
echo "Ветка: $BRANCH"
echo "Запусти 'claude' и скажи 'погнали'."
