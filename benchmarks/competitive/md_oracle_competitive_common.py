"""Shared PH-SCI MD external oracle workload — mirrors sim_scientific_oracle_checksum_md()."""
from __future__ import annotations

import time
from typing import Any, Callable

PARTICLES = 4
STEPS = 8
SPACING = 1.12
DT = 0.004
RC2 = 2.5 * 2.5
DRIFT_TOLERANCE = 1.0e-3

DEFAULT_RUNS = 20
DEFAULT_WARMUP = 3


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
        "particles": PARTICLES,
        "steps": STEPS,
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


def _lj_fx_pair(dx: float, r2: float) -> float:
    if r2 >= RC2 or r2 < 1.0e-12:
        return 0.0
    inv_r2 = 1.0 / r2
    inv_r6 = inv_r2 * inv_r2 * inv_r2
    inv_r12 = inv_r6 * inv_r6
    f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6
    return f_scalar * dx


def _lj_pe_pair(r2: float) -> float:
    if r2 >= RC2 or r2 < 1.0e-12:
        return 0.0
    inv_r2 = 1.0 / r2
    inv_r6 = inv_r2 * inv_r2 * inv_r2
    inv_r12 = inv_r6 * inv_r6
    return 4.0 * (inv_r12 - inv_r6)


def _chain_energy(px: list[float], py: list[float], vx: list[float], vy: list[float]) -> float:
    pe = 0.0
    ke = 0.0
    for i in range(PARTICLES):
        ke += 0.5 * (vx[i] * vx[i] + vy[i] * vy[i])
        for j in range(i + 1, PARTICLES):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            pe += _lj_pe_pair(r2)
    return pe + ke


def _chain_forces(px: list[float], py: list[float]) -> tuple[list[float], list[float]]:
    fx = [0.0] * PARTICLES
    fy = [0.0] * PARTICLES
    for i in range(PARTICLES):
        for j in range(i + 1, PARTICLES):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            fxi = _lj_fx_pair(dx, r2)
            fyi = _lj_fx_pair(dy, r2)
            fx[i] -= fxi
            fy[i] -= fyi
            fx[j] += fxi
            fy[j] += fyi
    return fx, fy


def li_md_oracle_checksum() -> float:
    """Python mirror of packages/li-sim-scientific sim_scientific_oracle_checksum_md()."""
    px = [i * SPACING for i in range(PARTICLES)]
    py = [0.0] * PARTICLES
    vx = [0.0] * PARTICLES
    vy = [0.0] * PARTICLES
    e0 = _chain_energy(px, py, vx, vy)
    for _ in range(STEPS):
        fx, fy = _chain_forces(px, py)
        for i in range(PARTICLES):
            vx[i] += 0.5 * DT * fx[i]
            vy[i] += 0.5 * DT * fy[i]
        for i in range(PARTICLES):
            px[i] += DT * vx[i]
            py[i] += DT * vy[i]
        fx, fy = _chain_forces(px, py)
        for i in range(PARTICLES):
            vx[i] += 0.5 * DT * fx[i]
            vy[i] += 0.5 * DT * fy[i]
    e1 = _chain_energy(px, py, vx, vy)
    denom = max(e0, e1, abs(e0), abs(e1), 1.0e-12)
    diff = abs(e1 - e0)
    return diff / denom


def drift_sanity(drift: float) -> bool:
    return drift > 0.0 and drift < DRIFT_TOLERANCE
