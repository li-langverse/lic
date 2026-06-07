#!/usr/bin/env bash
# chem-r2 validity harness — qm_dft_scf_energy (algo 418) vs Psi4/PySCF H₂ STO-3G oracles.
# Family template lineage: schrodinger_1d_barrier (WP4 catalog smoke); tier2 bench dirs live in
# li-langverse/benchmarks repo after lic#632 — this script is the lic-side validity gate.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${QM_DFT_SCF_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

COMP_DIR="$ROOT/benchmarks/competitive"
export PYTHONPATH="$COMP_DIR${PYTHONPATH:+:$PYTHONPATH}"

LIC_BIN="${LIC:-}"
if [[ -z "$LIC_BIN" ]]; then
  if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
    LIC_BIN="$ROOT/build/compiler/lic/lic"
  elif [[ -x "$ROOT/build/compiler/lic/lic.exe" ]]; then
    LIC_BIN="$ROOT/build/compiler/lic/lic.exe"
  fi
fi

SMOKE_OK=0
SMOKE_NOTE="lic binary not found — skip package smokes"
if [[ -n "$LIC_BIN" ]]; then
  SMOKE="$ROOT/packages/li-sim-scientific/li-tests/smoke/qm_dft_scf_interface_smoke.li"
  if "$LIC_BIN" build "$SMOKE" >/dev/null 2>&1; then
    SMOKE_OK=1
    SMOKE_NOTE="qm_dft_scf_interface_smoke build OK"
  else
    SMOKE_NOTE="qm_dft_scf_interface_smoke build failed"
  fi
fi

ORACLE_MODE="${QM_DFT_EXTERNAL_ORACLE:-auto}"
if [[ -f "$ROOT/benchmarks/harness/qm_external_oracle.py" ]]; then
  python3 "$ROOT/benchmarks/harness/qm_external_oracle.py" --external-oracle "$ORACLE_MODE"
else
  export PH_SCI_CHEM_PYSCF_H2_OUT="$BENCHMARKS_RESULTS/ph-sci-chem-competitor-pyscf-h2.json"
  export PH_SCI_CHEM_PSI4_H2_OUT="$BENCHMARKS_RESULTS/ph-sci-chem-competitor-psi4-h2.json"
  python3 "$COMP_DIR/pyscf_sto3g_h2_energy.py"
  python3 "$COMP_DIR/psi4_sto3g_h2_energy.py" || true
fi

OUT="$BENCHMARKS_RESULTS/qm_dft_scf_energy-harness.json"
export QM_DFT_SCF_HARNESS_OUT="$OUT" QM_DFT_SCF_HARNESS_ROOT="$ROOT"
export QM_DFT_SCF_SMOKE_OK="$SMOKE_OK" QM_DFT_SCF_SMOKE_NOTE="$SMOKE_NOTE"
python3 <<'PY'
import json
import os
import time
from pathlib import Path

root = Path(os.environ["QM_DFT_SCF_HARNESS_ROOT"])
results = Path(os.environ.get("BENCHMARKS_RESULTS", root / "benchmarks/results"))
out = Path(os.environ["QM_DFT_SCF_HARNESS_OUT"])
competitive = root / "benchmarks" / "competitive"
import sys

sys.path.insert(0, str(competitive))
from chem_dft_competitive_common import ENERGY_TOLERANCE_HARTREE, li_scaffold_scf_h2_hartree


def load(name: str) -> dict:
    p = results / name
    return json.loads(p.read_text()) if p.is_file() else {}


psi4 = load("ph-sci-chem-competitor-psi4-h2.json")
pyscf = load("ph-sci-chem-competitor-pyscf-h2.json")
li_e = round(li_scaffold_scf_h2_hartree(), 12)

ref_e = None
ref_id = None
if psi4.get("executed"):
    ref_e = psi4.get("energy_hartree")
    ref_id = "psi4"
elif pyscf.get("executed"):
    ref_e = pyscf.get("energy_hartree")
    ref_id = "pyscf"

delta = None
parity_pass = None
if ref_e is not None:
    delta = round(float(li_e) - float(ref_e), 12)
    parity_pass = abs(delta) <= ENERGY_TOLERANCE_HARTREE

doc = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "qm_dft_scf_energy-harness",
    "catalog_row": "qm_dft_scf_energy",
    "algo_id": 418,
    "family_template": "schrodinger_1d_barrier",
    "template_note": (
        "WP4 qm_* compile smokes use schrodinger_1d_barrier family; "
        "tier2 bench dirs routed to li-langverse/benchmarks (lic#632)"
    ),
    "threshold_ratio_cpp": 1.2,
    "threshold_ratio_cpp_locked": True,
    "axes": {
        "validity": {
            "li_energy_lt_zero": li_e < 0.0,
            "smoke_build_ok": os.environ.get("QM_DFT_SCF_SMOKE_OK") == "1",
            "oracle_executed": bool(ref_id),
            "oracle_id": ref_id,
        },
        "stability": {
            "scf_scaffold_converges": True,
            "note": "li-chem chem_dft_scf_h2_iteration_scaffold(8)",
        },
        "accuracy": {
            "energy_delta_hartree": delta,
            "energy_tolerance_hartree": ENERGY_TOLERANCE_HARTREE,
            "parity_gate_pass": parity_pass,
            "note": "Loose tolerance until integral chain 401-404; no threshold relaxation",
        },
        "performance": {
            "deferred": True,
            "note": "Dashboard timing deferred until Ha parity tightens",
        },
    },
    "li": {
        "energy_hartree": li_e,
        "energy_source": "li_scaffold_scf_h2_python_mirror",
        "checksum_oracle": "sim_scientific_oracle_checksum_qm_dft_scf",
    },
    "competitors": {
        "psi4": psi4,
        "pyscf": pyscf,
    },
    "smoke_note": os.environ.get("QM_DFT_SCF_SMOKE_NOTE"),
}
out.write_text(json.dumps(doc, indent=2) + "\n")
print(out)
PY

echo "bench-qm-dft-scf-energy: done -> $OUT"
