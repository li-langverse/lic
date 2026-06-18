"""Shared 1D implicit heat Jacobi workload for Li vs PETSc/hypre competitive rows."""

from __future__ import annotations

import math

NX = 8
STEPS = 200
JACOBI_ITERS = 4
ALPHA = 0.25
DX = 0.125
DT = 0.0001
CHECKSUM_TOLERANCE = 1.0e-9


def _r() -> float:
    return ALPHA * DT / (DX * DX)


def heat_implicit_matvec_1d(u: list[float], out: list[float], r: float) -> None:
    """Matrix-free apply: out[i] = u[i] + r*(u[i-1]+u[i+1]-2*u[i]) on interior."""
    out[0] = u[0]
    out[NX - 1] = u[NX - 1]
    for i in range(1, NX - 1):
        out[i] = u[i] + r * (u[i - 1] + u[i + 1] - 2.0 * u[i])


def jacobi_heat_implicit_assembled_step(
    u: list[float], b: list[float], x: list[float], r: float
) -> None:
    """One assembled Jacobi sweep for (I - r*L) x = b."""
    x[0] = b[0]
    x[NX - 1] = b[NX - 1]
    denom = 1.0 + 2.0 * r
    for i in range(1, NX - 1):
        x[i] = (b[i] + r * (u[i - 1] + u[i + 1])) / denom
    for i in range(NX):
        u[i] = x[i]


def initial_field() -> list[float]:
    u = [0.0] * NX
    for i in range(NX):
        u[i] = math.sin(0.25 * float(i))
    return u


def li_implicit_jacobi_oracle_checksum() -> float:
    """Python mirror of physics.fluids.pde_implicit_jacobi_oracle_checksum."""
    u = initial_field()
    b = [0.0] * NX
    x = [0.0] * NX
    r = _r()
    for _ in range(STEPS):
        for i in range(NX):
            b[i] = u[i]
        for _j in range(JACOBI_ITERS):
            jacobi_heat_implicit_assembled_step(u, b, x, r)
    return sum(u)


def workload_meta() -> dict:
    return {
        "nx": NX,
        "steps": STEPS,
        "jacobi_iters": JACOBI_ITERS,
        "alpha": ALPHA,
        "dx": DX,
        "dt": DT,
        "catalog_bench": "pde_heat_implicit_jacobi",
        "algo_id": 204,
    }
