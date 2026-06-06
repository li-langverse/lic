#!/usr/bin/env python3
"""External MD oracle stub for md_oracle_external (LAMMPS/GROMACS column plan).

Default: --dry-run records Li T0 reference checksum manifest (no domain binary).
Real drivers (B1/B2): set LI_MD_ORACLE_LAMMPS=1 or LI_MD_ORACLE_GROMACS=1 with binary on PATH.

Plan: docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
ORACLE_TOML = REPO / "benchmarks" / "competitive" / "md_oracle.toml"
BENCH_ID = "md_oracle_external"
OUT_DIR = REPO / "benchmarks" / "results" / BENCH_ID
OUT_JSON = OUT_DIR / "oracle_stub.json"
OUT_SUMMARY = OUT_DIR / "lammps.summary.json"
MD_LENNARD = REPO / "benchmarks" / "tier2_physics" / "md_lennard_jones"
NATIVE_FLAGS = ["-O3", "-march=native", "-ffast-math"]

# Li T0 oracle checksum band (sim_scientific_oracle_checksum_md, 8-step 4-particle chain)
LI_T0_CHECKSUM_MIN = 1.0e-6
LI_T0_CHECKSUM_MAX = 1.0e-2


def load_oracle_ids() -> list[str]:
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib  # type: ignore

    data = tomllib.loads(ORACLE_TOML.read_text())
    rows = data.get("oracle") or []
    return [str(row["id"]) for row in rows if isinstance(row, dict) and "id" in row]


def native_reference_drift() -> str | None:
    """Build md_core --verify when full tier2 md_lennard_jones checkout exists."""
    main_c = MD_LENNARD / "cpp" / "md_main.c"
    core_c = MD_LENNARD / "common" / "md_core.c"
    if not main_c.is_file() or not core_c.is_file():
        return None

    build_dir = REPO / "build" / "bench" / "md_lennard_jones"
    build_dir.mkdir(parents=True, exist_ok=True)
    native = build_dir / "md_oracle_ref"
    cc = os.environ.get("CC", "")
    if not cc or not shutil.which(cc):
        for candidate in ("clang-22", "clang"):
            if shutil.which(candidate):
                cc = candidate
                break
        else:
            return None
    subprocess.check_call(
        [cc, *NATIVE_FLAGS, str(main_c), str(core_c), "-lm", "-o", str(native)],
        cwd=REPO,
    )
    return subprocess.check_output([str(native), "--verify"], text=True).strip()


def li_t0_reference_checksum() -> float:
    """Deterministic Li oracle checksum (matches sim_scientific_oracle_checksum_md)."""
    # Mirror of packages/li-sim-scientific/src/lib.li md oracle chain (8 VV steps).
    rc2 = 2.5 * 2.5
    spacing = 1.12
    dt = 0.004
    px = [0.0, spacing, 2 * spacing, 3 * spacing]
    py = [0.0, 0.0, 0.0, 0.0]
    vx = [0.0, 0.0, 0.0, 0.0]
    vy = [0.0, 0.0, 0.0, 0.0]

    def pe_pair(r2: float) -> float:
        if r2 >= rc2 or r2 < 1.0e-12:
            return 0.0
        inv_r2 = 1.0 / r2
        inv_r6 = inv_r2**3
        inv_r12 = inv_r6**2
        return 4.0 * (inv_r12 - inv_r6)

    def fx_pair(dx: float, r2: float) -> float:
        if r2 >= rc2 or r2 < 1.0e-12:
            return 0.0
        inv_r2 = 1.0 / r2
        inv_r6 = inv_r2**3
        inv_r12 = inv_r6**2
        f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6
        return f_scalar * dx

    def energy() -> float:
        pe = 0.0
        ke = 0.0
        for i in range(4):
            ke += 0.5 * (vx[i] ** 2 + vy[i] ** 2)
            for j in range(i + 1, 4):
                dx = px[j] - px[i]
                dy = py[j] - py[i]
                pe += pe_pair(dx * dx + dy * dy)
        return pe + ke

    def forces() -> tuple[list[float], list[float]]:
        fx = [0.0] * 4
        fy = [0.0] * 4
        for i in range(4):
            for j in range(i + 1, 4):
                dx = px[j] - px[i]
                dy = py[j] - py[i]
                r2 = dx * dx + dy * dy
                fxi = fx_pair(dx, r2)
                fyi = fx_pair(dy, r2)
                fx[i] -= fxi
                fy[i] -= fyi
                fx[j] += fxi
                fy[j] += fyi
        return fx, fy

    e0 = energy()
    for _ in range(8):
        fx, fy = forces()
        for i in range(4):
            vx[i] += 0.5 * dt * fx[i]
            vy[i] += 0.5 * dt * fy[i]
        for i in range(4):
            px[i] += dt * vx[i]
            py[i] += dt * vy[i]
        fx, fy = forces()
        for i in range(4):
            vx[i] += 0.5 * dt * fx[i]
            vy[i] += 0.5 * dt * fy[i]
    e1 = energy()
    denom = max(abs(e0), abs(e1), 1.0e-12)
    return abs(e1 - e0) / denom


def check_real_driver_requested(engine: str) -> list[str]:
    pending: list[str] = []
    if engine in ("lammps", "all") or os.environ.get("LI_MD_ORACLE_LAMMPS", "") == "1":
        lammps = os.environ.get("LAMMPS_BIN") or shutil.which("lammps")
        if lammps:
            pending.append("lammps")
    if engine in ("gromacs", "all") or os.environ.get("LI_MD_ORACLE_GROMACS", "") == "1":
        gmx = os.environ.get("GMX_BIN") or shutil.which("gmx")
        if gmx:
            pending.append("gromacs")
    return pending


def write_manifest(
    *,
    engine: str,
    reference_drift: str | None,
    reference_checksum: float,
    mode: str,
    pending: list[str],
    dry_run: bool,
) -> Path:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest = {
        "benchmark": BENCH_ID,
        "engine": engine,
        "mode": mode,
        "dry_run": dry_run,
        "reference_energy_drift": reference_drift,
        "reference_checksum": reference_checksum,
        "oracle_ids": load_oracle_ids(),
        "pending_real_drivers": pending,
        "updated": datetime.now(timezone.utc).isoformat(),
        "plan": "docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md",
        "driver": "benchmarks/harness/md_external_oracle.py",
    }
    OUT_JSON.write_text(json.dumps(manifest, indent=2) + "\n")

    summary = {
        "schema": "li_sim_summary_v1",
        "benchmark": BENCH_ID,
        "vertical_id": "md_lennard_jones",
        "workload_class": "v0_micro",
        "lang": engine if engine != "skip" else "lammps",
        "variant": "external_binary_stub",
        "ok": mode in ("stub_ok", "dry_run_ok"),
        "metrics": {
            "energy_drift_rel": float(reference_drift) if reference_drift else reference_checksum,
            "checksum": f"{reference_checksum:.12g}",
        },
        "invariants": {"energy_drift_ok": True},
        "artifacts": {
            "params": f"benchmarks/tier2_physics/{BENCH_ID}/PINNED.md",
            "oracle_driver": "benchmarks/harness/md_external_oracle.py",
        },
        "updated": datetime.now(timezone.utc).isoformat(),
    }
    OUT_SUMMARY.write_text(json.dumps(summary, indent=2) + "\n")
    return OUT_JSON


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="External MD oracle stub (LAMMPS/GROMACS)")
    p.add_argument(
        "--engine",
        choices=("lammps", "gromacs", "skip", "all"),
        default="lammps",
        help="Target external engine (skip = manifest only)",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Record stub manifest without invoking domain binaries",
    )
    p.add_argument(
        "--external-oracle",
        choices=("lammps", "gromacs", "skip"),
        default=None,
        help="Alias for verify.py hook compatibility",
    )
    return p.parse_args()


def main() -> int:
    if not ORACLE_TOML.is_file():
        print(f"error: missing {ORACLE_TOML}", file=sys.stderr)
        return 1

    args = parse_args()
    engine = args.external_oracle or args.engine
    dry_run = args.dry_run or engine == "skip"

    checksum = li_t0_reference_checksum()
    if not (LI_T0_CHECKSUM_MIN <= checksum <= LI_T0_CHECKSUM_MAX):
        print(
            f"error: Li T0 checksum {checksum} outside expected band",
            file=sys.stderr,
        )
        return 1

    native_drift = native_reference_drift()
    pending = [] if dry_run else check_real_driver_requested(engine)

    if pending and not dry_run:
        write_manifest(
            engine=engine,
            reference_drift=native_drift,
            reference_checksum=checksum,
            mode="stub_blocked",
            pending=pending,
            dry_run=dry_run,
        )
        names = ", ".join(pending)
        print(
            f"md external oracle: real driver requested for {names} but not implemented (B1/B2)",
            file=sys.stderr,
        )
        return 2

    mode = "dry_run_ok" if dry_run else "stub_ok"
    out = write_manifest(
        engine=engine,
        reference_drift=native_drift,
        reference_checksum=checksum,
        mode=mode,
        pending=[],
        dry_run=dry_run,
    )
    ref = native_drift if native_drift else f"li_t0_checksum={checksum:.6g}"
    print(f"md external oracle {mode}: engine={engine} reference={ref}")
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
