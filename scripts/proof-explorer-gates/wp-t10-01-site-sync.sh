#!/usr/bin/env bash
# WP-T10-01: library.json lic_commit matches lic origin/main HEAD.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=_lib.sh
source "$(dirname "$0")/_lib.sh"

PL="$(pe_resolve_proof_library "$ROOT" || true)"
[[ -n "$PL" && -f "$PL/data/library.json" ]] || {
  echo "wp-t10-01: proof-library missing (set PROOF_LIBRARY_ROOT or clone ../proof-library)" >&2
  exit 1
}

LIC_MAIN="$(pe_resolve_lic_main_sha "$ROOT")"
pe_check_library_lic_commit "wp-t10-01" "$PL/data/library.json" "$LIC_MAIN"

python3 - "$PL/data/library.json" <<'PY'
import json
import sys
from pathlib import Path

lib = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
div = sum(1 for e in lib.get("entries") or [] if e.get("diverges"))
unk = sum(1 for e in lib.get("entries") or [] if (e.get("lean_status") or "") == "unknown")
got = lib.get("lic_commit") or ""
print(f"wp-t10-01-site-sync: OK lic_commit={got[:8]} divergent={div} unknown={unk}")
if div != 0 or unk != 0:
    sys.exit(1)
PY

python3 "$PL/scripts/check-no-proc-in-library.py"
echo "wp-t10-01-site-sync: OK"
