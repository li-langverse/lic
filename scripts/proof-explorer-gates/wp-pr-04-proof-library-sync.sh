#!/usr/bin/env bash
# WP-PR-04: proof-library rebuild + lic_commit sync + quality checks.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
[[ -n "$PL" && -d "$PL/.git" ]] || { echo "wp-pr-04: proof-library clone missing" >&2; exit 1; }

LIC_MAIN="$(git -C "$ROOT" rev-parse origin/main 2>/dev/null || git -C "$ROOT" rev-parse HEAD)"
LIC_ROOT="$ROOT" python3 "$PL/scripts/build-library.py"

python3 - "$PL/data/library.json" "$LIC_MAIN" <<'PY'
import json, sys
from pathlib import Path
lib = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
want = sys.argv[2]
got = lib.get("lic_commit") or ""
if not isinstance(got, str) or not got.startswith(want[:8]):
    print(f"wp-pr-04: lic_commit={got[:12] if got else '?'} want {want[:12]}", file=sys.stderr)
    sys.exit(1)
div = sum(1 for e in lib.get("entries") or [] if e.get("diverges"))
unk = sum(1 for e in lib.get("entries") or [] if (e.get("lean_status") or "") == "unknown")
if div != 0 or unk != 0:
    print(f"wp-pr-04: divergent={div} unknown={unk}", file=sys.stderr)
    sys.exit(1)
print(f"wp-pr-04-proof-library-sync: OK lic_commit={got[:8]} divergent={div}")
PY

bash "$PL/scripts/check-library-quality.sh"
python3 "$PL/scripts/check-no-proc-in-library.py"
echo "wp-pr-04-proof-library-sync: OK"
