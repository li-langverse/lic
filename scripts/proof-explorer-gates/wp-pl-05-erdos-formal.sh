#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
LIB="$PL/data/library.json"
python3 - "$LIB" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
erdos = [e for e in data.get("entries") or [] if e.get("field") == "erdos"]
if not erdos:
    raise SystemExit("wp-pl-05: no erdos rows")
sample = erdos[0]
impls = (sample.get("drilldown") or {}).get("implementations") or []
roles = {i.get("role") for i in impls}
if "formal_statement" not in roles:
    raise SystemExit("wp-pl-05: E-1 missing formal_statement")
with_stmt = sum(
    1
    for e in erdos
    if any(i.get("role") == "formal_statement" for i in (e.get("drilldown") or {}).get("implementations") or [])
)
if with_stmt < len(erdos) * 0.9:
    raise SystemExit(f"wp-pl-05: only {with_stmt}/{len(erdos)} have formal_statement")
print(f"wp-pl-05-erdos-formal: OK ({with_stmt}/{len(erdos)})")
PY
