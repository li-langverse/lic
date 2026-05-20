"""NumPy reference implementations for tier-1/2 harness benches.

Mirrors problem sizes in benchmarks/tier*/common/*_core.c (see bench_scales.py).
Matmul/dot/sum use BLAS-backed NumPy ops (@, dot, sum).
"""
from __future__ import annotations

import math
from typing import Callable

import numpy as np

from bench_scales import scale as bench_scale

# --- tier 1 ---


def simd_dot() -> float:
    n = bench_scale("simd_dot").dot_n or 10_000_000
    i = np.arange(n, dtype=np.int64)
    a = (i % 256).astype(np.float64) * 0.001
    b = ((i * 7) % 256).astype(np.float64) * 0.002
    return float(np.dot(a, b))


def _matmul_init(n: int) -> tuple[np.ndarray, np.ndarray]:
    ii = np.arange(n, dtype=np.float64)[:, None]
    jj = np.arange(n, dtype=np.float64)[None, :]
    a = ((ii + jj) % 17) * 0.01
    b = ((ii * 3 + jj) % 13) * 0.02
    return a, b


def matmul_naive() -> float:
    n = bench_scale("matmul_naive").matmul_n or 256
    a, b = _matmul_init(n)
    c = a @ b
    return float(np.sum(c))


def matmul_naive_n128() -> float:
    n = bench_scale("matmul_naive_n128").matmul_n or 128
    a, b = _matmul_init(n)
    return float(np.sum(a @ b))


def matmul_blocked() -> float:
    n = bench_scale("matmul_blocked").matmul_n or 512
    a, b = _matmul_init(n)
    return float(np.sum(a @ b))


def matmul_blocked_n128() -> float:
    n = bench_scale("matmul_blocked_n128").matmul_n or 128
    a, b = _matmul_init(n)
    return float(np.sum(a @ b))


def matmul_blocked_n1024() -> float:
    n = bench_scale("matmul_blocked_n1024").matmul_n or 1024
    a, b = _matmul_init(n)
    return float(np.sum(a @ b))


def reduce_sum() -> float:
    n = bench_scale("reduce_sum").reduce_n or 100_000_000
    i = np.arange(n, dtype=np.int64)
    a = (i % 1024).astype(np.float64) * 1e-6
    return float(np.sum(a))


def horner_pure_li() -> float:
    steps = bench_scale("horner_pure_li").horner_steps or 5_000_000
    x = 1.1
    acc = 0.0
    for _ in range(steps):
        acc = acc * x + 1.0
    return acc


# --- tier 2 helpers ---


def _rng(seed: int) -> np.random.Generator:
    return np.random.default_rng(seed)


def euler_fluid_2d() -> float:
    sc = bench_scale("euler_fluid_2d")
    nx, ny, steps = sc.nx or 64, sc.ny or 64, sc.steps or 8000
    dt, dx, dy, c = 0.001, 0.05, 0.05, 0.5
    cx, cy = c * dt / dx, c * dt / dy
    i = np.arange(nx, dtype=np.float64)[:, None]
    j = np.arange(ny, dtype=np.float64)[None, :]
    u = 0.5 + 0.5 * np.sin(0.2 * i) * np.cos(0.15 * j)
    for _ in range(steps):
        un = u.copy()
        un[1:-1, 1:-1] = u[1:-1, 1:-1] - cx * (
            u[1:-1, 1:-1] - u[0:-2, 1:-1]
        ) - cy * (u[1:-1, 1:-1] - u[1:-1, 0:-2])
        u = un
    return float(u[nx // 2, ny // 2])


def wind_field_bc() -> float:
    sc = bench_scale("wind_field_bc")
    nx, ny, steps = sc.nx or 64, sc.ny or 64, sc.steps or 5000
    dt, dx, dy = 0.008, 0.05, 0.05
    cx, cy = dt / dx, dt / dy
    u = np.full((nx, ny), 0.1, dtype=np.float64)
    for _ in range(steps):
        u[0, :] = 1.0
        un = u.copy()
        un[1:-1, 1:-1] = u[1:-1, 1:-1] - cx * (
            u[1:-1, 1:-1] - u[0:-2, 1:-1]
        ) - cy * (u[1:-1, 1:-1] - u[1:-1, 0:-2])
        u = un
    return float(u[-1, ny // 2])


def combustion_passive() -> float:
    sc = bench_scale("combustion_passive")
    n, steps = sc.n or 128, sc.steps or 3000
    dt, burn = 0.02, 0.1
    fuel = np.ones(n, dtype=np.float64)
    temp = np.full(n, 300.0, dtype=np.float64)
    for _ in range(steps):
        burned = np.minimum(burn * dt * fuel, fuel)
        fuel -= burned
        temp += burned * 100.0
    return float(temp[0])


def schrodinger_1d_barrier() -> float:
    sc = bench_scale("schrodinger_1d_barrier")
    n, steps = sc.n or 128, sc.steps or 8000
    dt, dx, v0 = 0.00005, 0.08, 8.0
    inv_dx2 = 1.0 / (dx * dx)
    i0, i1 = n // 3, (2 * n) // 3
    x = (np.arange(n, dtype=np.float64) - n / 2) * 0.12
    re = np.exp(-0.5 * x * x)
    im = np.zeros(n, dtype=np.float64)
    v = np.where((np.arange(n) > i0) & (np.arange(n) < i1), v0, 0.0)
    for _ in range(steps):
        lap_re = (re[2:] - 2.0 * re[1:-1] + re[:-2]) * inv_dx2
        lap_im = (im[2:] - 2.0 * im[1:-1] + im[:-2]) * inv_dx2
        re[1:-1] += dt * (lap_re - v[1:-1] * re[1:-1])
        im[1:-1] += dt * (lap_im - v[1:-1] * im[1:-1])
    return float(np.sum(re * re + im * im))


def fdtd_waveguide_2d() -> float:
    sc = bench_scale("fdtd_waveguide_2d")
    n, steps = sc.n or 128, sc.steps or 8000
    dt, dx, c = 0.001, 0.01, 1.0
    ce = c * dt / dx
    ex = np.zeros(n, dtype=np.float64)
    hz = np.zeros(n, dtype=np.float64)
    ex[0] = 1.0
    for _ in range(steps):
        hz[1:-1] -= ce * (ex[1:-1] - ex[:-2])
        ex[1:-1] -= ce * (hz[1:-1] - hz[:-2])
    return float(ex[n // 2])


def rigid_body_stack() -> float:
    sc = bench_scale("rigid_body_stack")
    n, steps = sc.n or 50, sc.steps or 2000
    dt, g = 1.0 / 60.0, 9.81
    y = np.linspace(1.0, 0.5, n, dtype=np.float64)
    vy = np.zeros(n, dtype=np.float64)
    for _ in range(steps):
        vy -= g * dt
        y += vy * dt
        y = np.maximum(y, 0.0)
        vy = np.where(y <= 0.0, 0.0, vy)
    return float(y[-1])


def cloth_swing() -> float:
    sc = bench_scale("cloth_swing")
    n, steps = sc.n or 16, sc.steps or 8000
    dt, rest, stiff = 1.0 / 60.0, 0.2, 0.95
    px = np.arange(n, dtype=np.float64) * rest
    py = np.ones(n, dtype=np.float64)
    vx = np.zeros(n, dtype=np.float64)
    vy = np.zeros(n, dtype=np.float64)
    px[0], py[0], vx[0], vy[0] = 0.0, 1.0, 0.0, 0.0
    for _ in range(steps):
        for _ in range(4):
            for i in range(n - 1):
                dx, dy = px[i + 1] - px[i], py[i + 1] - py[i]
                length = math.hypot(dx, dy)
                if length < 1e-12:
                    continue
                corr = stiff * (length - rest) / length
                if i > 0:
                    px[i] += 0.5 * corr * dx
                    py[i] += 0.5 * corr * dy
                px[i + 1] -= 0.5 * corr * dx
                py[i + 1] -= 0.5 * corr * dy
        for i in range(1, n):
            vy[i] -= 9.81 * dt
            px[i] += vx[i] * dt
            py[i] += vy[i] * dt
    return float(py[-1])


def ragdoll_chain() -> float:
    sc = bench_scale("ragdoll_chain")
    joints, steps = sc.n or 12, sc.steps or 3600
    dt, length = 1.0 / 60.0, 0.35
    px = np.zeros(joints, dtype=np.float64)
    py = np.linspace(0.0, -length * (joints - 1), joints, dtype=np.float64)
    vx = np.zeros(joints, dtype=np.float64)
    vy = np.zeros(joints, dtype=np.float64)
    for _ in range(steps):
        vy -= 9.81 * dt
        px += vx * dt
        py += vy * dt
        for i in range(joints - 1):
            dx, dy = px[i + 1] - px[i], py[i + 1] - py[i]
            dist = math.hypot(dx, dy)
            if dist < 1e-12:
                continue
            scale = (dist - length) / dist
            px[i + 1] -= 0.5 * scale * dx
            py[i + 1] -= 0.5 * scale * dy
            px[i] += 0.5 * scale * dx
            py[i] += 0.5 * scale * dy
    return float(py[-1])


def orbit_two_body() -> float:
    steps = bench_scale("orbit_two_body").steps or 100_000
    dt, mu, r0 = 0.001, 1.0, 1.0
    x, y = r0, 0.0
    vx, vy = 0.0, math.sqrt(mu / r0)
    for _ in range(steps):
        r2 = x * x + y * y + 1e-12
        r3 = r2 * math.sqrt(r2)
        ax = -mu * x / r3
        ay = -mu * y / r3
        vx += dt * ax
        vy += dt * ay
        x += dt * vx
        y += dt * vy
    return float(x)


def sph_dam_break_2d() -> float:
    sc = bench_scale("sph_dam_break_2d")
    n, steps = sc.n or 512, sc.steps or 10_000
    h, dt, g, k = 0.08, 0.00025, 9.81, 500.0
    box = 1.0
    nx, ny, dx = 32, 16, 0.03
    pos = np.zeros((n, 2), dtype=np.float64)
    vel = np.zeros((n, 2), dtype=np.float64)
    idx = 0
    for j in range(ny):
        for i in range(nx):
            if idx >= n:
                break
            pos[idx, 0] = 0.05 + i * dx
            pos[idx, 1] = 0.05 + j * dx
            idx += 1
    for _ in range(steps):
        acc = np.zeros((n, 2), dtype=np.float64)
        acc[:, 1] = -g
        for i in range(n):
            for j in range(i + 1, n):
                rx, ry = pos[j, 0] - pos[i, 0], pos[j, 1] - pos[i, 1]
                r2 = rx * rx + ry * ry + 1e-12
                r = math.sqrt(r2)
                if r >= h:
                    continue
                q = 1.0 - r / h
                f = k * q * q / r
                fx, fy = f * rx, f * ry
                acc[i, 0] -= fx
                acc[i, 1] -= fy
                acc[j, 0] += fx
                acc[j, 1] += fy
        vel += 0.5 * dt * acc
        pos += dt * vel
        acc[:, 1] = -g
        for i in range(n):
            for j in range(i + 1, n):
                rx, ry = pos[j, 0] - pos[i, 0], pos[j, 1] - pos[i, 1]
                r2 = rx * rx + ry * ry + 1e-12
                r = math.sqrt(r2)
                if r >= h:
                    continue
                q = 1.0 - r / h
                f = k * q * q / r
                fx, fy = f * rx, f * ry
                acc[i, 0] -= fx
                acc[i, 1] -= fy
                acc[j, 0] += fx
                acc[j, 1] += fy
        vel += 0.5 * dt * acc
        pos[:, 0] = np.clip(pos[:, 0], 0.0, box)
        pos[:, 1] = np.clip(pos[:, 1], 0.0, box)
    return float(np.sum(pos[:, 1]))


def three_body() -> float:
    steps = bench_scale("three_body").steps or 10_000_000
    dt, g, soft, mass = 0.01, 1.0, 1e-9, 1.0
    r = 1.0
    px = np.array([0.0, -0.8660254037844386 * r, 0.8660254037844386 * r], dtype=np.float64)
    py = np.array([r, -0.5 * r, -0.5 * r], dtype=np.float64)
    vx = np.zeros(3, dtype=np.float64)
    vy = np.zeros(3, dtype=np.float64)
    eps2 = soft * soft

    def forces() -> tuple[np.ndarray, np.ndarray]:
        fx = np.zeros(3, dtype=np.float64)
        fy = np.zeros(3, dtype=np.float64)
        for i in range(3):
            for j in range(i + 1, 3):
                dx, dy = px[j] - px[i], py[j] - py[i]
                r2 = dx * dx + dy * dy + eps2
                inv_r3 = 1.0 / (r2 * math.sqrt(r2))
                scale = g * mass * mass * inv_r3
                fx_ij, fy_ij = scale * dx, scale * dy
                fx[i] += fx_ij
                fy[i] += fy_ij
                fx[j] -= fx_ij
                fy[j] -= fy_ij
        return fx, fy

    def energy() -> float:
        ke = 0.5 * mass * np.sum(vx * vx + vy * vy)
        pe = 0.0
        for i in range(3):
            for j in range(i + 1, 3):
                dx, dy = px[j] - px[i], py[j] - py[i]
                pe -= g * mass * mass / math.sqrt(dx * dx + dy * dy + eps2)
        return float(ke + pe)

    fx, fy = forces()
    for _ in range(steps):
        vx += 0.5 * dt * fx / mass
        vy += 0.5 * dt * fy / mass
        px += dt * vx
        py += dt * vy
        fx, fy = forces()
        vx += 0.5 * dt * fx / mass
        vy += 0.5 * dt * fy / mass
    return energy()


def _c_lcg_rng(seed: int):
    """Match tier2 nbody_gravity/common/nbody_core.c LiNbRng."""
    state = seed & ((1 << 64) - 1)

    def next_u01() -> float:
        nonlocal state
        state = (state * 6364136223846793005 + 1) & ((1 << 64) - 1)
        return (state >> 11) / float(1 << 53)

    return next_u01


def nbody_gravity() -> float:
    sc = bench_scale("nbody_gravity")
    n, steps = sc.n or 128, sc.steps or 50_000
    dt, g, soft = 0.01, 1.0, 1e-6
    rng = _c_lcg_rng(42)
    pos = np.zeros((n, 3), dtype=np.float64)
    vel = np.zeros((n, 3), dtype=np.float64)
    for i in range(n):
        pos[i, 0] = rng() - 0.5
        pos[i, 1] = rng() - 0.5
        pos[i, 2] = rng() - 0.5
        vel[i, 0] = 0.01 * (rng() - 0.5)
        vel[i, 1] = 0.01 * (rng() - 0.5)
        vel[i, 2] = 0.01 * (rng() - 0.5)
    mass = 1.0
    eps2 = soft * soft

    def accel() -> np.ndarray:
        acc = np.zeros((n, 3), dtype=np.float64)
        for i in range(n):
            for j in range(i + 1, n):
                d = pos[j] - pos[i]
                r2 = float(np.dot(d, d) + eps2)
                inv_r3 = 1.0 / (r2 * math.sqrt(r2))
                scale_f = g * mass * mass * inv_r3
                acc[i] += scale_f * d
                acc[j] -= scale_f * d
        return acc

    acc = accel()
    for _ in range(steps):
        vel += 0.5 * dt * acc / mass
        pos += dt * vel
        acc = accel()
        vel += 0.5 * dt * acc / mass
    ke = 0.5 * mass * np.sum(vel * vel)
    pe = 0.0
    for i in range(n):
        for j in range(i + 1, n):
            d = pos[j] - pos[i]
            pe -= g * mass * mass / math.sqrt(np.dot(d, d) + eps2)
    return float(ke + pe)


def harmonic_oscillator_chain() -> float:
    sc = bench_scale("harmonic_oscillator_chain")
    n, steps = sc.n or 64, sc.steps or 2_000_000
    dt, k, mass, spacing = 0.001, 1.0, 1.0, 1.0
    x = np.arange(n, dtype=np.float64) * spacing
    v = np.zeros(n, dtype=np.float64)
    x[n // 2] += 0.1

    def forces() -> np.ndarray:
        f = np.zeros(n, dtype=np.float64)
        stretch = x[1:] - x[:-1] - spacing
        f[:-1] += k * stretch
        f[1:] -= k * stretch
        f[0] = 0.0
        f[-1] = 0.0
        return f

    f = forces()
    for _ in range(steps):
        v += 0.5 * dt * f / mass
        x += dt * v
        x[0] = 0.0
        x[-1] = (n - 1) * spacing
        v[0] = 0.0
        v[-1] = 0.0
        f = forces()
        v += 0.5 * dt * f / mass
    ke = 0.5 * mass * np.sum(v * v)
    pe = 0.5 * k * np.sum((x[1:] - x[:-1] - spacing) ** 2)
    return float(ke + pe)


def wave_equation_1d() -> float:
    sc = bench_scale("wave_equation_1d")
    n, steps = sc.n or 8192, sc.steps or 400_000
    c, dx, dt = 1.0, 0.01, 0.004
    r2 = (c * dt / dx) ** 2
    center = 0.5 * (n - 1) * dx
    width = 0.15
    xs = np.arange(n, dtype=np.float64) * dx
    u1 = np.exp(-((xs - center) / width) ** 2)
    u0 = u1.copy()
    u2 = u1.copy()
    u0[0] = u0[-1] = 0.0
    u1[0] = u1[-1] = 0.0
    for _ in range(steps):
        u2[1:-1] = (
            2.0 * u1[1:-1]
            - u0[1:-1]
            + r2 * (u1[2:] - 2.0 * u1[1:-1] + u1[:-2])
        )
        u2[0] = u2[-1] = 0.0
        u0, u1, u2 = u1, u2, u0
    v = (u1[1:-1] - u0[1:-1]) / dt
    du = (u1[2:] - u1[:-2]) / (2.0 * dx)
    e = 0.5 * np.sum(v * v + c * c * du * du)
    return float(e)


def wave_equation_2d() -> float:
    sc = bench_scale("wave_equation_2d")
    nx, ny, steps = sc.nx or 128, sc.ny or 128, sc.steps or 25_000
    c, dx, dt = 1.0, 0.01, 0.004
    r2 = (c * dt / dx) ** 2
    u = np.zeros((nx, ny), dtype=np.float64)
    u_prev = np.zeros_like(u)
    u_next = np.zeros_like(u)
    u[nx // 4, ny // 4] = 1.0
    for _ in range(steps):
        u_next[1:-1, 1:-1] = (
            2.0 * u[1:-1, 1:-1]
            - u_prev[1:-1, 1:-1]
            + r2
            * (
                u[2:, 1:-1]
                + u[:-2, 1:-1]
                + u[1:-1, 2:]
                + u[1:-1, :-2]
                - 4.0 * u[1:-1, 1:-1]
            )
        )
        u_prev, u, u_next = u, u_next, u_prev
    return float(u[nx // 2, ny // 2])


def heat_equation_2d() -> float:
    sc = bench_scale("heat_equation_2d")
    nx, ny, steps = sc.nx or 128, sc.ny or 128, sc.steps or 20_000
    alpha, dx, dt = 0.25, 0.01, 0.0001
    r = alpha * dt / (dx * dx)
    u = np.zeros((nx, ny), dtype=np.float64)
    u[nx // 4, ny // 4] = 1.0
    for _ in range(steps):
        un = u.copy()
        un[1:-1, 1:-1] = u[1:-1, 1:-1] + r * (
            u[2:, 1:-1]
            + u[:-2, 1:-1]
            + u[1:-1, 2:]
            + u[1:-1, :-2]
            - 4.0 * u[1:-1, 1:-1]
        )
        u = un
    return float(u[nx // 2, ny // 2])


def advection_diffusion_2d() -> float:
    sc = bench_scale("advection_diffusion_2d")
    nx, ny, steps = sc.nx or 128, sc.ny or 128, sc.steps or 15_000
    dx, dt, vx, vy, diff = 0.01, 0.0002, 0.8, 0.2, 0.05
    r = diff * dt / (dx * dx)
    cfx, cfy = vx * dt / dx, vy * dt / dx
    xs = np.arange(nx, dtype=np.float64)[:, None] * dx
    ys = np.arange(ny, dtype=np.float64)[None, :] * dx
    u = np.exp(-((xs - 0.35) ** 2 + (ys - 0.35) ** 2) / 0.002)
    for _ in range(steps):
        un = u.copy()
        un[1:-1, 1:-1] = (
            u[1:-1, 1:-1]
            - cfx * (u[1:-1, 1:-1] - u[:-2, 1:-1])
            - cfy * (u[1:-1, 1:-1] - u[1:-1, :-2])
            + r
            * (
                u[2:, 1:-1]
                + u[:-2, 1:-1]
                + u[1:-1, 2:]
                + u[1:-1, :-2]
                - 4.0 * u[1:-1, 1:-1]
            )
        )
        u = un
    return float(np.sum(u))


def double_pendulum() -> float:
    steps = bench_scale("double_pendulum").steps or 3_000_000
    dt = 0.0005
    m1, m2, l1, l2, g = 1.0, 1.0, 1.0, 1.0, 9.81
    y = np.array([2.0, 2.2, 0.0, 0.0], dtype=np.float64)

    def derivs(state: np.ndarray) -> np.ndarray:
        t1, t2, w1, w2 = state
        delta = t1 - t2
        c, s = math.cos(delta), math.sin(delta)
        den1 = (m1 + m2) * l1 - m2 * l1 * c * c
        den2 = (l2 / l1) * den1
        dydt = np.zeros(4, dtype=np.float64)
        dydt[0] = w1
        dydt[1] = w2
        dydt[2] = (
            -m2 * l1 * w1 * w1 * s * c
            + m2 * g * math.sin(t2) * c
            + m2 * l2 * w2 * w2 * s
            - (m1 + m2) * g * math.sin(t1)
        ) / den1
        dydt[3] = (
            -m2 * l2 * w2 * w2 * s * c
            + (m1 + m2) * (g * math.sin(t1) * c - l1 * w1 * w1 * s - g * math.sin(t2))
        ) / den2
        return dydt

    h = dt
    for _ in range(steps):
        k1 = derivs(y)
        k2 = derivs(y + 0.5 * h * k1)
        k3 = derivs(y + 0.5 * h * k2)
        k4 = derivs(y + h * k3)
        y += (h / 6.0) * (k1 + 2.0 * k2 + 2.0 * k3 + k4)
    t1, t2, w1, w2 = y
    delta = t1 - t2
    v1_sq = l1 * l1 * w1 * w1
    v2_sq = l1 * l1 * w1 * w1 + l2 * l2 * w2 * w2 + 2.0 * l1 * l2 * w1 * w2 * math.cos(delta)
    ke = 0.5 * m1 * v1_sq + 0.5 * m2 * v2_sq
    pe = -(m1 + m2) * g * l1 * math.cos(t1) - m2 * g * l2 * math.cos(t2)
    return float(ke + pe)


def md_lennard_jones() -> float:
    sc = bench_scale("md_lennard_jones")
    n, steps = sc.n or 256, sc.steps or 10_000
    dt, rc, box, temp = 0.004, 2.5, 10.0, 1.0
    rc2 = rc * rc
    rng = _rng(7)
    px = np.zeros(n, dtype=np.float64)
    py = np.zeros(n, dtype=np.float64)
    pz = np.zeros(n, dtype=np.float64)
    basis = np.array([[0, 0, 0], [0, 0.5, 0.5], [0.5, 0, 0.5], [0.5, 0.5, 0]], dtype=np.float64)
    k = 1
    while 4 * k * k * k < n:
        k += 1
    a = box / k
    idx = 0
    for ix in range(k):
        for iy in range(k):
            for iz in range(k):
                for b in range(4):
                    if idx >= n:
                        break
                    px[idx] = (ix + basis[b, 0]) * a
                    py[idx] = (iy + basis[b, 1]) * a
                    pz[idx] = (iz + basis[b, 2]) * a
                    idx += 1
    vx = rng.normal(size=n)
    vy = rng.normal(size=n)
    vz = rng.normal(size=n)
    scale = math.sqrt(temp)
    vx *= scale
    vy *= scale
    vz *= scale
    vx -= vx.mean()
    vy -= vy.mean()
    vz -= vz.mean()
    ke = 0.5 * np.sum(vx * vx + vy * vy + vz * vz)
    target = 1.5 * n * temp
    if ke > 1e-20:
        s = math.sqrt(target / ke)
        vx *= s
        vy *= s
        vz *= s

    def mic(d: float) -> float:
        half = 0.5 * box
        if d > half:
            return d - box
        if d < -half:
            return d + box
        return d

    def wrap(x: float) -> float:
        x = math.fmod(x, box)
        if x < 0:
            x += box
        return x

    def potential() -> float:
        pe = 0.0
        for i in range(n):
            for j in range(i + 1, n):
                dx = mic(px[j] - px[i])
                dy = mic(py[j] - py[i])
                dz = mic(pz[j] - pz[i])
                r2 = dx * dx + dy * dy + dz * dz
                if r2 >= rc2 or r2 < 1e-12:
                    continue
                inv_r2 = 1.0 / r2
                inv_r6 = inv_r2**3
                inv_r12 = inv_r6 * inv_r6
                pe += 4.0 * (inv_r12 - inv_r6)
        return pe

    def forces() -> tuple[np.ndarray, np.ndarray, np.ndarray]:
        fx = np.zeros(n, dtype=np.float64)
        fy = np.zeros(n, dtype=np.float64)
        fz = np.zeros(n, dtype=np.float64)
        for i in range(n):
            for j in range(i + 1, n):
                dx = mic(px[j] - px[i])
                dy = mic(py[j] - py[i])
                dz = mic(pz[j] - pz[i])
                r2 = dx * dx + dy * dy + dz * dz
                if r2 >= rc2 or r2 < 1e-12:
                    continue
                inv_r2 = 1.0 / r2
                inv_r6 = inv_r2**3
                inv_r12 = inv_r6 * inv_r6
                f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6
                fx_ij = f_scalar * dx
                fy_ij = f_scalar * dy
                fz_ij = f_scalar * dz
                fx[i] -= fx_ij
                fy[i] -= fy_ij
                fz[i] -= fz_ij
                fx[j] += fx_ij
                fy[j] += fy_ij
                fz[j] += fz_ij
        return fx, fy, fz

    ke0 = 0.5 * np.sum(vx * vx + vy * vy + vz * vz)
    e0 = potential() + ke0
    fx, fy, fz = forces()
    for _ in range(steps):
        vx += 0.5 * dt * fx
        vy += 0.5 * dt * fy
        vz += 0.5 * dt * fz
        for i in range(n):
            px[i] = wrap(px[i] + dt * vx[i])
            py[i] = wrap(py[i] + dt * vy[i])
            pz[i] = wrap(pz[i] + dt * vz[i])
        fx, fy, fz = forces()
        vx += 0.5 * dt * fx
        vy += 0.5 * dt * fy
        vz += 0.5 * dt * fz
    ke1 = 0.5 * np.sum(vx * vx + vy * vy + vz * vz)
    e1 = potential() + ke1
    denom = e0 if e0 >= e1 else e1
    if denom < 1e-12:
        denom = 1e-12
    diff = e1 - e0
    return abs(diff) / denom


KERNELS: dict[str, Callable[[], float]] = {
    "simd_dot": simd_dot,
    "matmul_naive": matmul_naive,
    "matmul_naive_n128": matmul_naive_n128,
    "matmul_blocked": matmul_blocked,
    "matmul_blocked_n128": matmul_blocked_n128,
    "matmul_blocked_n1024": matmul_blocked_n1024,
    "reduce_sum": reduce_sum,
    "horner_pure_li": horner_pure_li,
    "md_lennard_jones": md_lennard_jones,
    "three_body": three_body,
    "nbody_gravity": nbody_gravity,
    "harmonic_oscillator_chain": harmonic_oscillator_chain,
    "wave_equation_1d": wave_equation_1d,
    "heat_equation_2d": heat_equation_2d,
    "double_pendulum": double_pendulum,
    "advection_diffusion_2d": advection_diffusion_2d,
    "wave_equation_2d": wave_equation_2d,
    "sph_dam_break_2d": sph_dam_break_2d,
    "euler_fluid_2d": euler_fluid_2d,
    "combustion_passive": combustion_passive,
    "wind_field_bc": wind_field_bc,
    "rigid_body_stack": rigid_body_stack,
    "cloth_swing": cloth_swing,
    "orbit_two_body": orbit_two_body,
    "fdtd_waveguide_2d": fdtd_waveguide_2d,
    "schrodinger_1d_barrier": schrodinger_1d_barrier,
    "ragdoll_chain": ragdoll_chain,
}
