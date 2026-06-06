#!/usr/bin/env python3
"""External MD oracle stub for md_lennard_jones (LAMMPS/GROMACS column plan).

Default: record Li-internal reference drift (Python mirror of sim_scientific_oracle_checksum_md).
No LAMMPS/GROMACS binary required. Set LI_MD_ORACLE_LAMMPS=1 with lammps on PATH to reserve
exit 2 until B1 driver ships.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
MD_DIR = REPO / "benchmarks" / "tier2_physics" / "md_lennard_jones"
ORACLE_TOML = REPO / "benchmarks" / "competitive" / "md_oracle.toml"
OUT_DIR = REPO / "benchmarks" / "results" / "md_lennard_jones"
OUT_JSON = OUT_DIR / "oracle_stub.json"


def _load_oracle_registry() -> dict:
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib  # type: ignore

    if not ORACLE_TOML.is_file():
        raise SystemExit(f"missing oracle registry: {ORACLE_TOML}")
    return tomllib.loads(ORACLE_TOML.read_text(encoding="utf-8"))


def _lj_fx(dx: float, r2: float, rc2: float) -> float:
    if r2 >= rc2 or r2 < 1.0e-12:
        return 0.0
    inv_r2 = 1.0 / r2
    inv_r6 = inv_r2 * inv_r2 * inv_r2
    inv_r12 = inv_r6 * inv_r6
    f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6
    return f_scalar * dx


def _lj_pe(r2: float, rc2: float) -> float:
    if r2 >= rc2 or r2 < 1.0e-12:
        return 0.0
    inv_r2 = 1.0 / r2
    inv_r6 = inv_r2 * inv_r2 * inv_r2
    inv_r12 = inv_r6 * inv_r6
    return 4.0 * (inv_r12 - inv_r6)


def _chain_energy(px, py, vx, vy) -> float:
    rc2 = 2.5 * 2.5
    pe = 0.0
    ke = 0.0
    for i in range(4):
        ke += 0.5 * (vx[i] * vx[i] + vy[i] * vy[i])
        for j in range(i + 1, 4):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            pe += _lj_pe(r2, rc2)
    return pe + ke


def _chain_forces(px, py, fx, fy) -> None:
    rc2 = 2.5 * 2.5
    for i in range(4):
        fx[i] = 0.0
        fy[i] = 0.0
    for i in range(4):
        for j in range(i + 1, 4):
            dx = px[j] - px[i]
            dy = py[j] - py[i]
            r2 = dx * dx + dy * dy
            fxi = _lj_fx(dx, r2, rc2)
            fyi = _lj_fx(dy, r2, rc2)
            fx[i] -= fxi
            fy[i] -= fyi
            fx[j] += fxi
            fy[j] += fyi


def li_reference_energy_drift() -> float:
    """Mirror packages/li-sim-scientific sim_scientific_oracle_checksum_md()."""
    spacing = 1.12
    dt = 0.004
    px = [i * spacing for i in range(4)]
    py = [0.0] * 4
    vx = [0.0] * 4
    vy = [0.0] * 4
    fx = [0.0] * 4
    fy = [0.0] * 4
    e0 = _chain_energy(px, py, vx, vy)
    for _ in range(8):
        _chain_forces(px, py, fx, fy)
        for i in range(4):
            vx[i] += 0.5 * dt * fx[i]
            vy[i] += 0.5 * dt * fy[i]
        for i in range(4):
            px[i] += dt * vx[i]
            py[i] += dt * vy[i]
        _chain_forces(px, py, fx, fy)
        for i in range(4):
            vx[i] += 0.5 * dt * fx[i]
            vy[i] += 0.5 * dt * fy[i]
    e1 = _chain_energy(px, py, vx, vy)
    denom = max(abs(e0), abs(e1), 1.0e-12)
    return abs(e1 - e0) / denom


def _try_cpp_reference() -> float | None:
    cpp_main = MD_DIR / "cpp" / "md_main.c"
    if not cpp_main.is_file():
        return None
    build_dir = REPO / "build" / "bench" / "md_lennard_jones"
    build_dir.mkdir(parents=True, exist_ok=True)
    bin_path = build_dir / "md_ref"
    common_c = MD_DIR / "common" / "md_core.c"
    if not common_c.is_file():
        return None
    cc = os.environ.get("CC", "cc")
    cmd = [
        cc,
        "-O2",
        "-I",
        str(MD_DIR / "common"),
        str(cpp_main),
        str(common_c),
        "-lm",
        "-o",
        str(bin_path),
    ]
    try:
        subprocess.run(cmd, check=True, capture_output=True, cwd=REPO)
        proc = subprocess.run([str(bin_path), "--verify"], capture_output=True, text=True, cwd=REPO)
        if proc.returncode != 0:
            return None
        for line in proc.stdout.splitlines():
            if "energy_drift" in line.lower():
                parts = line.split("=")
                if len(parts) >= 2:
                    return float(parts[-1].strip())
    except (OSError, subprocess.CalledProcessError, ValueError):
        return None
    return None


def _external_attempt(kind: str) -> dict:
    flag = f"LI_MD_ORACLE_{kind.upper()}=1"
    if os.environ.get(f"LI_MD_ORACLE_{kind.upper()}") != "1":
        return {"executed": False, "note": f"set {flag} for B1+ driver"}
    binary = kind
    if not shutil.which(binary):
        return {"executed": False, "note": f"{binary} not on PATH"}
    return {"executed": False, "note": f"{kind} driver reserved (exit 2) — implement B1/B2"}


def main() -> int:
    reg = _load_oracle_registry()
    oracles = reg.get("oracle") or []
    oracle_ids = [o.get("id") for o in oracles if isinstance(o, dict) and o.get("id")]

    drift = _try_cpp_reference()
    reference_source = "cpp_md_core"
    if drift is None:
        drift = li_reference_energy_drift()
        reference_source = "li_oracle_python_mirror"

    if os.environ.get("LI_MD_ORACLE_LAMMPS") == "1" and shutil.which("lammps"):
        print("lammps present but B1 driver not shipped", file=sys.stderr)
        return 2
    if os.environ.get("LI_MD_ORACLE_GROMACS") == "1" and shutil.which("gmx"):
        print("gromacs present but B2 driver not shipped", file=sys.stderr)
        return 2

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    doc = {
        "schema": "li_md_external_oracle_stub_v1",
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "mode": "stub_ok",
        "benchmark": reg.get("meta", {}).get("benchmark", "md_lennard_jones"),
        "oracle_registry": str(ORACLE_TOML.relative_to(REPO)),
        "driver": "benchmarks/harness/md_external_oracle.py",
        "oracle_ids": oracle_ids,
        "reference_energy_drift": drift,
        "reference_source": reference_source,
        "workload_class": "v0_micro",
        "external": {
            "lammps": _external_attempt("lammps"),
            "gromacs": _external_attempt("gromacs"),
        },
        "plan": "docs/benchmarks/competitive-engines-plan.md",
        "study": "docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md",
    }
    OUT_JSON.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {OUT_JSON}")
    print(f"reference_energy_drift={drift} source={reference_source}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
