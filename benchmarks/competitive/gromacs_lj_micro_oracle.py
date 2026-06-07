#!/usr/bin/env python3
"""GROMACS LJ micro oracle stub — records Li reference until B1 driver ships."""
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
    "PH_SCI_MD_GROMACS_OUT",
    "benchmarks/results/ph-sci-md-competitor-gromacs.json",
)
report = report_base("gromacs", "ph-sci-md-competitor-gromacs", "md_lj_chain_4p_8vv")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["license"] = "LGPL-2.1"
report["pinned_version"] = "2024.2"
report["pinned_tag"] = "v2024.2"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


ref_drift = li_md_oracle_checksum()
report["reference_energy_drift"] = round(ref_drift, 12)
report["reference_source"] = "li_native_python_mirror"

gmx = shutil.which("gmx") or shutil.which("gmx_mpi")
if os.environ.get("LI_MD_ORACLE_GROMACS") == "1" and gmx:
    report["note"] = "GROMACS binary found — B1 micro driver not yet implemented (exit reserved)"
    write_report()
    sys.exit(2)

report["note"] = (
    "GROMACS not bundled — stub column records Li oracle reference; "
    "set LI_MD_ORACLE_GROMACS=1 with gmx on PATH for B1 driver attempts"
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
report["parity_note"] = f"stub until GROMACS micro matches Li drift < {DRIFT_TOLERANCE}"
write_report()
