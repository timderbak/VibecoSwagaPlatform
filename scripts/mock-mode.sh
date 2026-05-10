#!/usr/bin/env bash
# mock-mode.sh — Включает/выключает mock-режим для cross-module reads.
#
# В mock-режиме твой модуль работает на фейковых данных коллег
# (см. playbook 12-isolated-development.md).
#
# Usage:
#   ./scripts/mock-mode.sh on    # включить
#   ./scripts/mock-mode.sh off   # выключить (production-like)
#   ./scripts/mock-mode.sh status

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
ENV_LOCAL="$ROOT/.env.local"

ACTION="${1:?Usage: $0 [on|off|status]}"

ensure_env_local() {
  if [ ! -f "$ENV_LOCAL" ]; then
    touch "$ENV_LOCAL"
    if ! grep -q '\.env\.local' "$ROOT/.gitignore" 2>/dev/null; then
      echo ".env.local" >> "$ROOT/.gitignore"
    fi
  fi
}

case "$ACTION" in
  on)
    ensure_env_local
    if grep -q '^MOCK_CROSS_MODULES=' "$ENV_LOCAL"; then
      sed -i.bak 's/^MOCK_CROSS_MODULES=.*/MOCK_CROSS_MODULES=true/' "$ENV_LOCAL"
      rm -f "$ENV_LOCAL.bak"
    else
      echo "MOCK_CROSS_MODULES=true" >> "$ENV_LOCAL"
    fi
    echo "✓ Mock-режим ВКЛЮЧЁН (.env.local)."
    echo "  Cross-module reads вернут фейковые данные."
    echo "  Перезапусти контейнеры: docker compose down && docker compose up -d"
    ;;

  off)
    ensure_env_local
    if grep -q '^MOCK_CROSS_MODULES=' "$ENV_LOCAL"; then
      sed -i.bak 's/^MOCK_CROSS_MODULES=.*/MOCK_CROSS_MODULES=false/' "$ENV_LOCAL"
      rm -f "$ENV_LOCAL.bak"
    else
      echo "MOCK_CROSS_MODULES=false" >> "$ENV_LOCAL"
    fi
    echo "✓ Mock-режим ВЫКЛЮЧЕН."
    echo "  Cross-module reads пойдут на реальные сервисы коллег."
    echo "  Перезапусти контейнеры: docker compose down && docker compose up -d"
    ;;

  status)
    if [ -f "$ENV_LOCAL" ] && grep -q '^MOCK_CROSS_MODULES=true' "$ENV_LOCAL"; then
      echo "Mock-режим: ВКЛЮЧЁН"
    else
      echo "Mock-режим: выключен"
    fi
    ;;

  *)
    echo "Usage: $0 [on|off|status]"
    exit 1
    ;;
esac
