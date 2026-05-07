#!/usr/bin/env bash
# init-project.sh — распаковывает reference/ в корень репо.
#
# Usage:
#   ./scripts/init-project.sh fastapi   # FastAPI + Next.js эталон
#   ./scripts/init-project.sh blank     # только playbooks, без кода
#
# Запускается из vibeco init после клонирования шаблона.

set -euo pipefail

STACK="${1:-fastapi}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

case "$STACK" in
  fastapi)
    echo "→ Initializing FastAPI + Next.js project from reference/"
    if [ ! -d reference ]; then
      echo "✗ reference/ directory not found. Are you in the template repo?"
      exit 1
    fi

    # Move reference contents to root
    cp -r reference/backend ./
    cp -r reference/frontend ./
    cp reference/docker-compose.yml ./
    cp reference/docker-compose.test.yml ./
    cp reference/deploy.sh ./
    cp reference/.env.example ./
    cp -r reference/.github ./

    # Cleanup
    rm -rf reference/

    # Make deploy.sh executable
    chmod +x deploy.sh

    # Init empty docs templates if not present
    [ -f docs/business-flows.md ] || cp docs/templates/business-flows.md.template docs/business-flows.md 2>/dev/null || true
    [ -f docs/tech-stack.md ] || cp docs/templates/tech-stack.md.template docs/tech-stack.md 2>/dev/null || true
    [ -f docs/features.md ] || cp docs/templates/features.md.template docs/features.md 2>/dev/null || true
    [ -f docs/architecture.md ] || cp docs/templates/architecture.md.template docs/architecture.md 2>/dev/null || true
    [ -f docs/changelog.md ] || cp docs/templates/changelog.md.template docs/changelog.md 2>/dev/null || true

    echo "✓ FastAPI project initialized."
    echo ""
    echo "Next steps:"
    echo "  1. Copy .env.example → .env, fill in values"
    echo "  2. Run 'claude' to start onboarding"
    ;;

  blank)
    echo "→ Initializing blank project (playbooks only, no reference code)"
    rm -rf reference/
    echo "✓ Blank project initialized."
    echo ""
    echo "Next steps:"
    echo "  1. You'll need to set up your own backend/, frontend/, docker-compose.yml etc."
    echo "  2. Use playbooks/ as a guide"
    echo "  3. Run 'claude' to start onboarding"
    ;;

  *)
    echo "✗ Unknown stack: $STACK"
    echo "Usage: $0 [fastapi|blank]"
    exit 1
    ;;
esac
