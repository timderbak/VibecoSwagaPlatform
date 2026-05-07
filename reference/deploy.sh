#!/usr/bin/env bash
# deploy.sh — Идемпотентный деплой проекта.
# Запускается локально (для деплоя на удалённый сервер) или из CI.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

# Префлайт
if [ ! -f .env ]; then
  echo "✗ .env не найден. Скопируй .env.example → .env и заполни."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "✗ Docker не установлен."
  exit 1
fi

# Сборка
echo "→ Building containers..."
docker compose -f docker-compose.yml build

# Миграции
echo "→ Running migrations..."
docker compose -f docker-compose.yml up -d postgres
sleep 5
docker compose -f docker-compose.yml run --rm backend alembic upgrade head

# Запуск
echo "→ Starting services..."
docker compose -f docker-compose.yml up -d

# Health-check
echo "→ Waiting for backend..."
for i in {1..30}; do
  if curl -sf http://localhost:8000/health >/dev/null 2>&1; then
    echo "✓ Backend healthy."
    break
  fi
  sleep 2
  if [ "$i" -eq 30 ]; then
    echo "✗ Backend не поднялся за 60 секунд. Проверь docker compose logs backend."
    exit 1
  fi
done

echo ""
echo "✓ Deploy completed."
echo "  Backend: http://localhost:8000"
echo "  Frontend: http://localhost:3000"
echo "  OpenAPI: http://localhost:8000/api/v1/openapi.json"
