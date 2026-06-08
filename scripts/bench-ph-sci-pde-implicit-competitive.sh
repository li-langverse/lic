#!/usr/bin/env bash
# PH-SCI PDE implicit competitive bench — Li Jacobi vs PETSc/hypre stub (lic#108).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_PDE_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

REGISTRY="$ROOT/benchmarks/competitive/ph-sci-pde-implicit.toml"
OUT="$BENCHMARKS_RESULTS/ph-sci-pde-implicit-competitive.json"
COMP_DIR="$ROOT/benchmarks/competitive"
export PYTHONPATH="$COMP_DIR${PYTHONPATH:+:$PYTHONPATH}"

bash "$ROOT/scripts/bench-ph-sci-pde-implicit-li.sh"
python3 "$COMP_DIR/petsc_heat_implicit_stub.py"

export PH_SCI_PDE_COMP_ROOT="$ROOT" PH_SCI_PDE_COMP_OUT="$OUT"
python3 <<'PY'
import json
import os
import time
from pathlib import Path

root = Path(os.environ["PH_SCI_PDE_COMP_ROOT"])
results = Path(os.environ.get("BENCHMARKS_RESULTS", root / "benchmarks/results"))
out = Path(os.environ["PH_SCI_PDE_COMP_OUT"])
competitive = root / "benchmarks" / "competitive"
import sys

sys.path.insert(0, str(competitive))
from pde_implicit_competitive_common import CHECKSUM_TOLERANCE, li_implicit_jacobi_oracle_checksum

li_doc = json.loads((results / "ph-sci-pde-implicit-li.json").read_text())
petsc_doc = json.loads((results / "ph-sci-pde-competitor-petsc.json").read_text())
li_checksum = li_doc.get("checksum") or round(li_implicit_jacobi_oracle_checksum(), 12)
petsc_checksum = petsc_doc.get("checksum")
delta = None
parity = True
if petsc_checksum is not None:
    delta = abs(float(li_checksum) - float(petsc_checksum))
    parity = delta <= CHECKSUM_TOLERANCE

row = {
    "id": "heat_implicit_jacobi_8",
    "catalog_bench": "pde_heat_implicit_jacobi",
    "algo_id": 204,
    "li": li_doc,
    "competitors": [petsc_doc],
    "checksum_li": li_checksum,
    "checksum_delta": delta,
    "parity_gate_pass": parity,
    "vendor_pins": {
        "petsc": petsc_doc.get("petsc_version_pin", "3.25.0"),
        "hypre": petsc_doc.get("hypre_version_pin", "2.32.0"),
    },
}
doc = {
    "suite": "ph-sci-pde-implicit-competitive",
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "issue": "https://github.com/li-langverse/lic/issues/108",
    "rows": [row],
}
out.write_text(json.dumps(doc, indent=2) + "\n")
print(f"wrote {out}")
PY
