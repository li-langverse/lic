"""Shared PH-SCI chem DFT competitive workload — H atom STO-3G mini scaffold (lib.li mirror)."""
from __future__ import annotations

import time
from typing import Any, Callable

# Workload definition (documented parity target for PySCF/Psi4 drivers).
ATOM = "H 0 0 0"
BASIS = "sto-3g"
XC = "lda,vwn"
CHARGE = 0
SPIN = 1
UNIT = "Angstrom"

DEFAULT_RUNS = 20
DEFAULT_WARMUP = 3

# Tier-2 gate: Li mini radial-grid scaffold is NOT full Gaussian DFT — loose energy tolerance.
ENERGY_TOLERANCE_HARTREE = 0.35

GRID_N = 8
BASIS_N = 4
GRID_DR = 0.18

GRID_R = (0.12, 0.30, 0.48, 0.66, 0.84, 1.02, 1.20, 1.38)
BASIS_ZETA = (3.42525091, 0.62391373, 0.16885540, 0.90000000)
BASIS_CENTROID = (0.30, 0.60, 0.90, 1.20)
STO3G_COEFF = (0.15432897, 0.53532814, 0.44463454)
STO3G_ZETA = (3.42525091, 0.62391373, 0.16885540)


def report_base(competitor_id: str, suite: str, workload: str) -> dict[str, Any]:
    return {
        "competitor_id": competitor_id,
        "suite": suite,
        "workload": workload,
        "executed": False,
        "cpu_sec": None,
        "energy_hartree": None,
        "validity_gate_pass": False,
        "validity_ratio": 0.0,
        "framework_version": None,
        "device": "cpu",
        "note": None,
        "geometry": ATOM,
        "basis": BASIS,
        "xc": XC,
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


def _primitive_decay(r: float, zeta: float) -> float:
    return 1.0 / (1.0 + zeta * r * r)


def _basis_eval_at(bi: int, r: float) -> float:
    return _primitive_decay(r, BASIS_ZETA[bi])


def _basis_eval_sto3g(r: float) -> float:
    p0 = _primitive_decay(r, STO3G_ZETA[0])
    p1 = _primitive_decay(r, STO3G_ZETA[1])
    p2 = _primitive_decay(r, STO3G_ZETA[2])
    return STO3G_COEFF[0] * p0 + STO3G_COEFF[1] * p1 + STO3G_COEFF[2] * p2


def _cbrt_rho(rho: float) -> float:
    if rho <= 1.0e-12:
        return 0.0
    x = max(rho, 1.0e-6)
    for _ in range(4):
        x2 = x * x
        if x2 > 1.0e-18:
            x = (2.0 * x + rho / x2) / 3.0
    return x


def _lda_xc_density(rho: float) -> float:
    if rho <= 1.0e-12:
        return 0.0
    return -0.738558 * _cbrt_rho(rho)


def _fill_density_from_basis() -> list[float]:
    coeffs = [1.0, 0.0, 0.0, 0.0]
    dens = []
    for k in range(GRID_N):
        r = GRID_R[k]
        psi = sum(coeffs[i] * _basis_eval_at(i, r) for i in range(BASIS_N))
        dens.append(psi * psi)
    return dens


def _hartree_grid(dens: list[float]) -> float:
    hartree = 0.0
    dr = GRID_DR
    for i in range(GRID_N):
        ri = GRID_R[i]
        for j in range(GRID_N):
            rj = GRID_R[j]
            d = abs(ri - rj)
            hartree += 0.5 * dens[i] * dens[j] * dr * dr / (d + 0.05)
    return hartree


def li_scaffold_energy_from_density(dens: list[float]) -> float:
    """Python transcription of chem_dft_energy_from_density + kernel (packages/li-chem/src/lib.li)."""
    kin = pot = xc = 0.0
    z_eff = 1.0
    dr = GRID_DR
    for i in range(GRID_N):
        r = GRID_R[i]
        rho = dens[i]
        pot -= z_eff * rho * dr / (r + 0.05)
        xc += _lda_xc_density(rho) * dr
        if i < 7:
            dphi = _basis_eval_sto3g(GRID_R[i + 1]) - _basis_eval_sto3g(r)
            kin += 0.5 * dphi * dphi / (dr * dr)
    return kin + pot + xc + _hartree_grid(dens)


def li_scaffold_energy_hartree() -> float:
    return li_scaffold_energy_from_density(_fill_density_from_basis())
