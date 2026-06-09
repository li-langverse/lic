#!/usr/bin/env bash
# Patch tier5 bench_http TLS DHE probe until benchmarks vendor picks up the fix.
# Python 3.11+ subprocess rejects bytes stdin when text=True.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

rel="vendor/lis-tier5/benchmarks/tier5_http/harness/bench_http.py"
f="$BENCHMARKS_ROOT/$rel"
[[ -f "$f" ]] || exit 0

python3 - "$f" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
old = '            input=b"",\n            capture_output=True,\n            text=True,'
new = '            input="",\n            capture_output=True,\n            text=True,'
if old not in text:
    if new.splitlines()[0] in text:
        sys.exit(0)
    sys.exit(0)
path.write_text(text.replace(old, new, 1), encoding="utf-8")
print(f"patched {path}")
PY
