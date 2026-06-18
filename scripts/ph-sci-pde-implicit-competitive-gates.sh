#!/usr/bin/env bash
# CI-friendly gate: competitive JSON exists; Li checksum + PETSc stub skip OK.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="${PH_SCI_PDE_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}/ph-sci-pde-implicit-competitive.json"

bash scripts/bench-ph-sci-pde-implicit-competitive.sh
[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }

python3 <<'PY'
import json
import sys
from pathlib import Path

out = Path("benchmarks/results/ph-sci-pde-implicit-competitive.json")
doc = json.loads(out.read_text())
rows = doc.get("rows") or []
if not rows:
    print("no competitive rows")
    sys.exit(1)
row = rows[0]
li = row.get("li") or {}
if not row.get("checksum_li"):
    print("missing checksum_li")
    sys.exit(1)
if not li.get("checksum"):
    print("missing li checksum")
    sys.exit(1)
pins = row.get("vendor_pins") or {}
if pins.get("petsc") != "3.25.0":
    print("unexpected petsc pin", pins.get("petsc"))
    sys.exit(1)
if pins.get("hypre") != "2.32.0":
    print("unexpected hypre pin", pins.get("hypre"))
    sys.exit(1)
comps = row.get("competitors") or []
petsc = comps[0] if comps else {}
if petsc.get("note"):
    print("petsc:", petsc.get("note"))
print("ph-sci-pde-implicit-competitive-gates OK")
PY
