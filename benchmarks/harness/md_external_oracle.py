#!/usr/bin/env python3
"""External MD oracle stub for md_lennard_jones (LAMMPS/GROMACS column plan).

Default: record native md_core --verify reference; no domain binary required.
Set LI_MD_ORACLE_LAMMPS=1 with lammps on PATH to reserve exit 2 until B1 driver ships.
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
BUILD_DIR = REPO / "build" / "bench" / "md_lennard_jones"
ORACLE_TOML = REPO / "benchmarks" / "competitive" / "md_oracle.toml"
OUT_JSON = REPO / "benchmarks" / "results" / "md_lennard_jones" / "oracle_stub.json"
NATIVE_FLAGS = ["-O3", "-march=native", "-ffast-math"]


def native_reference_drift() -> str:
    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    native = BUILD_DIR / "md_oracle_ref"
    main_c = MD_DIR / "cpp" / "md_main.c"
    core_c = MD_DIR / "common" / "md_core.c"
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


def write_manifest(*, reference: str, mode: str, pending: list[str]) -> Path:
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    manifest = {
        "benchmark": "md_lennard_jones",
        "mode": mode,
        "reference_energy_drift": reference,
        "oracle_ids": load_oracle_ids(),
        "pending_real_drivers": pending,
        "updated": datetime.now(timezone.utc).isoformat(),
        "plan": "docs/benchmarks/competitive-engines-plan.md",
    }
    OUT_JSON.write_text(json.dumps(manifest, indent=2) + "\n")
    return OUT_JSON


def main() -> int:
    if not ORACLE_TOML.is_file():
        print(f"error: missing {ORACLE_TOML}", file=sys.stderr)
        return 1

    reference = native_reference_drift()
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
