#!/usr/bin/env bash
# Генерирует TS-типы из текущего OpenAPI бэкенда.
# Запускается из контракта-агента и после каждого изменения схем.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "→ Starting backend to fetch OpenAPI..."
cd "$ROOT"
docker compose up -d backend postgres
sleep 5

echo "→ Fetching openapi.json..."
curl -sf http://localhost:8000/api/v1/openapi.json -o /tmp/openapi.json

echo "→ Freezing contract snapshot..."
mkdir -p docs/contracts
cp /tmp/openapi.json docs/contracts/openapi.json

echo "→ Generating TS types..."
cd "$ROOT/frontend"
npx -y openapi-typescript /tmp/openapi.json -o lib/api/types.ts

echo "✓ TS types regenerated at frontend/lib/api/types.ts"
echo "✓ Frozen contract snapshot at docs/contracts/openapi.json"
