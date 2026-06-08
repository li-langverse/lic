#!/usr/bin/env python3
"""External MD oracle stub for md_oracle_external / md_lennard_jones (LAMMPS/GROMACS column).

Default: record native md_core --verify reference when tier-2 tree exists.
Dry-run: emit stub manifest without building (CI / study gates).

Set LI_MD_ORACLE_LAMMPS=1 with lammps on PATH to reserve exit 2 until B1 driver ships.
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
MD_DIR = REPO / "benchmarks" / "tier2_physics" / "md_lennard_jones"
MD_ORACLE_DIR = REPO / "benchmarks" / "tier2_physics" / "md_oracle_external"
BUILD_DIR = REPO / "build" / "bench" / "md_lennard_jones"
ORACLE_TOML = REPO / "benchmarks" / "competitive" / "md_oracle.toml"
OUT_JSON = REPO / "benchmarks" / "results" / "md_oracle_external" / "oracle_stub.json"
NATIVE_FLAGS = ["-O3", "-march=native", "-ffast-math"]


def native_reference_drift() -> str:
    main_c = MD_DIR / "cpp" / "md_main.c"
    core_c = MD_DIR / "common" / "md_core.c"
    if not main_c.is_file() or not core_c.is_file():
        return "dry_run_stub"

    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    native = BUILD_DIR / "md_oracle_ref"
    cc = os.environ.get("CC", "")
    if not cc or not shutil.which(cc):
        for candidate in ("clang-22", "clang"):
            if shutil.which(candidate):
                cc = candidate
                break
        else:
            raise RuntimeError("no C compiler (set CC or install clang)")
    subprocess.check_call(
        [cc, *NATIVE_FLAGS, str(main_c), str(core_c), "-lm", "-o", str(native)],
        cwd=REPO,
    )
    return subprocess.check_output([str(native), "--verify"], text=True).strip()


def load_oracle_ids() -> list[str]:
    if not ORACLE_TOML.is_file():
        return ["lammps_lj_micro", "gromacs_lj_micro"]
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib  # type: ignore

    data = tomllib.loads(ORACLE_TOML.read_text())
    rows = data.get("oracle") or []
    return [str(row["id"]) for row in rows if isinstance(row, dict) and "id" in row]


def check_real_driver_requested(engine: str) -> list[str]:
    pending: list[str] = []
    if engine in ("lammps", "all") and os.environ.get("LI_MD_ORACLE_LAMMPS", "") == "1":
        lammps = os.environ.get("LAMMPS_BIN") or shutil.which("lammps")
        if lammps:
            pending.append("lammps")
    if engine in ("gromacs", "all") and os.environ.get("LI_MD_ORACLE_GROMACS", "") == "1":
        gmx = os.environ.get("GMX_BIN") or shutil.which("gmx")
        if gmx:
            pending.append("gromacs")
    return pending


def write_manifest(
    *,
    reference: str,
    mode: str,
    pending: list[str],
    engine: str,
    dry_run: bool,
) -> Path:
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    manifest = {
        "schema": "li_sim_summary_v1",
        "benchmark": "md_oracle_external",
        "vertical_id": "md_lennard_jones",
        "mode": mode,
        "engine": engine,
        "dry_run": dry_run,
        "reference_energy_drift": reference,
        "oracle_ids": load_oracle_ids(),
        "pending_real_drivers": pending,
        "driver": "benchmarks/harness/md_external_oracle.py",
        "tier2_path": "benchmarks/tier2_physics/md_oracle_external",
        "updated": datetime.now(timezone.utc).isoformat(),
        "plan": "docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md",
    }
    OUT_JSON.write_text(json.dumps(manifest, indent=2) + "\n")
    return OUT_JSON


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="External MD oracle stub (LAMMPS/GROMACS)")
    parser.add_argument(
        "--engine",
        choices=["lammps", "gromacs", "skip", "all"],
        default="skip",
        help="Target external engine column (default: skip = stub only)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Emit stub manifest without building native reference",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)

    if not ORACLE_TOML.is_file():
        print(f"error: missing {ORACLE_TOML}", file=sys.stderr)
        return 1

    if args.dry_run:
        reference = "dry_run_stub"
        pending: list[str] = []
        mode = "stub_ok"
    else:
        reference = native_reference_drift()
        pending = check_real_driver_requested(args.engine)
        if pending:
            write_manifest(
                reference=reference,
                mode="stub_blocked",
                pending=pending,
                engine=args.engine,
                dry_run=False,
            )
            names = ", ".join(pending)
            print(
                f"md external oracle: real driver requested for {names} but not implemented (B1/B2)",
                file=sys.stderr,
            )
            return 2
        mode = "stub_ok"

    out = write_manifest(
        reference=reference,
        mode=mode,
        pending=pending,
        engine=args.engine,
        dry_run=args.dry_run,
    )
    print(f"md external oracle stub ok: reference_drift={reference} engine={args.engine}")
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
