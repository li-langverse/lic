#!/usr/bin/env python3
"""PETSc + hypre implicit heat oracle stub — skip gracefully when PETSC_DIR unset."""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "benchmarks" / "competitive"))
from pde_implicit_competitive_common import li_implicit_jacobi_oracle_checksum, workload_meta

OUT = Path(
    os.environ.get(
        "PH_SCI_PDE_PETSC_OUT",
        ROOT / "benchmarks/results/ph-sci-pde-competitor-petsc.json",
    )
)
PETSC_PIN = "3.25.0"
HYPRE_PIN = "2.32.0"


def main() -> int:
    petsc_dir = os.environ.get("PETSC_DIR", "")
    report = {
        "id": "petsc_hypre",
        "engine": "PETSc+hypre",
        "petsc_version_pin": PETSC_PIN,
        "hypre_version_pin": HYPRE_PIN,
        "preconditioner": "BoomerAMG",
        "workload": workload_meta(),
        "executed": False,
        "checksum": None,
        "checksum_source": "none",
        "note": "",
    }
    if not petsc_dir:
        report["note"] = (
            "PETSC_DIR unset — optional oracle skipped (install PETSc "
            f"{PETSC_PIN} + hypre {HYPRE_PIN}; see README-pde-implicit.md)"
        )
    else:
        # B1: real KSPSolve driver; until then document honest stub checksum.
        report["note"] = (
            f"PETSC_DIR={petsc_dir} — full KSP+hypre driver deferred to B1; "
            "using Li Jacobi mirror checksum for schema smoke only"
        )
        report["checksum"] = round(li_implicit_jacobi_oracle_checksum(), 12)
        report["checksum_source"] = "li_mirror_stub"
        report["executed"] = False

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
