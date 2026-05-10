from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    PROJECT_NAME: str = "VibecoSwaga"
    VERSION: str = "0.1.0"
    API_V1_STR: str = "/api/v1"

    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@postgres:5432/app"

    JWT_SECRET: str = "change-me-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRE_MINUTES: int = 60 * 24

    ENVIRONMENT: str = "development"

    # Mode B (isolated development) — см. playbook 12.
    # При true cross-module reads возвращают фейковые данные через _mocks.py.
    MOCK_CROSS_MODULES: bool = False


settings = Settings()
