#!/usr/bin/env bash
# CI-friendly gate: MD competitive JSON exists; Li oracle valid; external columns stub-honest.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RESULTS="${PH_SCI_MD_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
OUT="$RESULTS/ph-sci-md-competitive.json"

bash scripts/bench-ph-sci-md-competitive.sh

[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }

python3 <<'PY'
import json
import sys
from pathlib import Path

out = Path("benchmarks/results/ph-sci-md-competitive.json")
doc = json.loads(out.read_text())
rows = doc.get("rows") or []
if not rows:
    print("no competitive rows")
    sys.exit(1)
row = rows[0]
li = row.get("li") or {}
comps = {c.get("id"): c for c in row.get("competitors") or []}
lammps = comps.get("lammps") or {}
gromacs = comps.get("gromacs") or {}

if li.get("energy_drift") is None:
    print("missing li energy_drift")
    sys.exit(1)

drift = float(li["energy_drift"])
if not (0.0 <= drift < 0.001):
    print("li drift out of tier-2 range:", drift)
    sys.exit(1)

for cid, comp in ("lammps", lammps), ("gromacs", gromacs):
    if comp.get("reference_energy_drift") is None:
        print(f"missing {cid} reference_energy_drift")
        sys.exit(1)
    if comp.get("executed"):
        print(f"{cid} unexpectedly executed in stub mode")
        sys.exit(1)
    print(f"{cid} stub:", comp.get("note", "")[:80])

print("li drift:", drift, "parity_gate_pass:", row.get("parity_gate_pass"))
print("ph-sci-md-competitive-gates OK")
PY
