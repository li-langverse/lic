#!/usr/bin/env python3
"""External PDE oracle stub for pde_heat_implicit_jacobi (PETSc+hypre column plan).

Default: write stub li_sim_summary_v1 manifest; no PETSc/hypre binary required.
Set PETSC_DIR with mpiexec on PATH to reserve exit 2 until B1 SNES/KSP driver ships.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

REPO = Path(__file__).resolve().parents[2]
ORACLE_TOML = REPO / "benchmarks" / "competitive" / "pde_oracle.toml"
OUT_DIR = REPO / "benchmarks" / "results" / "pde_heat_implicit_jacobi"
STUB_MANIFEST = OUT_DIR / "oracle_stub.json"

DEFAULT_NX = 64
DEFAULT_STEPS = 12_000
DEFAULT_JACOBI = 6


def load_oracle_ids() -> list[str]:
    if not ORACLE_TOML.is_file():
        return ["petsc_hypre_heat_implicit"]
    data = tomllib.loads(ORACLE_TOML.read_text())
    return [o["id"] for o in data.get("oracle", []) if o.get("status") != "deferred"]


def write_summary(engine: str, *, stub: bool, grid: int) -> Path:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    oracle_ids = load_oracle_ids()
    mode = "stub_ok" if stub else "petsc_reserved"

    summary = {
        "schema": "li_sim_summary_v1",
        "benchmark": "pde_heat_implicit_jacobi",
        "vertical_id": "pde_heat_2d",
        "workload_class": "v0_micro",
        "lang": engine,
        "variant": "external_binary",
        "ok": stub,
        "metrics": {
            "checksum": None,
            "nx": grid,
            "ny": grid,
            "steps": DEFAULT_STEPS,
            "jacobi_iters": DEFAULT_JACOBI,
            "mode": mode,
        },
        "invariants": {"oracle_stub_ok": stub},
        "artifacts": {
            "driver": "benchmarks/harness/pde_external_oracle.py",
            "pins": "benchmarks/competitive/pde_oracle.toml",
        },
        "updated": now,
    }

    out = OUT_DIR / f"{engine}.summary.min.json"
    out.write_text(json.dumps(summary, separators=(",", ":")) + "\n")

    stub_doc = {
        "mode": mode,
        "engine": engine,
        "oracle_ids": oracle_ids,
        "grid": grid,
        "petsc_dir_set": bool(os.environ.get("PETSC_DIR")),
        "updated": now,
    }
    STUB_MANIFEST.write_text(json.dumps(stub_doc, indent=2) + "\n")
    return out


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--engine", default="petsc_hypre", choices=("petsc_hypre", "skip"))
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--grid", type=int, default=DEFAULT_NX)
    args = p.parse_args()

    if args.engine == "skip":
        print("pde_external_oracle: skipped")
        return 0

    petsc_ready = bool(os.environ.get("PETSC_DIR")) and shutil.which("mpiexec") is not None
    if args.dry_run or not petsc_ready:
        path = write_summary(args.engine, stub=True, grid=args.grid)
        print(f"pde_external_oracle: stub_ok -> {path}")
        return 0

    write_summary(args.engine, stub=False, grid=args.grid)
    print(
        "pde_external_oracle: PETSC_DIR set; real SNES/KSP driver reserved (exit 2)",
        file=sys.stderr,
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())
