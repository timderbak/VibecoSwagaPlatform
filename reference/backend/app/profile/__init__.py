"""Profile module — owner User и аутентификации.

Внешний публичный API модуля (то, что могут импортировать другие модули):
  - app.shared.schemas.UserRead — публичная схема (в общей зоне)
  - app.profile.service.get_user_by_id — read через сервис
  - app.profile.dependencies.get_current_user — auth dependency

Внутренние детали (НЕ импортировать из других модулей):
  - app.profile.models.User — SQLAlchemy-модель (приватная)
  - app.profile.api.* — эндпоинты (приватные, видны через router)
  - app.profile._password — хэш паролей
"""
