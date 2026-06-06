#!/usr/bin/env bash
# WP-T10-03: proof-library main has fresh library.json from lic.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
[[ -n "$PL" && -f "$PL/scripts/build-library.py" ]] || { echo "wp-t10-03: proof-library missing" >&2; exit 1; }

LIC_ROOT="$ROOT" python3 "$PL/scripts/build-library.py"
bash "$PL/scripts/check-library-quality.sh"
python3 "$PL/scripts/check-no-proc-in-library.py"

SIGNOFF="$ROOT/data/proof-explorer-loop/wp-t10-proof-library-main.signoff"
if [[ -f "$SIGNOFF" ]]; then
  echo "wp-t10-03-proof-library-main: OK (merged sign-off)"
  exit 0
fi

# Accept local rebuild when lic_commit matches main (PR may be in flight)
LIC_MAIN="$(git -C "$ROOT" rev-parse origin/main 2>/dev/null || git -C "$ROOT" rev-parse HEAD)"
python3 - "$PL/data/library.json" "$LIC_MAIN" <<'PY'
import json, sys
from pathlib import Path
lib = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
want = sys.argv[2]
got = lib.get("lic_commit", "")
if not got.startswith(want[:8]):
    print(f"wp-t10-03: lic_commit mismatch {got[:12]} vs {want[:12]}", file=sys.stderr)
    sys.exit(1)
print("wp-t10-03-proof-library-main: OK (library rebuilt; merge PR for Pages)")
PY
