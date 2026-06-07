#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
LIB="$PL/data/library.json"
[[ -f "$LIB" ]] || { echo "wp-pl-02: no library.json" >&2; exit 1; }
python3 - "$LIB" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
by = data.get("summary", {}).get("by_lean_status") or {}
unknown = by.get("unknown", 0)
total = data.get("summary", {}).get("total") or 1
if unknown / total > 0.5:
    print(f"wp-pl-02: too many unknown {unknown}/{total}", file=sys.stderr)
    sys.exit(1)
scan = data.get("sources", {}).get("lean_scan") or []
if len(scan) < 10:
    print(f"wp-pl-02: lean_scan too short ({len(scan)})", file=sys.stderr)
    sys.exit(1)
print(f"wp-pl-02-lean-scan: OK (unknown={unknown}/{total}, sources={len(scan)})")
PY
