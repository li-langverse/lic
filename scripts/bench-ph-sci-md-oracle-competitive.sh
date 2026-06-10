#!/usr/bin/env bash
# PH-SCI MD external oracle competitive bench — Li tier-2 MD drift vs LAMMPS/GROMACS stubs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_MD_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

REGISTRY="$ROOT/benchmarks/competitive/md_oracle.toml"
OUT="$BENCHMARKS_RESULTS/ph-sci-md-oracle-competitive.json"
COMP_DIR="$ROOT/benchmarks/competitive"
export PYTHONPATH="$COMP_DIR${PYTHONPATH:+:$PYTHONPATH}"

export PH_SCI_MD_COMP_ROOT="$ROOT" PH_SCI_MD_COMP_OUT="$OUT" PH_SCI_MD_COMP_REGISTRY="$REGISTRY"
python3 <<'PY'
import json
import os
import sys
import time
from pathlib import Path

root = Path(os.environ["PH_SCI_MD_COMP_ROOT"])
out = Path(os.environ["PH_SCI_MD_COMP_OUT"])
registry = os.environ["PH_SCI_MD_COMP_REGISTRY"]
competitive = root / "benchmarks" / "competitive"
sys.path.insert(0, str(competitive))
from md_oracle_competitive_common import (
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    DRIFT_TOLERANCE,
    PARTICLES,
    SPACING,
    STEPS,
    bench_loop,
    drift_sanity,
    li_md_oracle_checksum,
)

cpu_sec, bench_err = bench_loop(
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    li_md_oracle_checksum,
    drift_sanity,
)
drift = round(li_md_oracle_checksum(), 12)
li_row = {
    "id": "li",
    "incumbent": "Li sim_scientific_oracle_checksum_md (4-particle LJ chain)",
    "workload_class": "v0_micro",
    "executed": bench_err is None,
    "cpu_sec": cpu_sec,
    "energy_drift": drift,
    "energy_source": "li_md_oracle_python_mirror",
    "validity_gate_pass": drift_sanity(drift),
    "validity_ratio": 1.0 if drift_sanity(drift) else 0.0,
    "ratio_vs_li": 1.0,
    "device": "cpu",
    "workload": "md_lj_micro",
    "note": bench_err,
}


def stub_comp(cid: str, incumbent: str, license_id: str, pinned: str, csv_lang: str) -> dict:
    return {
        "id": cid,
        "incumbent": incumbent,
        "workload_class": "external_binary_stub",
        "executed": False,
        "cpu_sec": None,
        "energy_drift": None,
        "validity_gate_pass": None,
        "validity_ratio": None,
        "ratio_vs_li": None,
        "license": license_id,
        "pinned_version": pinned,
        "csv_lang": csv_lang,
        "note": (
            "NOT bundled in CI — external domain oracle; enable with "
            f"LI_MD_ORACLE_{cid.upper()}=1 when binary on PATH; see README-md-oracle.md"
        ),
        "device": "cpu",
        "workload": "md_lj_micro",
    }


rows = [
    {
        "id": "md_lj_micro",
        "kernel": "sim_scientific_oracle_checksum_md",
        "workload_class": "v0_micro",
        "workload_note": (
            f"{PARTICLES}-particle LJ chain spacing={SPACING}, {STEPS} velocity-Verlet steps; "
            "normalized energy drift checksum"
        ),
        "particles": PARTICLES,
        "steps": STEPS,
        "spacing": SPACING,
        "drift_tolerance": DRIFT_TOLERANCE,
        "drift_delta": None,
        "parity_gate_pass": None,
        "parity_note": "LAMMPS/GROMACS columns stub until WP-PLAT-05 B1 drivers ship",
        "executed": bool(li_row["executed"]),
        "li": li_row,
        "competitors": [
            stub_comp("lammps", "LAMMPS pair/lj/cut", "GPL-2.0-only", "2024.06.27", "lammps"),
            stub_comp("gromacs", "GROMACS velocity-Verlet", "LGPL-2.1-or-later", "2024.2", "gromacs"),
        ],
    }
]

out.write_text(
    json.dumps(
        {
            "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "suite": "ph-sci-md-oracle-competitive",
            "registry_path": "benchmarks/competitive/md_oracle.toml",
            "registry_schema": "li_ph_sci_md_oracle_competitive_v1",
            "rows": rows,
        },
        indent=2,
    )
    + "\n",
)
print(out)
PY
echo "bench-ph-sci-md-oracle-competitive: done"
