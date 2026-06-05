#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
LIB="$PL/data/library.json"
python3 - "$LIB" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
by_id = {e["id"]: e for e in data.get("entries") or []}
for sid in ("std_add_comm", "std_dot4_bilinear_right", "std_dot4_comm", "std_mul_assoc", "std_triangle_ineq_scalar"):
    row = by_id.get(sid)
    if not row:
        raise SystemExit(f"wp-pl-04: missing {sid}")
    impls = (row.get("drilldown") or {}).get("implementations") or []
    if not any(i.get("role") == "lean_formal" for i in impls):
        raise SystemExit(f"wp-pl-04: {sid} no lean_formal")
print("wp-pl-04-stdlib-drilldown: OK")
PY
