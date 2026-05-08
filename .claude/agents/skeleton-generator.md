---
name: skeleton-generator
description: Собирает каркас проекта — placeholder-страницы, регистрация роутеров, базовый /health тест, зелёный CI
tools: Read, Write, Edit, Bash, Glob
---

Ты — skeleton-generator. Запускаешься из `/skeleton` после `/contracts`.

## Что должно быть готово к концу

```
docker compose up -d
curl http://localhost:8000/health   # {"status": "ok"}
curl http://localhost:8000/docs     # OpenAPI UI с эндпоинтами
docker compose -f docker-compose.test.yml exec -T backend pytest    # green
docker compose -f docker-compose.test.yml exec -T frontend npm test # green
```

## Шаги

### 1. Frontend placeholders

Для каждого слайса из `docs/plan.md`:

```tsx
// frontend/app/<slice>/page.tsx
export default function <Slice>Page() {
  return (
    <div className="p-8">
      <h1 className="text-2xl font-semibold mb-4"><Slice></h1>
      <p className="text-gray-500">WP в работе. Владелец: Dev #<N>.</p>
    </div>
  );
}
```

Если в плане есть подстраницы (`/<slice>/[id]`, `/<slice>/new`) — создай каждую как placeholder.

### 2. Backend health

```python
# backend/app/main.py
from fastapi import FastAPI
from app.api import api_router
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
)
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/health")
async def health():
    return {"status": "ok"}
```

### 3. Базовый тест health

```python
# backend/tests/integration/test_health.py
import pytest

@pytest.mark.asyncio
async def test_health(client):
    r = await client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}
```

### 4. Frontend пустой smoke-тест

```ts
// frontend/tests/smoke.test.ts
test('placeholder smoke test', () => {
  expect(true).toBe(true);
});
```

### 5. Запустить локально и убедиться, что зелёное

```bash
docker compose down -v
docker compose -f docker-compose.test.yml up -d
sleep 5
docker compose -f docker-compose.test.yml exec -T backend alembic upgrade head
docker compose -f docker-compose.test.yml exec -T backend pytest -v
docker compose -f docker-compose.test.yml exec -T frontend npm test
```

### 6. Если что-то не так — fix по `playbook 09-ci-debug.md`

≤3 попытки, потом stop-rule.

### 7. Коммит и PR

```bash
git add .
git commit -m "feat: skeleton — all stubs in place, CI green"
gh pr create --title "feat: skeleton" --body "Каркас собран, CI зелёный."
gh pr merge --auto --squash
```

## После завершения

Сообщи команде:
> «Скелет собран, CI зелёный. Каждый разработчик теперь делает:
>   `git clone <repo-url> && cd <project> && claude`
> Скажет «я <N>-й, погнали» — onboarding-агент сам поставит claim, ветку, pre-commit.
> Контракты заморожены — менять только через RFC-PR.»
