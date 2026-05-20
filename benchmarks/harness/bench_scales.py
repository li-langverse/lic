"""Bench scale profiles: quick (few DOFs, long-enough integration for stability) vs full (perf)."""
from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class Scale:
    """Problem size for one benchmark id."""

    note: str = ""
    # dynamics
    n: int | None = None
    nx: int | None = None
    ny: int | None = None
    steps: int | None = None
    # tier-1
    matmul_n: int | None = None
    dot_n: int | None = None
    reduce_n: int | None = None
    horner_steps: int | None = None


def mode() -> str:
    """quick = few DOFs + long-enough steps for stability; full = perf sweep."""
    if os.environ.get("LI_BENCH_QUICK") == "1":
        return "quick"
    return os.environ.get("LI_BENCH_SCALE", "full").lower()


def is_quick() -> bool:
    return mode() != "full"


# Few bodies / small grids; enough steps to expose blow-up (not production particle counts).
QUICK: dict[str, Scale] = {
    "simd_dot": Scale(dot_n=1_000_000, note="micro"),
    "matmul_naive": Scale(matmul_n=256, note="micro"),
    "matmul_naive_n128": Scale(matmul_n=128, note="micro"),
    "matmul_blocked": Scale(matmul_n=256, note="micro"),
    "matmul_blocked_n128": Scale(matmul_n=128, note="micro"),
    "matmul_blocked_n1024": Scale(matmul_n=512, note="micro"),
    "reduce_sum": Scale(reduce_n=10_000_000, note="micro"),
    "horner_pure_li": Scale(horner_steps=500_000, note="micro"),
    "md_lennard_jones": Scale(n=64, steps=2000, note="3D MD stability"),
    "three_body": Scale(n=3, steps=200_000, note="3 bodies, long integration"),
    "nbody_gravity": Scale(n=32, steps=5000, note="N-body stability"),
    "harmonic_oscillator_chain": Scale(n=32, steps=50_000, note="chain stability"),
    "wave_equation_1d": Scale(n=2048, steps=20_000, note="1D wave stability"),
    "heat_equation_2d": Scale(nx=64, ny=64, steps=5000, note="diffusion stability"),
    "double_pendulum": Scale(steps=100_000, note="pendulum stability"),
    "advection_diffusion_2d": Scale(nx=64, ny=64, steps=5000, note="smoke field"),
    "wave_equation_2d": Scale(nx=64, ny=64, steps=5000, note="2D wave stability"),
    "sph_dam_break_2d": Scale(n=48, steps=3000, note="few particles SPH v0"),
    "euler_fluid_2d": Scale(nx=32, ny=32, steps=4000, note="2D advection"),
    "combustion_passive": Scale(n=64, steps=2000, note="burn stability"),
    "wind_field_bc": Scale(nx=32, ny=32, steps=3000, note="wind BC"),
    "rigid_body_stack": Scale(n=12, steps=1200, note="few rigid bodies"),
    "cloth_swing": Scale(n=8, steps=4000, note="short chain"),
    "ragdoll_chain": Scale(n=12, steps=3600, note="few joints"),
    "orbit_two_body": Scale(steps=50_000, note="2-body orbit"),
    "fdtd_waveguide_2d": Scale(n=64, steps=4000, note="1D FDTD"),
    "schrodinger_1d_barrier": Scale(n=64, steps=4000, note="TDSE barrier"),
    "game_world_soa_10k": Scale(n=2048, steps=120, note="quick SoA world tick"),
    "game_replication_encode": Scale(n=200, steps=100, note="replication encode rounds"),
    "sim_physics_frame": Scale(n=12, steps=400, note="physics frame substeps"),
}

# Production-scale (matches current C enum defaults when LI_BENCH_QUICK unset).
FULL: dict[str, Scale] = {
    "simd_dot": Scale(dot_n=10_000_000),
    "matmul_naive": Scale(matmul_n=256),
    "matmul_naive_n128": Scale(matmul_n=128),
    "matmul_blocked": Scale(matmul_n=512),
    "matmul_blocked_n128": Scale(matmul_n=128),
    "matmul_blocked_n1024": Scale(matmul_n=1024),
    "reduce_sum": Scale(reduce_n=100_000_000),
    "horner_pure_li": Scale(horner_steps=5_000_000),
    "md_lennard_jones": Scale(n=256, steps=10_000),
    "three_body": Scale(n=3, steps=10_000_000),
    "nbody_gravity": Scale(n=128, steps=50_000),
    "harmonic_oscillator_chain": Scale(n=64, steps=2_000_000),
    "wave_equation_1d": Scale(n=8192, steps=400_000),
    "heat_equation_2d": Scale(nx=128, ny=128, steps=20_000),
    "double_pendulum": Scale(steps=3_000_000),
    "advection_diffusion_2d": Scale(nx=128, ny=128, steps=15_000),
    "wave_equation_2d": Scale(nx=128, ny=128, steps=25_000),
    "sph_dam_break_2d": Scale(n=512, steps=10_000),
    "euler_fluid_2d": Scale(nx=64, ny=64, steps=8000),
    "combustion_passive": Scale(n=128, steps=3000),
    "wind_field_bc": Scale(nx=64, ny=64, steps=5000),
    "rigid_body_stack": Scale(n=50, steps=2000),
    "cloth_swing": Scale(n=16, steps=8000),
    "ragdoll_chain": Scale(n=12, steps=3600),
    "orbit_two_body": Scale(steps=100_000),
    "fdtd_waveguide_2d": Scale(n=128, steps=8000),
    "schrodinger_1d_barrier": Scale(n=128, steps=8000),
    "game_world_soa_10k": Scale(n=10240, steps=600, note="10k entity SoA budget"),
    "game_replication_encode": Scale(n=1000, steps=500, note="replication competitive"),
    "sim_physics_frame": Scale(n=12, steps=2000, note="game physics frame"),
}


def scale(name: str) -> Scale:
    table = QUICK if is_quick() else FULL
    return table.get(name, Scale())


def stability_limits(name: str) -> dict[str, float]:
    """Post-run sanity: checksum must be finite and within loose physical bounds."""
    lim: dict[str, float] = {"max_abs_checksum": 1e18}
    if name in ("three_body", "nbody_gravity", "orbit_two_body"):
        lim["max_abs_checksum"] = 1e6
    if name in ("wave_equation_1d", "wave_equation_2d", "heat_equation_2d"):
        lim["max_abs_checksum"] = 1e12
    if name == "md_lennard_jones":
        lim["max_abs_checksum"] = 1.0  # energy drift ratio
    return lim
