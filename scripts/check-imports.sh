#!/usr/bin/env bash
# check-imports.sh — Pre-commit hook (часть): запрещает импорт приватной
# реализации одного модуля из другого модуля.
#
# Разрешено:
#   from app.shared.schemas import UserRead         ← shared всегда OK
#   from app.shared.enums import Role               ← shared всегда OK
#   from app.profile.service import get_user_by_id  ← service.* — публичный API
#   from app.profile.dependencies import get_current_user
#
# Запрещено (внутренняя реализация):
#   from app.profile.models import User             ← models.* — private
#   from app.profile._password import hash_password ← _xxx — private
#   from app.profile.api import router              ← api.* импортируется только в main.py
#
# Применяется ТОЛЬКО к staged файлам, которые в `backend/app/<module>/`.
# Импорты внутри своего модуля разрешены.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

STAGED=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '^backend/app/[a-z_]+/' | grep -v '^backend/app/shared/' | grep -v '^backend/app/core/' | grep '\.py$' || true)

if [ -z "$STAGED" ]; then
    exit 0
fi

VIOLATIONS=()
for FILE in $STAGED; do
    OWN_MODULE=$(echo "$FILE" | awk -F/ '{print $3}')

    # Ищем "from app.<other_module>.models" / "from app.<other_module>._xxx" / "from app.<other_module>.api"
    while IFS= read -r LINE; do
        if [[ "$LINE" =~ ^from\ app\.([a-z_]+)\.(models|api|_[a-z_]+) ]]; then
            OTHER_MODULE="${BASH_REMATCH[1]}"
            FORBIDDEN_SUBPATH="${BASH_REMATCH[2]}"
            if [ "$OTHER_MODULE" != "$OWN_MODULE" ] && [ "$OTHER_MODULE" != "shared" ] && [ "$OTHER_MODULE" != "core" ]; then
                VIOLATIONS+=("$FILE: импорт приватной реализации '$OTHER_MODULE.$FORBIDDEN_SUBPATH' из чужого модуля")
            fi
        fi
    done < "$FILE"
done

if [ ${#VIOLATIONS[@]} -gt 0 ]; then
    echo "❌ Нарушение module-инкапсуляции:"
    for V in "${VIOLATIONS[@]}"; do
        echo "   $V"
    done
    echo ""
    echo "   Разрешённые публичные импорты другого модуля:"
    echo "     from app.<other>.service import ...        # service.* публичный"
    echo "     from app.<other>.dependencies import ...   # dependencies.* публичный"
    echo "     from app.shared.schemas import ...         # shared всегда OK"
    echo ""
    echo "   Если нужна приватная реализация — попроси Claude:"
    echo "     'добавь публичный метод X в service другого модуля и импортируй его'"
    echo "   Это будет cross-zone request к owner'у того модуля."
    exit 1
fi

exit 0
