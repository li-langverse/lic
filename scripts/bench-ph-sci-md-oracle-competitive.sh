#!/usr/bin/env bash
# PH-SCI MD external oracle competitive bench — Li checksum vs LAMMPS (GPL user-installed).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_MD_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

REGISTRY="benchmarks/competitive/ph-sci-md-oracle.toml"
OUT="$BENCHMARKS_RESULTS/ph-sci-md-oracle-competitive.json"
COMP_DIR="$ROOT/benchmarks/competitive"
export PYTHONPATH="$COMP_DIR${PYTHONPATH:+:$PYTHONPATH}"

bash "$ROOT/scripts/bench-ph-sci-md-oracle-li.sh"

export PH_SCI_MD_LAMMPS_OUT="$BENCHMARKS_RESULTS/ph-sci-md-competitor-lammps.json"
python3 "$COMP_DIR/lammps_lj_chain_checksum.py"

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
from md_oracle_competitive_common import DRIFT_TOLERANCE, KERNEL, WORKLOAD


def load(name: str) -> dict:
    p = results / name
    return json.loads(p.read_text()) if p.is_file() else {}


def li_row(src: dict, wc: str) -> dict:
    return {
        "id": "li",
        "incumbent": "Li sim_scientific_oracle_checksum_md",
        "workload_class": wc,
        "executed": bool(src.get("executed")),
        "cpu_sec": src.get("cpu_sec"),
        "energy_drift_checksum": src.get("energy_drift_checksum"),
        "energy_drift_source": src.get("energy_drift_source", "li_python_mirror"),
        "validity_gate_pass": bool(src.get("validity_gate_pass")),
        "validity_ratio": src.get("validity_ratio"),
        "ratio_vs_li": 1.0,
        "device": "cpu",
        "workload": src.get("workload") or WORKLOAD,
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
        "energy_drift_checksum": (src or {}).get("energy_drift_checksum"),
        "validity_gate_pass": (src or {}).get("validity_gate_pass"),
        "validity_ratio": (src or {}).get("validity_ratio"),
        "ratio_vs_li": ratio,
        "note": (src or {}).get("note") or note,
        "framework_version": (src or {}).get("framework_version"),
        "license": (src or {}).get("license"),
        "device": (src or {}).get("device", "cpu"),
        "workload": (src or {}).get("workload") or WORKLOAD,
    }


li = load("ph-sci-md-oracle-li.json")
lammps = load("ph-sci-md-competitor-lammps.json")
li_sec = li.get("cpu_sec")
li_drift = li_row(li, "pilot").get("energy_drift_checksum")
ref_drift = lammps.get("energy_drift_checksum") if lammps.get("executed") else None
delta = None
parity_pass = None
if li_drift is not None and ref_drift is not None:
    delta = round(float(li_drift) - float(ref_drift), 12)
    parity_pass = abs(delta) <= DRIFT_TOLERANCE

rows = [
    {
        "id": "lj_chain_4atom_drift",
        "kernel": KERNEL,
        "algo_registry_id": 104,
        "algo_registry_name": "md_oracle_external",
        "workload_class": "pilot",
        "workload_note": (
            "4-atom LJ chain; 8-step velocity-Verlet; relative energy drift checksum"
        ),
        "drift_tolerance": DRIFT_TOLERANCE,
        "drift_delta": delta,
        "parity_gate_pass": parity_pass,
        "parity_note": (
            "LAMMPS GPL oracle optional in CI — Li/python mirror always recorded"
        ),
        "executed": bool(li.get("executed")) or bool(lammps.get("executed")),
        "li": li_row(li, "pilot"),
        "competitors": [
            comp_row(
                lammps,
                li_sec,
                "lammps",
                "LAMMPS lj/cut",
                "external_oracle",
                "GPL-2.0-only when lmp on PATH",
            ),
            {
                "id": "gromacs",
                "incumbent": "GROMACS mdrun",
                "workload_class": "external_manual",
                "executed": False,
                "cpu_sec": None,
                "energy_drift_checksum": None,
                "validity_gate_pass": None,
                "validity_ratio": None,
                "ratio_vs_li": None,
                "license": "LGPL-2.1-or-later",
                "note": (
                    "NOT bundled — future driver; see "
                    "benchmarks/competitive/README-md-oracle.md"
                ),
                "device": "cpu",
                "workload": WORKLOAD,
            },
        ],
    }
]

out.write_text(
    json.dumps(
        {
            "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "suite": "ph-sci-md-oracle-competitive",
            "registry_path": registry,
            "registry_schema": "li_ph_sci_md_oracle_competitive_v1",
            "gate_script": "scripts/ph-sci-md-oracle-competitive-gates.sh",
            "rows": rows,
        },
        indent=2,
    )
    + "\n",
)
print(out)
PY
echo "bench-ph-sci-md-oracle-competitive: done"
