#!/usr/bin/env bash
# WP-T10-01: library.json lic_commit matches lic origin/main HEAD.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
[[ -n "$PL" && -f "$PL/data/library.json" ]] || { echo "wp-t10-01: proof-library missing" >&2; exit 1; }

LIC_MAIN="$(git -C "$ROOT" rev-parse origin/main 2>/dev/null || git -C "$ROOT" rev-parse HEAD)"
LIC_HEAD="$(git -C "$ROOT" rev-parse HEAD)"
python3 - "$PL/data/library.json" "$LIC_MAIN" "$LIC_HEAD" <<'PY'
import json, sys
from pathlib import Path
lib = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
main_ref, head_ref = sys.argv[2], sys.argv[3]
got = lib.get("lic_commit", "")
ok = got.startswith(main_ref[:8]) or got.startswith(head_ref[:8])
if not ok:
    print(f"wp-t10-01: lic_commit={got[:12]} want main={main_ref[:12]} or head={head_ref[:12]}", file=sys.stderr)
    sys.exit(1)
div = sum(1 for e in lib.get("entries") or [] if e.get("diverges"))
unk = sum(1 for e in lib.get("entries") or [] if (e.get("lean_status") or "") == "unknown")
print(f"wp-t10-01-site-sync: OK lic_commit={got[:8]} divergent={div} unknown={unk}")
if div != 0 or unk != 0:
    sys.exit(1)
PY
python3 "$PL/scripts/check-no-proc-in-library.py"
echo "wp-t10-01-site-sync: OK"
