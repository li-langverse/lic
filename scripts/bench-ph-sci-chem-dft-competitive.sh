#!/usr/bin/env bash
# PH-SCI chem DFT competitive bench — Li mini STO-3G scaffold vs PySCF/Psi4 (ORCA external-only).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_CHEM_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_SCI_CHEM_COMP_INNER=1 BENCHMARKS_ROOT='${BENCHMARKS_ROOT:-}' LIC=./build-wsl/compiler/lic/lic CC=clang-22 CXX=clang++-22 && bash scripts/bench-ph-sci-chem-dft-competitive.sh"
}

if [[ "${PH_SCI_CHEM_COMP_INNER:-0}" != "1" ]] \
  && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] \
  && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

REGISTRY="$ROOT/benchmarks/competitive/ph-sci-chem-dft.toml"
OUT="$BENCHMARKS_RESULTS/ph-sci-chem-dft-competitive.json"
COMP_DIR="$ROOT/benchmarks/competitive"
export PYTHONPATH="$COMP_DIR${PYTHONPATH:+:$PYTHONPATH}"

bash "$ROOT/scripts/bench-ph-sci-chem-dft-li.sh"

export PH_SCI_CHEM_PYSCF_OUT="$BENCHMARKS_RESULTS/ph-sci-chem-competitor-pyscf.json"
export PH_SCI_CHEM_PSI4_OUT="$BENCHMARKS_RESULTS/ph-sci-chem-competitor-psi4.json"
python3 "$COMP_DIR/pyscf_sto3g_h_energy.py"
python3 "$COMP_DIR/psi4_sto3g_h_energy.py" || true

export PH_SCI_CHEM_COMP_ROOT="$ROOT" PH_SCI_CHEM_COMP_OUT="$OUT" PH_SCI_CHEM_COMP_REGISTRY="$REGISTRY"
python3 <<'PY'
import json
import os
import sys
import time
from pathlib import Path

root = Path(os.environ["PH_SCI_CHEM_COMP_ROOT"])
results = Path(os.environ.get("BENCHMARKS_RESULTS", root / "benchmarks/results"))
out = Path(os.environ["PH_SCI_CHEM_COMP_OUT"])
registry = os.environ["PH_SCI_CHEM_COMP_REGISTRY"]
competitive = root / "benchmarks" / "competitive"
sys.path.insert(0, str(competitive))
from chem_dft_competitive_common import (
    ATOM,
    BASIS,
    ENERGY_TOLERANCE_HARTREE,
    XC,
    li_scaffold_energy_hartree,
)


def load(name: str) -> dict:
    p = results / name
    return json.loads(p.read_text()) if p.is_file() else {}


def li_row(src: dict, wc: str) -> dict:
    li_sec = src.get("cpu_sec")
    return {
        "id": "li",
        "incumbent": "Li native (li-chem mini STO-3G scaffold)",
        "workload_class": wc,
        "executed": bool(src.get("executed")),
        "cpu_sec": li_sec,
        "energy_hartree": src.get("energy_hartree") or round(li_scaffold_energy_hartree(), 12),
        "energy_source": src.get("energy_source", "li_scaffold_python_mirror"),
        "validity_gate_pass": bool(src.get("validity_gate_pass")),
        "validity_ratio": 1.0 if src.get("validity_gate_pass") else 0.0,
        "ratio_vs_li": 1.0,
        "device": "cpu",
        "workload": src.get("workload"),
    }


def comp_row(src: dict | None, li_sec, cid: str, inc: str, wc: str, note: str) -> dict:
    csec = (src or {}).get("cpu_sec")
    ratio = None
    if li_sec and csec and float(li_sec) > 0:
        ratio = round(float(csec) / float(li_sec), 6)
    return {
        "id": cid,
        "incumbent": inc,
        "workload_class": wc,
        "executed": bool((src or {}).get("executed")),
        "cpu_sec": csec,
        "energy_hartree": (src or {}).get("energy_hartree"),
        "validity_gate_pass": (src or {}).get("validity_gate_pass"),
        "validity_ratio": (src or {}).get("validity_ratio"),
        "ratio_vs_li": ratio,
        "note": (src or {}).get("note") or note,
        "framework_version": (src or {}).get("framework_version"),
        "license": (src or {}).get("license"),
        "device": (src or {}).get("device", "cpu"),
        "workload": (src or {}).get("workload"),
    }


li = load("ph-sci-chem-dft-li.json")
pyscf = load("ph-sci-chem-competitor-pyscf.json")
psi4 = load("ph-sci-chem-competitor-psi4.json")
li_sec = li.get("cpu_sec")
li_e = li_row(li, "pilot").get("energy_hartree")
ref_e = pyscf.get("energy_hartree") if pyscf.get("executed") else None
delta = None
parity_pass = None
if li_e is not None and ref_e is not None:
    delta = round(float(li_e) - float(ref_e), 12)
    parity_pass = abs(delta) <= ENERGY_TOLERANCE_HARTREE

rows = [
    {
        "id": "sto3g_h_energy",
        "kernel": "chem.dft_energy_kernel_hartree",
        "workload_class": "pilot",
        "workload_note": (
            "H atom @ origin; Li 8-point radial mini STO-3G + LDA grid vs PySCF RKS/LDA STO-3G"
        ),
        "geometry": ATOM,
        "basis": BASIS,
        "xc": XC,
        "energy_tolerance_hartree": ENERGY_TOLERANCE_HARTREE,
        "energy_delta_hartree": delta,
        "parity_gate_pass": parity_pass,
        "parity_note": (
            "Li scaffold is not full Gaussian-basis DFT — large delta expected until CHEM-04 parity"
        ),
        "executed": bool(li.get("executed")) or bool(pyscf.get("executed")),
        "li": li_row(li, "pilot"),
        "competitors": [
            comp_row(
                pyscf,
                li_sec,
                "pyscf",
                "PySCF RKS/LDA",
                "oss_oracle",
                "Apache-2.0 primary reference",
            ),
            comp_row(
                psi4,
                li_sec,
                "psi4",
                "Psi4 RKS/SVWN",
                "oss_oracle_optional",
                "LGPL optional when installed",
            ),
            {
                "id": "orca",
                "incumbent": "ORCA RKS/LDA",
                "workload_class": "external_manual",
                "executed": False,
                "cpu_sec": None,
                "energy_hartree": None,
                "validity_gate_pass": None,
                "validity_ratio": None,
                "ratio_vs_li": None,
                "license": "academic-free-not-redistributable",
                "note": (
                    "NOT bundled in CI — user-run oracle; import JSON or see "
                    "benchmarks/competitive/README-chem-dft.md"
                ),
                "device": "cpu",
                "workload": "sto3g_h_lda_energy",
            },
        ],
    }
]

out.write_text(
    json.dumps(
        {
            "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "suite": "ph-sci-chem-dft-competitive",
            "registry_path": registry,
            "registry_schema": "li_ph_sci_chem_dft_competitive_v1",
            "rows": rows,
        },
        indent=2,
    )
    + "\n",
)
print(out)
PY
echo "bench-ph-sci-chem-dft-competitive: done"
