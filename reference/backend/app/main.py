from fastapi import FastAPI

from app.core.config import settings
from app.profile.api import router as profile_router
from app.projects.api import router as projects_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
)

# Регистрация роутеров модулей (каждый Dev добавляет свой при /module-init).
app.include_router(profile_router, prefix=settings.API_V1_STR)
app.include_router(projects_router, prefix=settings.API_V1_STR)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
