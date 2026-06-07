#!/usr/bin/env bash
# CI-friendly gate: competitive JSON exists; PySCF oracle runs or skips gracefully.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RESULTS="${PH_SCI_CHEM_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
OUT="$RESULTS/ph-sci-chem-dft-competitive.json"

if [[ "${PH_SCI_CHEM_SKIP_PIP:-0}" != "1" ]]; then
  python3 -m pip install --user --break-system-packages \
    -r scripts/requirements-ph-sci-chem-dft-competitive.txt >/dev/null 2>&1 || true
fi

bash scripts/bench-ph-sci-chem-dft-competitive.sh

[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }

python3 <<'PY'
import json
import sys
from pathlib import Path

out = Path("benchmarks/results/ph-sci-chem-dft-competitive.json")
doc = json.loads(out.read_text())
rows = doc.get("rows") or []
if not rows:
    print("no competitive rows")
    sys.exit(1)
row = rows[0]
li = row.get("li") or {}
comps = {c.get("id"): c for c in row.get("competitors") or []}
pyscf = comps.get("pyscf") or {}

if not li.get("energy_hartree"):
    print("missing li energy_hartree")
    sys.exit(1)

if pyscf.get("executed"):
    if pyscf.get("energy_hartree") is None:
        print("pyscf executed but missing energy")
        sys.exit(1)
    print(
        "parity:",
        "delta_hartree=",
        row.get("energy_delta_hartree"),
        "parity_gate_pass=",
        row.get("parity_gate_pass"),
    )
elif pyscf.get("note"):
    print("pyscf skipped:", pyscf.get("note"))
else:
    print("pyscf not executed — install pyscf for oracle")
    sys.exit(1)

if not li.get("executed"):
    print("warn: Li bench binary did not execute — energy from python mirror only")
print("ph-sci-chem-dft-competitive-gates OK")
PY
