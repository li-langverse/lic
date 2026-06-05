"""Shared PH-SCI electrochemistry competitive workload — CHE H* toy (lib.li mirror)."""
from __future__ import annotations

import sys
import time
from pathlib import Path
from typing import Any, Callable

_COMP_DIR = Path(__file__).resolve().parent
if str(_COMP_DIR) not in sys.path:
    sys.path.insert(0, str(_COMP_DIR))

from chem_dft_competitive_common import li_scaffold_scf_h2_hartree, li_scaffold_scf_hartree

# PySCF CHE oracle geometry (H + H₂ STO-3G); Li uses mini radial SCF (WP-ECHEM-05).
H_STAR_ATOM = "H 0 0 0"
H2_ATOM = "H 0 0 0; H 0 0 0.74"
BASIS = "sto-3g"
XC = "lda,vwn"
REFERENCE_POTENTIAL_V = 0.0
H2_BOND_ANG = 0.74

DEFAULT_RUNS = 12
DEFAULT_WARMUP = 2

# Radial scaffold ≠ Gaussian DFT — loose tolerance until full slab parity.
ENERGY_TOLERANCE_EV = 5.0

HARTREE_TO_EV = 27.211386246


def report_base(competitor_id: str, suite: str, workload: str) -> dict[str, Any]:
    return {
        "competitor_id": competitor_id,
        "suite": suite,
        "workload": workload,
        "executed": False,
        "cpu_sec": None,
        "energy_ev": None,
        "validity_gate_pass": False,
        "validity_ratio": 0.0,
        "framework_version": None,
        "device": "cpu",
        "note": None,
        "geometry_h_star": H_STAR_ATOM,
        "geometry_h2": H2_ATOM,
        "basis": BASIS,
        "xc": XC,
        "potential_v": REFERENCE_POTENTIAL_V,
    }


def bench_loop(
    runs: int,
    warmup: int,
    fn: Callable[[], Any],
    sanity: Callable[[Any], bool],
) -> tuple[float | None, str | None]:
    for _ in range(warmup):
        out = fn()
        if not sanity(out):
            return None, "warmup sanity failed"
    t0 = time.perf_counter()
    for _ in range(runs):
        out = fn()
        if not sanity(out):
            return None, "mid-run sanity failed"
    return round((time.perf_counter() - t0) / runs, 6), None


def li_echem_che_h_adsorption_energy_ev(potential_v: float) -> float:
    delta_h = li_scaffold_scf_hartree() - 0.5 * li_scaffold_scf_h2_hartree()
    return hartree_to_ev(delta_h) - potential_v


def hartree_to_ev(delta_hartree: float) -> float:
    return round(delta_hartree * HARTREE_TO_EV, 6)
