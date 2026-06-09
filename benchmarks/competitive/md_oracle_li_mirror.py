"""Li MD tier-2 oracle mirror — 4-particle LJ chain, 8 velocity-Verlet steps (lib.li)."""
from __future__ import annotations


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


def md_oracle_chain_energy(px: list[float], py: list[float], vx: list[float], vy: list[float]) -> float:
    rc2 = 2.5 * 2.5
    pe = 0.0
    ke = 0.0
    for i in range(4):
        ke += 0.5 * (vx[i] * vx[i] + vy[i] * vy[i])
        for j in range(i + 1, 4):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            pe += md_oracle_lj_pe_pair(r2, rc2)
    return pe + ke


def md_oracle_chain_forces(px: list[float], py: list[float], fx: list[float], fy: list[float]) -> None:
    rc2 = 2.5 * 2.5
    for i in range(4):
        fx[i] = 0.0
        fy[i] = 0.0
    for i in range(4):
        for j in range(i + 1, 4):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            fxi = md_oracle_lj_fx_pair(dx, r2, rc2)
            fyi = md_oracle_lj_fx_pair(dy, r2, rc2)
            fx[i] -= fxi
            fy[i] -= fyi
            fx[j] += fxi
            fy[j] += fyi


def li_sim_scientific_oracle_checksum_md() -> float:
    spacing = 1.12
    dt = 0.004
    px = [i * spacing for i in range(4)]
    py = [0.0] * 4
    vx = [0.0] * 4
    vy = [0.0] * 4
    fx = [0.0] * 4
    fy = [0.0] * 4
    e0 = md_oracle_chain_energy(px, py, vx, vy)
    for _ in range(8):
        md_oracle_chain_forces(px, py, fx, fy)
        for i in range(4):
            vx[i] += 0.5 * dt * fx[i]
            vy[i] += 0.5 * dt * fy[i]
        for i in range(4):
            px[i] += dt * vx[i]
            py[i] += dt * vy[i]
        md_oracle_chain_forces(px, py, fx, fy)
        for i in range(4):
            vx[i] += 0.5 * dt * fx[i]
            vy[i] += 0.5 * dt * fy[i]
    e1 = md_oracle_chain_energy(px, py, vx, vy)
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
