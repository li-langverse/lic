#!/usr/bin/env python3
"""External MD oracle stub for md_lennard_jones (LAMMPS/GROMACS column plan).

Default: record Li micro oracle reference; no domain binary required.
Set LI_MD_ORACLE_LAMMPS=1 with lammps on PATH to reserve exit 2 until B1 driver ships.
"""

from __future__ import annotations

import json
import os
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
ORACLE_TOML = REPO / "benchmarks" / "competitive" / "md_oracle.toml"
OUT_JSON = REPO / "benchmarks" / "results" / "md_lennard_jones" / "oracle_stub.json"


def lj_fx_pair(dx: float, r2: float, rc2: float) -> float:
    if r2 >= rc2 or r2 < 1.0e-12:
        return 0.0
    inv_r2 = 1.0 / r2
    inv_r6 = inv_r2 * inv_r2 * inv_r2
    inv_r12 = inv_r6 * inv_r6
    f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6
    return f_scalar * dx


def lj_pe_pair(r2: float, rc2: float) -> float:
    if r2 >= rc2 or r2 < 1.0e-12:
        return 0.0
    inv_r2 = 1.0 / r2
    inv_r6 = inv_r2 * inv_r2 * inv_r2
    inv_r12 = inv_r6 * inv_r6
    return 4.0 * (inv_r12 - inv_r6)


def chain_energy(px: list[float], py: list[float], vx: list[float], vy: list[float]) -> float:
    rc2 = 2.5 * 2.5
    pe = 0.0
    ke = 0.0
    for i in range(4):
        ke += 0.5 * (vx[i] * vx[i] + vy[i] * vy[i])
        for j in range(i + 1, 4):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            pe += lj_pe_pair(r2, rc2)
    return pe + ke


def chain_forces(px: list[float], py: list[float]) -> tuple[list[float], list[float]]:
    rc2 = 2.5 * 2.5
    fx = [0.0] * 4
    fy = [0.0] * 4
    for i in range(4):
        for j in range(i + 1, 4):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            fxi = lj_fx_pair(dx, r2, rc2)
            fyi = lj_fx_pair(dy, r2, rc2)
            fx[i] -= fxi
            fy[i] -= fyi
            fx[j] += fxi
            fy[j] += fyi
    return fx, fy


def li_micro_oracle_checksum() -> float:
    """Mirror sim_scientific_oracle_checksum_md() in packages/li-sim-scientific."""
    spacing = 1.12
    dt = 0.004
    px = [i * spacing for i in range(4)]
    py = [0.0] * 4
    vx = [0.0] * 4
    vy = [0.0] * 4
    e0 = chain_energy(px, py, vx, vy)
    for _ in range(8):
        fx, fy = chain_forces(px, py)
        for i in range(4):
            vx[i] += 0.5 * dt * fx[i]
            vy[i] += 0.5 * dt * fy[i]
        for i in range(4):
            px[i] += dt * vx[i]
            py[i] += dt * vy[i]
        fx, fy = chain_forces(px, py)
        for i in range(4):
            vx[i] += 0.5 * dt * fx[i]
            vy[i] += 0.5 * dt * fy[i]
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


def load_oracle_ids() -> list[str]:
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib  # type: ignore

    data = tomllib.loads(ORACLE_TOML.read_text())
    rows = data.get("oracle") or []
    return [str(row["id"]) for row in rows if isinstance(row, dict) and "id" in row]


def check_real_driver_requested() -> list[str]:
    pending: list[str] = []
    if os.environ.get("LI_MD_ORACLE_LAMMPS", "") == "1":
        lammps = os.environ.get("LAMMPS_BIN") or shutil.which("lammps")
        if lammps:
            pending.append("lammps")
    if os.environ.get("LI_MD_ORACLE_GROMACS", "") == "1":
        gmx = os.environ.get("GMX_BIN") or shutil.which("gmx")
        if gmx:
            pending.append("gromacs")
    return pending


def write_manifest(*, reference: float, mode: str, pending: list[str]) -> Path:
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    manifest = {
        "schema": "li_md_oracle_stub_v1",
        "benchmark": "md_lennard_jones",
        "mode": mode,
        "reference_energy_drift": reference,
        "oracle_ids": load_oracle_ids(),
        "pending_real_drivers": pending,
        "updated": datetime.now(timezone.utc).isoformat(),
        "plan": "docs/benchmarks/competitive-engines-plan.md",
        "registry": "benchmarks/competitive/md_oracle.toml",
        "gate_script": "scripts/ph-sci-md-oracle-competitive-gates.sh",
        "li_tests": "li-tests/tooling/md_external_oracle_stub.sh",
    }
    OUT_JSON.write_text(json.dumps(manifest, indent=2) + "\n")
    return OUT_JSON


def main() -> int:
    if not ORACLE_TOML.is_file():
        print(f"error: missing {ORACLE_TOML}", file=sys.stderr)
        return 1

    reference = li_micro_oracle_checksum()
    pending = check_real_driver_requested()
    if pending:
        write_manifest(reference=reference, mode="stub_blocked", pending=pending)
        names = ", ".join(pending)
        print(
            f"md external oracle: real driver requested for {names} but not implemented (B1/B2)",
            file=sys.stderr,
        )
        return 2

    out = write_manifest(reference=reference, mode="stub_ok", pending=[])
    print(f"md external oracle stub ok: reference_drift={reference}")
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
