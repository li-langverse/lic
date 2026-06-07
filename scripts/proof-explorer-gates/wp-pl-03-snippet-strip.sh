#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
[[ -n "$PL" ]] || exit 1
python3 "$PL/scripts/check-no-proc-in-library.py"
bash "$PL/scripts/check-library-quality.sh"
echo "wp-pl-03-snippet-strip: OK"
