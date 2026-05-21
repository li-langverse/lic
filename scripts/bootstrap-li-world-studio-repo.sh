#!/usr/bin/env bash
# Deprecated alias — use bootstrap-li-studio-app-repo.sh
echo "Note: li-world-studio was renamed to li-studio-app (see docs/ecosystem/studio-naming.md)" >&2
exec "$(dirname "$0")/bootstrap-li-studio-app-repo.sh" "$@"
