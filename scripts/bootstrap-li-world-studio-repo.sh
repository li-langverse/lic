#!/usr/bin/env bash
# Deprecated alias — use bootstrap-li-studio-app-repo.sh
echo "Note: use studio-app (app) and studio / studio.ai (packages). See docs/ecosystem/studio-naming.md" >&2
exec "$(dirname "$0")/bootstrap-li-studio-app-repo.sh" "$@"
