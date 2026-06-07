"""Shared PH-SCI MD competitive workload — 4-particle LJ chain (lib.li mirror)."""
from __future__ import annotations

import time
from typing import Any, Callable

N_PARTICLES = 4
SPACING = 1.12
DT = 0.004
RC2 = 2.5 * 2.5
VV_STEPS = 8

DEFAULT_RUNS = 20
DEFAULT_WARMUP = 3

# Tier-2 gate: external LAMMPS/GROMACS columns stub until B1 drivers ship.
DRIFT_TOLERANCE = 1.0e-3


def report_base(competitor_id: str, suite: str, workload: str) -> dict[str, Any]:
    return {
        "competitor_id": competitor_id,
        "suite": suite,
        "workload": workload,
        "executed": False,
        "cpu_sec": None,
        "energy_drift": None,
        "validity_gate_pass": False,
        "validity_ratio": 0.0,
        "framework_version": None,
        "device": "cpu",
        "note": None,
        "n_particles": N_PARTICLES,
        "vv_steps": VV_STEPS,
        "spacing": SPACING,
        "dt": DT,
    }


def bench_loop(
    runs: int,
    warmup: int,
    fn: Callable[[], float],
    sanity: Callable[[float], bool],
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


def md_oracle_lj_fx_pair(dx: float, r2: float, rc2: float) -> float:
    if r2 >= rc2 or r2 < 1.0e-12:
        return 0.0
    inv_r2 = 1.0 / r2
    inv_r6 = inv_r2 * inv_r2 * inv_r2
    inv_r12 = inv_r6 * inv_r6
    f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6
    return f_scalar * dx


def md_oracle_lj_pe_pair(r2: float, rc2: float) -> float:
    if r2 >= rc2 or r2 < 1.0e-12:
        return 0.0
    inv_r2 = 1.0 / r2
    inv_r6 = inv_r2 * inv_r2 * inv_r2
    inv_r12 = inv_r6 * inv_r6
    return 4.0 * (inv_r12 - inv_r6)


def md_oracle_chain_energy(
    px: list[float], py: list[float], vx: list[float], vy: list[float]
) -> float:
    pe = 0.0
    ke = 0.0
    for i in range(N_PARTICLES):
        ke += 0.5 * (vx[i] * vx[i] + vy[i] * vy[i])
        for j in range(i + 1, N_PARTICLES):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            pe += md_oracle_lj_pe_pair(r2, RC2)
    return pe + ke


def md_oracle_chain_forces(
    px: list[float], py: list[float], fx: list[float], fy: list[float]
) -> None:
    for i in range(N_PARTICLES):
        fx[i] = 0.0
        fy[i] = 0.0
    for i in range(N_PARTICLES):
        for j in range(i + 1, N_PARTICLES):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            fxi = md_oracle_lj_fx_pair(dx, r2, RC2)
            fyi = md_oracle_lj_fx_pair(dy, r2, RC2)
            fx[i] -= fxi
            fy[i] -= fyi
            fx[j] += fxi
            fy[j] += fyi


def li_md_oracle_checksum() -> float:
    """Mirror of sim_scientific_oracle_checksum_md() in li-sim-scientific."""
    px = [float(i) * SPACING for i in range(N_PARTICLES)]
    py = [0.0] * N_PARTICLES
    vx = [0.0] * N_PARTICLES
    vy = [0.0] * N_PARTICLES
    fx = [0.0] * N_PARTICLES
    fy = [0.0] * N_PARTICLES
    e0 = md_oracle_chain_energy(px, py, vx, vy)
    for _ in range(VV_STEPS):
        md_oracle_chain_forces(px, py, fx, fy)
        for i in range(N_PARTICLES):
            vx[i] += 0.5 * DT * fx[i]
            vy[i] += 0.5 * DT * fy[i]
        for i in range(N_PARTICLES):
            px[i] += DT * vx[i]
            py[i] += DT * vy[i]
        md_oracle_chain_forces(px, py, fx, fy)
        for i in range(N_PARTICLES):
            vx[i] += 0.5 * DT * fx[i]
            vy[i] += 0.5 * DT * fy[i]
    e1 = md_oracle_chain_energy(px, py, vx, vy)
    denom = e0
    if e1 > denom:
        denom = e1
    if denom < 0.0:
        denom = max(denom, -e0, -e1)
    if denom < 1.0e-12:
        denom = 1.0e-12
    diff = abs(e1 - e0)
    return diff / denom


def drift_sanity(drift: float) -> bool:
    return 0.0 <= drift < DRIFT_TOLERANCE
