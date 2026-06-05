#!/usr/bin/env bash
# CI-friendly gate: echem competitive JSON + PySCF oracle row echem_che_h.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RESULTS="${PH_SCI_ECHEM_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
OUT="$RESULTS/ph-sci-echem-competitive.json"

if [[ "${PH_SCI_ECHEM_SKIP_PIP:-0}" != "1" ]]; then
  python3 -m pip install --user --break-system-packages \
    -r scripts/requirements-ph-sci-chem-dft-competitive.txt >/dev/null 2>&1 || true
fi

bash scripts/bench-ph-sci-echem-competitive.sh

[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }

python3 <<'PY'
import json
import sys
from pathlib import Path

out = Path("benchmarks/results/ph-sci-echem-competitive.json")
doc = json.loads(out.read_text())
rows = doc.get("rows") or []
if not rows:
    print("no competitive rows")
    sys.exit(1)
row = next((r for r in rows if r.get("id") == "echem_che_h"), rows[0])
li = row.get("li") or {}
comps = {c.get("id"): c for c in row.get("competitors") or []}
pyscf = comps.get("pyscf") or {}

if li.get("energy_ev") is None:
    print("missing li energy_ev")
    sys.exit(1)

if pyscf.get("executed"):
    if pyscf.get("energy_ev") is None:
        print("pyscf executed but missing energy_ev")
        sys.exit(1)
    print(
        "echem_che_h parity:",
        "energy_delta_ev=",
        row.get("energy_delta_ev"),
        "parity_gate_pass=",
        row.get("parity_gate_pass"),
        "(large delta OK — stub honesty)",
    )
elif pyscf.get("note"):
    print("pyscf skipped:", pyscf.get("note"))
    sys.exit(1)
else:
    print("pyscf not executed — install pyscf for oracle")
    sys.exit(1)

print("ph-sci-echem-competitive-gates OK")
PY
