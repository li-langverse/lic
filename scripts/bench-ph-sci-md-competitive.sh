#!/usr/bin/env bash
# PH-SCI MD competitive bench — Li LJ oracle vs LAMMPS/GROMACS stub columns.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_MD_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

REGISTRY="$ROOT/benchmarks/competitive/md_oracle.toml"
OUT="$BENCHMARKS_RESULTS/ph-sci-md-competitive.json"
COMP_DIR="$ROOT/benchmarks/competitive"
export PYTHONPATH="$COMP_DIR${PYTHONPATH:+:$PYTHONPATH}"

bash "$ROOT/scripts/bench-ph-sci-md-li.sh"

export PH_SCI_MD_LAMMPS_OUT="$BENCHMARKS_RESULTS/ph-sci-md-competitor-lammps.json"
export PH_SCI_MD_GROMACS_OUT="$BENCHMARKS_RESULTS/ph-sci-md-competitor-gromacs.json"
python3 "$COMP_DIR/lammps_lj_micro_oracle.py"
python3 "$COMP_DIR/gromacs_lj_micro_oracle.py"

export PH_SCI_MD_COMP_ROOT="$ROOT" PH_SCI_MD_COMP_OUT="$OUT" PH_SCI_MD_COMP_REGISTRY="$REGISTRY"
python3 <<'PY'
import json
import os
import sys
import time
from pathlib import Path

root = Path(os.environ["PH_SCI_MD_COMP_ROOT"])
results = Path(os.environ.get("BENCHMARKS_RESULTS", root / "benchmarks/results"))
out = Path(os.environ["PH_SCI_MD_COMP_OUT"])
registry = os.environ["PH_SCI_MD_COMP_REGISTRY"]
competitive = root / "benchmarks" / "competitive"
sys.path.insert(0, str(competitive))
from md_competitive_common import DRIFT_TOLERANCE


def load(name: str) -> dict:
    p = results / name
    return json.loads(p.read_text()) if p.is_file() else {}


def li_row(src: dict, wc: str) -> dict:
    return {
        "id": "li",
        "incumbent": "Li native (li-sim-scientific 4-particle LJ chain)",
        "workload_class": wc,
        "executed": bool(src.get("executed")),
        "cpu_sec": src.get("cpu_sec"),
        "energy_drift": src.get("energy_drift"),
        "energy_source": src.get("energy_source", "li_native_python_mirror"),
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
        "energy_drift": (src or {}).get("energy_drift"),
        "reference_energy_drift": (src or {}).get("reference_energy_drift"),
        "validity_gate_pass": (src or {}).get("validity_gate_pass"),
        "validity_ratio": (src or {}).get("validity_ratio"),
        "ratio_vs_li": ratio,
        "note": (src or {}).get("note") or note,
        "framework_version": (src or {}).get("framework_version"),
        "license": (src or {}).get("license"),
        "pinned_version": (src or {}).get("pinned_version"),
        "device": (src or {}).get("device", "cpu"),
        "workload": (src or {}).get("workload"),
        "parity_note": (src or {}).get("parity_note"),
    }


li = load("ph-sci-md-li.json")
lammps = load("ph-sci-md-competitor-lammps.json")
gromacs = load("ph-sci-md-competitor-gromacs.json")
li_sec = li.get("cpu_sec")
li_drift = li_row(li, "v0_micro").get("energy_drift")
ref_drift = lammps.get("reference_energy_drift") or gromacs.get("reference_energy_drift")
delta = None
parity_pass = None
if li_drift is not None and ref_drift is not None:
    delta = round(float(li_drift) - float(ref_drift), 12)
    parity_pass = abs(delta) < 1.0e-15

rows = [
    {
        "id": "lj_chain_micro",
        "kernel": "sim.scientific.oracle_checksum_md",
        "workload_class": "v0_micro",
        "workload_note": (
            "4-particle LJ chain, 8 velocity-Verlet steps; "
            "LAMMPS/GROMACS columns stub until B1 micro drivers"
        ),
        "n_particles": 4,
        "vv_steps": 8,
        "spacing": 1.12,
        "dt": 0.004,
        "drift_tolerance": DRIFT_TOLERANCE,
        "energy_drift_delta": delta,
        "parity_gate_pass": parity_pass,
        "parity_note": (
            "External columns stub — Li native drift is tier-2 reference; "
            "LAMMPS/GROMACS parity deferred to B1"
        ),
        "executed": True,
        "li": li_row(li, "v0_micro"),
        "competitors": [
            comp_row(
                lammps,
                li_sec,
                "lammps",
                "LAMMPS pair/lj/cut micro",
                "external_stub",
                "stub column — install LAMMPS for B1 driver",
            ),
            comp_row(
                gromacs,
                li_sec,
                "gromacs",
                "GROMACS LJ micro",
                "external_stub",
                "stub column — install GROMACS for B1 driver",
            ),
        ],
    }
]

doc = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-sci-md-competitive",
    "registry_path": registry,
    "registry_schema": "li_ph_sci_md_competitive_v1",
    "rows": rows,
}
out.write_text(json.dumps(doc, indent=2) + "\n")
print(out)
PY
echo "bench-ph-sci-md-competitive: done"
