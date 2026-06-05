"""Shared PH-SCI electrochemistry competitive workload — CHE H* toy (lib.li mirror)."""
from __future__ import annotations

import time
from typing import Any, Callable

# Toy geometry: single H atom proxy for Pt(111) H* until WP-ECHEM-05 slab SCF.
H_STAR_ATOM = "H 0 0 0"
H2_ATOM = "H 0 0 0; H 0 0 0.74"
BASIS = "sto-3g"
XC = "lda,vwn"
REFERENCE_POTENTIAL_V = 0.0

DEFAULT_RUNS = 12
DEFAULT_WARMUP = 2

# Li stub honesty: large delta expected until real SCF (WP-ECHEM-05).
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


def li_echem_h_star_energy_ev_stub() -> float:
    return -2.45


def li_echem_h2_energy_ev_stub() -> float:
    return 0.0


def li_echem_che_h_adsorption_energy_ev(potential_v: float) -> float:
    return li_echem_h_star_energy_ev_stub() - 0.5 * li_echem_h2_energy_ev_stub() - potential_v


def hartree_to_ev(delta_hartree: float) -> float:
    return round(delta_hartree * HARTREE_TO_EV, 6)
