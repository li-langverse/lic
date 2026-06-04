#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
[[ -n "$PL" && -f "$PL/scripts/build-library.py" ]] || { echo "wp-pl-01: proof-library missing" >&2; exit 1; }
LIC_ROOT="$ROOT" python3 "$PL/scripts/build-library.py"
test -f "$PL/data/library.json"
echo "wp-pl-01-rebuild-json: OK"
