#!/usr/bin/env bash
# WP-AX-09: proof-library library.json exists (rebuild when proof-library checkout present).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
if [[ -n "$PL" && -f "$PL/scripts/build-library.py" ]]; then
  LIC_ROOT="$ROOT" python3 "$PL/scripts/build-library.py" || exit 1
  test -f "$PL/data/library.json"
  echo "wp-ax-09-rebuild-library-json: OK (rebuilt)"
  exit 0
fi

if [[ -f "$ROOT/../proof-library/data/library.json" ]]; then
  echo "wp-ax-09-rebuild-library-json: OK (existing library.json)"
  exit 0
fi

echo "wp-ax-09: proof-library/data/library.json missing" >&2
exit 1
