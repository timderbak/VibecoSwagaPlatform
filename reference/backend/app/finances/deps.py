"""Dependency injection переключатель — реальные сервисы или моки.

Используется в service.py:
    from app.finances.deps import get_user_lookup, get_project_lookup

При MOCK_CROSS_MODULES=true вызовы возвращают моки. При false — реальные
сервисы коллег. Это позволяет Mode B — работать в своей ветке без
зависимости от прогресса других модулей (см. playbook 12).
"""

from app.core.config import settings
from app.finances._mocks import mock_get_project_by_id, mock_get_user_by_id
from app.profile.service import get_user_by_id as real_get_user_by_id
from app.projects.service import get_project_by_id as real_get_project_by_id


def get_user_lookup():
    """Возвращает функцию для чтения User. Mock или real по env."""
    return mock_get_user_by_id if settings.MOCK_CROSS_MODULES else real_get_user_by_id


def get_project_lookup():
    """Возвращает функцию для чтения Project. Mock или real по env."""
    return mock_get_project_by_id if settings.MOCK_CROSS_MODULES else real_get_project_by_id
