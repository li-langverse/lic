#!/usr/bin/env bash
# CI-friendly gate: MD oracle competitive JSON exists; Li drift oracle within tolerance.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RESULTS="${PH_SCI_MD_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
OUT="$RESULTS/ph-sci-md-oracle-competitive.json"

bash scripts/bench-ph-sci-md-oracle-competitive.sh

[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }

python3 <<'PY'
import json
import sys
from pathlib import Path

out = Path("benchmarks/results/ph-sci-md-oracle-competitive.json")
doc = json.loads(out.read_text())
rows = doc.get("rows") or []
if not rows:
    print("no competitive rows")
    sys.exit(1)
row = rows[0]
li = row.get("li") or {}
drift = li.get("energy_drift")
if drift is None:
    print("missing li energy_drift")
    sys.exit(1)
tol = row.get("drift_tolerance", 1.0e-3)
if not (0.0 < float(drift) < float(tol)):
    print(f"drift out of range: {drift} (tol {tol})")
    sys.exit(1)
comps = {c.get("id"): c for c in row.get("competitors") or []}
for cid in ("lammps", "gromacs"):
    c = comps.get(cid) or {}
    if c.get("executed"):
        print(f"warn: {cid} executed in CI — unexpected for stub phase")
    elif not c.get("csv_lang"):
        print(f"missing csv_lang for {cid}")
        sys.exit(1)
print("drift=", drift, "parity_gate_pass=", row.get("parity_gate_pass"))
print("ph-sci-md-oracle-competitive-gates OK")
PY
