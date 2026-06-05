#!/usr/bin/env bash
# PH-SCI electrochemistry competitive bench — Li CHE stub vs PySCF H/H2 oracle.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_ECHEM_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

REGISTRY="$ROOT/benchmarks/competitive/ph-sci-electrochemistry.toml"
OUT="$BENCHMARKS_RESULTS/ph-sci-echem-competitive.json"
COMP_DIR="$ROOT/benchmarks/competitive"
export PYTHONPATH="$COMP_DIR${PYTHONPATH:+:$PYTHONPATH}"

bash "$ROOT/scripts/bench-ph-sci-echem-li.sh"

export PH_SCI_ECHEM_PYSCF_OUT="$BENCHMARKS_RESULTS/ph-sci-echem-competitor-pyscf.json"
python3 "$COMP_DIR/pyscf_echem_che_h.py"

export PH_SCI_ECHEM_COMP_ROOT="$ROOT" PH_SCI_ECHEM_COMP_OUT="$OUT" PH_SCI_ECHEM_COMP_REGISTRY="$REGISTRY"
python3 <<'PY'
import json
import os
import sys
import time
from pathlib import Path

root = Path(os.environ["PH_SCI_ECHEM_COMP_ROOT"])
results = Path(os.environ.get("BENCHMARKS_RESULTS", root / "benchmarks/results"))
out = Path(os.environ["PH_SCI_ECHEM_COMP_OUT"])
registry = os.environ["PH_SCI_ECHEM_COMP_REGISTRY"]
competitive = root / "benchmarks" / "competitive"
sys.path.insert(0, str(competitive))
from echem_competitive_common import ENERGY_TOLERANCE_EV, REFERENCE_POTENTIAL_V


def load(name: str) -> dict:
    p = results / name
    return json.loads(p.read_text()) if p.is_file() else {}


def li_row(src: dict, wc: str) -> dict:
    return {
        "id": "li",
        "incumbent": "Li native (li-chem echem_che_h_adsorption_energy stub)",
        "workload_class": wc,
        "executed": bool(src.get("executed")),
        "cpu_sec": src.get("cpu_sec"),
        "energy_ev": src.get("energy_ev"),
        "energy_source": src.get("energy_source", "li_echem_stub_mirror"),
        "validity_gate_pass": bool(src.get("validity_gate_pass")),
        "validity_ratio": 1.0 if src.get("validity_gate_pass") else 0.0,
        "ratio_vs_li": 1.0,
        "device": "cpu",
        "workload": src.get("workload"),
        "potential_v": REFERENCE_POTENTIAL_V,
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
        "energy_ev": (src or {}).get("energy_ev"),
        "validity_gate_pass": (src or {}).get("validity_gate_pass"),
        "validity_ratio": (src or {}).get("validity_ratio"),
        "ratio_vs_li": ratio,
        "note": (src or {}).get("note") or note,
        "framework_version": (src or {}).get("framework_version"),
        "license": (src or {}).get("license"),
        "device": (src or {}).get("device", "cpu"),
        "workload": (src or {}).get("workload"),
        "potential_v": REFERENCE_POTENTIAL_V,
    }


li = load("ph-sci-echem-li.json")
pyscf = load("ph-sci-echem-competitor-pyscf.json")
li_sec = li.get("cpu_sec")
li_e = li_row(li, "stub").get("energy_ev")
ref_e = pyscf.get("energy_ev") if pyscf.get("executed") else None
delta = None
parity_pass = None
if li_e is not None and ref_e is not None:
    delta = round(float(li_e) - float(ref_e), 6)
    parity_pass = abs(delta) <= ENERGY_TOLERANCE_EV

rows = [
    {
        "id": "echem_che_h",
        "kernel": "echem.che_h_adsorption_energy",
        "workload_class": "pilot",
        "workload_note": (
            "CHE H* vs RHE at U=0; Li scalar stub vs PySCF E(H)-0.5*E(H2) toy geometry"
        ),
        "potential_v": REFERENCE_POTENTIAL_V,
        "energy_tolerance_ev": ENERGY_TOLERANCE_EV,
        "energy_delta_ev": delta,
        "parity_gate_pass": parity_pass,
        "parity_note": (
            "Large delta expected until WP-ECHEM-05 couples real slab SCF — stub honesty"
        ),
        "executed": bool(li.get("executed")) or bool(pyscf.get("executed")),
        "li": li_row(li, "pilot"),
        "competitors": [
            comp_row(
                pyscf,
                li_sec,
                "pyscf",
                "PySCF RKS/LDA CHE proxy",
                "oss_oracle",
                "Apache-2.0 primary reference (H + H2 STO-3G)",
            ),
            {
                "id": "orca",
                "incumbent": "ORCA RKS/LDA",
                "workload_class": "external_manual",
                "executed": False,
                "cpu_sec": None,
                "energy_ev": None,
                "validity_gate_pass": None,
                "validity_ratio": None,
                "ratio_vs_li": None,
                "license": "academic-free-not-redistributable",
                "note": (
                    "NOT bundled in CI — user-run oracle; see "
                    "benchmarks/competitive/README-chem-dft.md"
                ),
                "device": "cpu",
                "workload": "echem_che_h",
            },
        ],
    }
]

out.write_text(
    json.dumps(
        {
            "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "suite": "ph-sci-echem-competitive",
            "registry_path": registry,
            "registry_schema": "li_ph_sci_echem_competitive_v1",
            "rows": rows,
        },
        indent=2,
    )
    + "\n",
)
print(out)
PY
echo "bench-ph-sci-echem-competitive: done"
