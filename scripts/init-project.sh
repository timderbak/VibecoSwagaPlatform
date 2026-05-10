#!/usr/bin/env bash
# init-project.sh — распаковывает reference/ в корень + готовит docs/ + .planning/.
#
# Usage:
#   ./scripts/init-project.sh fastapi   # FastAPI + Next.js эталон
#   ./scripts/init-project.sh blank     # только playbooks, без кода
#
# Запускается один раз вручную сразу после `git clone` нового проекта
# из этого template.
#
# После выполнения:
#   1. Папка reference/ удалена.
#   2. В корне лежит код (backend/, frontend/, docker-compose.*, .github/).
#   3. В docs/ лежат пустые шаблоны (business-flows.md, tech-stack.md и т.д.).
#   4. В .planning/ лежат PROJECT.md и ROADMAP.md (стартовая точка для GSD).
#   5. DEVELOPERS.md в корне — список разработчиков и зон ответственности.

set -euo pipefail

STACK="${1:-fastapi}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# ────────────────────────────────────────────────────────────────────
# helpers
# ────────────────────────────────────────────────────────────────────

copy_doc_template() {
  local name="$1"
  local src="docs/templates/${name}.template"
  local dst="docs/${name}"
  if [ -f "$src" ] && [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    echo "  ✓ docs/${name}"
  fi
}

init_planning_dir() {
  mkdir -p .planning/phases
  if [ ! -f .planning/PROJECT.md ] && [ -f docs/templates/.planning-PROJECT.md.template ]; then
    cp docs/templates/.planning-PROJECT.md.template .planning/PROJECT.md
    echo "  ✓ .planning/PROJECT.md"
  fi
  if [ ! -f .planning/ROADMAP.md ] && [ -f docs/templates/.planning-ROADMAP.md.template ]; then
    cp docs/templates/.planning-ROADMAP.md.template .planning/ROADMAP.md
    echo "  ✓ .planning/ROADMAP.md"
  fi
  touch .planning/phases/.gitkeep
}

init_developers_md() {
  if [ ! -f DEVELOPERS.md ] && [ -f docs/templates/DEVELOPERS.md.template ]; then
    cp docs/templates/DEVELOPERS.md.template DEVELOPERS.md
    echo "  ✓ DEVELOPERS.md"
  fi
}

# ────────────────────────────────────────────────────────────────────

case "$STACK" in
  fastapi)
    echo "→ Initializing FastAPI + Next.js project from reference/"
    if [ ! -d reference ]; then
      echo "✗ reference/ directory not found. Are you in the template repo?"
      exit 1
    fi

    cp -r reference/backend ./
    cp -r reference/frontend ./
    cp reference/docker-compose.yml ./
    cp reference/docker-compose.test.yml ./
    cp reference/deploy.sh ./
    cp reference/.env.example ./
    cp -r reference/.github ./
    rm -rf reference/
    chmod +x deploy.sh

    echo ""
    echo "→ Initializing docs/ from templates"
    copy_doc_template business-flows.md
    copy_doc_template tech-stack.md
    copy_doc_template features.md
    copy_doc_template architecture.md
    copy_doc_template changelog.md

    echo ""
    echo "→ Initializing .planning/ for GSD workflow"
    init_planning_dir

    echo ""
    echo "→ Initializing DEVELOPERS.md"
    init_developers_md

    echo ""
    echo "✓ FastAPI project initialized."
    ;;

  blank)
    echo "→ Initializing blank project (playbooks only, no reference code)"
    rm -rf reference/

    echo ""
    echo "→ Initializing docs/ from templates"
    copy_doc_template business-flows.md
    copy_doc_template tech-stack.md
    copy_doc_template features.md
    copy_doc_template architecture.md
    copy_doc_template changelog.md

    echo ""
    echo "→ Initializing .planning/ for GSD workflow"
    init_planning_dir

    echo ""
    echo "→ Initializing DEVELOPERS.md"
    init_developers_md

    echo ""
    echo "✓ Blank project initialized."
    echo ""
    echo "  You'll need to set up your own backend/, frontend/, docker-compose.yml etc."
    echo "  See playbooks/ for guidance."
    ;;

  *)
    echo "✗ Unknown stack: $STACK"
    echo "Usage: $0 [fastapi|blank]"
    exit 1
    ;;
esac

echo ""
echo "Next steps:"
echo "  1. Edit DEVELOPERS.md — fill in your team."
echo "  2. Edit .planning/PROJECT.md and ROADMAP.md — describe your project + first milestone."
echo "  3. Edit docs/business-flows.md — write at least one user flow."
echo "  4. Copy .env.example → .env, fill in values."
echo "  5. Run 'claude' and say 'погнали' — onboarding will start."
