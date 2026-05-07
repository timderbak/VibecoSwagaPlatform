# Playbook 05 — Skeleton

Цель: собрать пустой каркас всего проекта, который проходит CI зелёным и готов к параллельной разработке.

## Когда запускается
- После `playbook 04-contracts.md`.
- Вручную: `/skeleton`.

## Что нужно создать

### Backend

- `backend/app/api/__init__.py` — собирает все роутеры:
  ```python
  from fastapi import APIRouter
  from app.api import projects, billing, auth
  api_router = APIRouter()
  api_router.include_router(projects.router)
  api_router.include_router(billing.router)
  api_router.include_router(auth.router)
  ```

- `backend/app/main.py`:
  ```python
  from fastapi import FastAPI
  from app.api import api_router
  from app.core.config import settings

  app = FastAPI(title=settings.PROJECT_NAME)
  app.include_router(api_router, prefix="/api")

  @app.get("/health")
  async def health():
      return {"status": "ok"}
  ```

- Все эндпоинты слайсов уже есть с `NotImplementedError` (созданы на /contracts).

### Frontend

- `frontend/app/layout.tsx`, `frontend/app/page.tsx` — корневые.
- `frontend/app/<slice>/page.tsx` для каждого слайса — placeholder:
  ```tsx
  export default function ProjectsPage() {
    return <div>Projects — WP pending</div>;
  }
  ```

### Тесты

- `backend/tests/integration/test_health.py`:
  ```python
  async def test_health(client):
      r = await client.get("/health")
      assert r.status_code == 200
      assert r.json() == {"status": "ok"}
  ```

- Для каждого слайса — пустой `tests/integration/<slice>/__init__.py`.

### CI должен пройти зелёным

```yaml
# .github/workflows/ci.yml
- run: docker compose -f docker-compose.test.yml up -d
- run: docker compose -f docker-compose.test.yml exec -T backend pytest
- run: docker compose -f docker-compose.test.yml exec -T frontend npm test
```

`pytest` запустится на скелете и пройдёт (только тест health). `npm test` — пустые suite'ы.

## Локальная проверка

```bash
docker compose up -d
curl http://localhost:8000/health        # {"status": "ok"}
curl http://localhost:8000/docs          # OpenAPI UI с эндпоинтами
docker compose down
```

## Коммит

`feat: skeleton — all stubs in place, CI green`

## После завершения

Скажи команде:
> «Скелет собран, CI зелёный. Каждый дев теперь делает `vibeco join <repo-url>`, выбирает свой номер, и начинает работать в своей зоне через TDD. Контракты заморожены — менять только через RFC-PR.»
