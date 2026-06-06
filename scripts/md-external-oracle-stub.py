#!/usr/bin/env python3
"""External MD oracle stub for md_lennard_jones (LAMMPS/GROMACS column plan).

B0: record Li internal oracle path + registry ids; no domain binary required.
Set LI_MD_ORACLE_LAMMPS=1 with lammps on PATH to reserve exit 2 until B1 driver ships.
"""

from __future__ import annotations

import json
import os
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
ORACLE_TOML = REPO / "benchmarks" / "competitive" / "md_oracle.toml"
OUT_JSON = REPO / "benchmarks" / "results" / "md_lennard_jones" / "oracle_stub.json"
PLAN = "docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md"


def load_oracle_ids() -> list[str]:
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib  # type: ignore

    data = tomllib.loads(ORACLE_TOML.read_text(encoding="utf-8"))
    rows = data.get("oracle") or []
    return [str(row["id"]) for row in rows if isinstance(row, dict) and "id" in row]


def load_harness_meta() -> dict:
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib  # type: ignore

    data = tomllib.loads(ORACLE_TOML.read_text(encoding="utf-8"))
    harness = data.get("harness") or {}
    return harness if isinstance(harness, dict) else {}


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


def write_manifest(*, mode: str, pending: list[str]) -> Path:
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    harness = load_harness_meta()
    manifest = {
        "schema": "li_md_oracle_stub_v1",
        "benchmark": "md_lennard_jones",
        "mode": mode,
        "algo_registry_id": harness.get("algo_registry_id", 104),
        "algo_registry_name": harness.get("algo_registry_name", "md_oracle_external"),
        "li_oracle_fn": harness.get("li_oracle_fn", "sim_scientific_oracle_checksum_md"),
        "li_oracle_api": harness.get("li_oracle_api", ""),
        "li_tests_smoke": harness.get("li_tests_smoke", ""),
        "oracle_ids": load_oracle_ids(),
        "pending_real_drivers": pending,
        "updated": datetime.now(timezone.utc).isoformat(),
        "plan": PLAN,
        "registry": str(ORACLE_TOML.relative_to(REPO)),
    }
    OUT_JSON.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return OUT_JSON


def main() -> int:
    if not ORACLE_TOML.is_file():
        print(f"error: missing {ORACLE_TOML}", file=sys.stderr)
        return 1

    pending = check_real_driver_requested()
    if pending:
        write_manifest(mode="stub_blocked", pending=pending)
        names = ", ".join(pending)
        print(
            f"md external oracle: real driver requested for {names} but not implemented (B1/B2)",
            file=sys.stderr,
        )
        return 2

    out = write_manifest(mode="stub_ok", pending=[])
    print("md external oracle stub ok (Li internal oracle path cited)")
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
