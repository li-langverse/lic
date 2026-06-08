#!/usr/bin/env python3
"""LAMMPS LJ micro oracle stub — records Li reference until B1 driver ships."""
from __future__ import annotations

import json
import os
import shutil
import sys
import time
from pathlib import Path

from md_competitive_common import (
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    DRIFT_TOLERANCE,
    bench_loop,
    drift_sanity,
    li_md_oracle_checksum,
    report_base,
)

out = os.environ.get(
    "PH_SCI_MD_LAMMPS_OUT",
    "benchmarks/results/ph-sci-md-competitor-lammps.json",
)
report = report_base("lammps", "ph-sci-md-competitor-lammps", "md_lj_chain_4p_8vv")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["license"] = "GPL-2.0"
report["pinned_version"] = "2024.06.27"
report["pinned_tag"] = "stable_22Jun2024"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


ref_drift = li_md_oracle_checksum()
report["reference_energy_drift"] = round(ref_drift, 12)
report["reference_source"] = "li_native_python_mirror"

if os.environ.get("LI_MD_ORACLE_LAMMPS") == "1" and shutil.which("lmp"):
    report["note"] = "LAMMPS binary found — B1 micro driver not yet implemented (exit reserved)"
    write_report()
    sys.exit(2)

report["note"] = (
    "LAMMPS not bundled — stub column records Li oracle reference; "
    "set LI_MD_ORACLE_LAMMPS=1 with lmp on PATH for B1 driver attempts"
)
cpu_sec, err = bench_loop(DEFAULT_RUNS, DEFAULT_WARMUP, li_md_oracle_checksum, drift_sanity)
if err:
    report["note"] = f"reference bench failed: {err}"
    write_report()
    sys.exit(1)

report["executed"] = False
report["cpu_sec"] = cpu_sec
report["energy_drift"] = None
report["validity_gate_pass"] = False
report["validity_ratio"] = 0.0
report["workload_class"] = "external_stub"
report["parity_note"] = f"stub until LAMMPS micro matches Li drift < {DRIFT_TOLERANCE}"
write_report()
