"""Shared PH-SCI MD external oracle workload — 4-particle LJ chain (lib.li mirror)."""
from __future__ import annotations

import time
from typing import Any, Callable

# Workload matches sim_scientific_oracle_checksum_md() in li-sim-scientific.
N_PARTICLES = 4
SPACING = 1.12
DT = 0.004
STEPS = 8
RC = 2.5
RC2 = RC * RC
WORKLOAD = "lj_chain_4atom_8step_drift"
KERNEL = "sim_scientific_oracle_checksum_md"

DEFAULT_RUNS = 20
DEFAULT_WARMUP = 3

# Tier-2 gate: relative energy drift between step 0 and step 8 (NVE micro).
DRIFT_TOLERANCE = 1.0e-3


def report_base(competitor_id: str, suite: str, workload: str) -> dict[str, Any]:
    return {
        "competitor_id": competitor_id,
        "suite": suite,
        "workload": workload,
        "executed": False,
        "cpu_sec": None,
        "energy_drift_checksum": None,
        "validity_gate_pass": False,
        "validity_ratio": 0.0,
        "framework_version": None,
        "device": "cpu",
        "note": None,
        "n_particles": N_PARTICLES,
        "spacing": SPACING,
        "dt": DT,
        "steps": STEPS,
        "rc": RC,
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


def lj_fx(dx: float, r2: float, rc2: float = RC2) -> float:
    if r2 >= rc2 or r2 < 1.0e-12:
        return 0.0
    inv_r2 = 1.0 / r2
    inv_r6 = inv_r2 * inv_r2 * inv_r2
    inv_r12 = inv_r6 * inv_r6
    f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6
    return f_scalar * dx


def lj_pe(r2: float, rc2: float = RC2) -> float:
    if r2 >= rc2 or r2 < 1.0e-12:
        return 0.0
    inv_r2 = 1.0 / r2
    inv_r6 = inv_r2 * inv_r2 * inv_r2
    inv_r12 = inv_r6 * inv_r6
    return 4.0 * (inv_r12 - inv_r6)


def chain_energy(
    px: list[float],
    py: list[float],
    vx: list[float],
    vy: list[float],
    rc2: float = RC2,
) -> float:
    pe = 0.0
    ke = 0.0
    for i in range(N_PARTICLES):
        ke += 0.5 * (vx[i] * vx[i] + vy[i] * vy[i])
        for j in range(i + 1, N_PARTICLES):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            pe += lj_pe(r2, rc2)
    return pe + ke


def chain_forces(px: list[float], py: list[float], rc2: float = RC2) -> tuple[list[float], list[float]]:
    fx = [0.0] * N_PARTICLES
    fy = [0.0] * N_PARTICLES
    for i in range(N_PARTICLES):
        for j in range(i + 1, N_PARTICLES):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            fxi = lj_fx(dx, r2, rc2)
            fyi = lj_fx(dy, r2, rc2)
            fx[i] -= fxi
            fy[i] -= fyi
            fx[j] += fxi
            fy[j] += fyi
    return fx, fy


def li_oracle_checksum_md() -> float:
    """Mirror of sim_scientific_oracle_checksum_md() — velocity-Verlet, 8 steps."""
    px = [float(i) * SPACING for i in range(N_PARTICLES)]
    py = [0.0] * N_PARTICLES
    vx = [0.0] * N_PARTICLES
    vy = [0.0] * N_PARTICLES
    e0 = chain_energy(px, py, vx, vy)
    for _ in range(STEPS):
        fx, fy = chain_forces(px, py)
        for i in range(N_PARTICLES):
            vx[i] += 0.5 * DT * fx[i]
            vy[i] += 0.5 * DT * fy[i]
        for i in range(N_PARTICLES):
            px[i] += DT * vx[i]
            py[i] += DT * vy[i]
        fx, fy = chain_forces(px, py)
        for i in range(N_PARTICLES):
            vx[i] += 0.5 * DT * fx[i]
            vy[i] += 0.5 * DT * fy[i]
    e1 = chain_energy(px, py, vx, vy)
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
