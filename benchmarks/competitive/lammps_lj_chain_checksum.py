#!/usr/bin/env python3
"""LAMMPS lj/cut micro-oracle — 4-atom chain energy drift (GPL; not bundled in CI)."""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

from md_oracle_competitive_common import (
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    DRIFT_TOLERANCE,
    WORKLOAD,
    bench_loop,
    li_oracle_checksum_md,
    report_base,
)

out = os.environ.get(
    "PH_SCI_MD_LAMMPS_OUT",
    "benchmarks/results/ph-sci-md-competitor-lammps.json",
)
report = report_base("lammps", "ph-sci-md-competitor-lammps", WORKLOAD)
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["license"] = "GPL-2.0-only"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


def find_lammps() -> str | None:
    for name in ("lmp", "lammps", "lmp_mpi", "lmp_serial"):
        path = shutil.which(name)
        if path:
            return path
    return None


def lammps_input() -> str:
    # 2D lj units micro-workload aligned with Li oracle (4-atom chain, rc=2.5, dt=0.004, 8 steps).
    return """# PH-SCI MD external oracle micro — md-r3-oracle-plan
units           lj
dimension       2
atom_style      atomic
boundary        f f p

region          box block -1 5 -1 1 -0.5 0.5
create_box      1 box

create_atoms    1 single 0.00 0.0 0.0
create_atoms    1 single 1.12 0.0 0.0
create_atoms    1 single 2.24 0.0 0.0
create_atoms    1 single 3.36 0.0 0.0

mass            1 1.0
pair_style      lj/cut 2.5
pair_coeff      1 1 1.0 1.0 2.5

velocity        all set 0.0 0.0 0.0
fix             nve all nve

timestep        0.004
thermo_style    custom step pe ke etotal
thermo          1

variable        e0 equal pe+ke
run             0
variable        e1 equal pe+ke
run             8
print           "E0 ${e0} E1 ${e1}"
"""


def parse_drift(stdout: str) -> float | None:
    e0 = e1 = None
    for line in stdout.splitlines():
        line = line.strip()
        if line.startswith("E0 "):
            parts = line.split()
            if len(parts) >= 4:
                try:
                    e0 = float(parts[1])
                    e1 = float(parts[2])
                except ValueError:
                    pass
    if e0 is None or e1 is None:
        return None
    denom = e0
    if e1 > denom:
        denom = e1
    if denom < 0.0:
        if -e0 > denom:
            denom = -e0
        if -e1 > denom:
            denom = -e1
    if denom < 1.0e-12:
        denom = 1.0e-12
    diff = e1 - e0
    if diff < 0.0:
        diff = -diff
    return diff / denom


lmp = find_lammps()
if not lmp:
    report["note"] = (
        "lammps/lmp not in PATH — install LAMMPS for external oracle; "
        "see benchmarks/competitive/README-md-oracle.md"
    )
    write_report()
    sys.exit(0)

report["framework_version"] = lmp


def run_once() -> float:
    with tempfile.TemporaryDirectory(prefix="li-md-lammps-") as td:
        inp = Path(td) / "in.lj_chain"
        log = Path(td) / "log.lammps"
        inp.write_text(lammps_input(), encoding="utf-8")
        proc = subprocess.run(
            [lmp, "-in", str(inp), "-log", str(log)],
            capture_output=True,
            text=True,
            timeout=120,
            check=False,
        )
        text = (proc.stdout or "") + "\n" + (proc.stderr or "")
        if log.is_file():
            text += "\n" + log.read_text(encoding="utf-8", errors="replace")
        if proc.returncode != 0:
            raise RuntimeError(f"lammps exit {proc.returncode}: {text[-500:]}")
        drift = parse_drift(text)
        if drift is None:
            raise RuntimeError("could not parse E0/E1 from LAMMPS output")
        return drift


def sanity(drift: float) -> bool:
    return 0.0 < drift < 1.0


try:
    drift = run_once()
except Exception as exc:
    report["note"] = f"LAMMPS run failed: {exc}"
    report["energy_drift_checksum"] = li_oracle_checksum_md()
    report["energy_drift_source"] = "li_python_mirror_fallback"
    write_report()
    sys.exit(0)

cpu_sec, err = bench_loop(DEFAULT_RUNS, DEFAULT_WARMUP, run_once, sanity)
if err:
    report["note"] = err
    report["energy_drift_checksum"] = round(drift, 12)
    write_report()
    sys.exit(0)

report["cpu_sec"] = cpu_sec
report["energy_drift_checksum"] = round(drift, 12)
report["executed"] = True
report["validity_gate_pass"] = drift <= DRIFT_TOLERANCE
report["validity_ratio"] = 1.0 if report["validity_gate_pass"] else 0.0
report["note"] = "LAMMPS lj/cut 4-atom chain — GPL external oracle (user-installed)"
write_report()
