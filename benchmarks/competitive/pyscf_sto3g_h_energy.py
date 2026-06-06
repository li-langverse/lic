#!/usr/bin/env python3
"""PySCF RKS/LDA reference — H atom STO-3G (Apache-2.0 oracle)."""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

from chem_dft_competitive_common import (
    ATOM,
    BASIS,
    CHARGE,
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    SPIN,
    XC,
    bench_loop,
    report_base,
)

out = os.environ.get(
    "PH_SCI_CHEM_PYSCF_OUT",
    "benchmarks/results/ph-sci-chem-competitor-pyscf.json",
)
report = report_base("pyscf", "ph-sci-chem-competitor-pyscf", "sto3g_h_lda_energy")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["license"] = "Apache-2.0"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    from pyscf import dft, gto
except ImportError:
    report["note"] = "pyscf not installed — pip install -r scripts/requirements-ph-sci-chem-dft-competitive.txt"
    write_report()
    sys.exit(0)

report["framework_version"] = getattr(gto, "__version__", None) or "pyscf"

mol = gto.M(atom=ATOM, basis=BASIS, spin=SPIN, charge=CHARGE)


def run_scf():
    mf = dft.RKS(mol)
    mf.xc = XC
    mf.verbose = 0
    return mf.kernel()


def sanity(energy) -> bool:
    return energy is not None and float(energy) < 0.0


energy = float(run_scf())
cpu_sec, err = bench_loop(DEFAULT_RUNS, DEFAULT_WARMUP, run_scf, sanity)

if err:
    report["note"] = err
    report["energy_hartree"] = energy
    write_report()
    sys.exit(0)

report["cpu_sec"] = cpu_sec
report["energy_hartree"] = round(energy, 12)
report["executed"] = True
report["validity_gate_pass"] = True
report["validity_ratio"] = 1.0
report["note"] = "PySCF RKS converged SCF energy (primary OSS oracle)"
write_report()
