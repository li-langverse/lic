#!/usr/bin/env python3
"""External MD oracle stub for md_lennard_jones (LAMMPS/GROMACS column plan).

Default: record Li native oracle reference; no domain binary required.
Set LI_MD_ORACLE_LAMMPS=1 with lammps on PATH to reserve exit 2 until B1 driver ships.

Gate: li-tests/tooling/md_external_oracle_stub.sh
Registry: benchmarks/competitive/md_oracle.toml
Plan: docs/benchmarks/competitive-engines-plan.md
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
ORACLE_TOML = REPO / "benchmarks" / "competitive" / "md_oracle.toml"
OUT_JSON = REPO / "benchmarks" / "results" / "md_lennard_jones" / "oracle_stub.json"
NATIVE_FLAGS = ["-O3", "-march=native", "-ffast-math"]

# Li in-repo oracle band (8-step 4-particle LJ chain) — see scientific_oracle_bench.li
LI_ORACLE_MIN = 0.0
LI_ORACLE_MAX = 1.0e-3


def load_oracle_ids() -> list[str]:
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib  # type: ignore

    data = tomllib.loads(ORACLE_TOML.read_text())
    rows = data.get("oracle") or []
    return [str(row["id"]) for row in rows if isinstance(row, dict) and "id" in row]


def benchmarks_root() -> Path | None:
    raw = os.environ.get("BENCHMARKS_ROOT", "")
    if raw:
        p = Path(raw)
        if p.is_dir():
            return p
    cache = REPO / ".cache" / "li-benchmarks"
    if (cache / "harness" / "bench.py").is_file():
        return cache
    return None


def tier2_md_dir(broot: Path) -> Path | None:
    for rel in (
        "benchmarks/workloads/tier2_physics/md_lennard_jones",
        "tier2_physics/md_lennard_jones",
    ):
        candidate = broot / rel
        if (candidate / "common" / "md_core.c").is_file():
            return candidate
    return None


def native_reference_drift(md_dir: Path) -> str:
    build_dir = REPO / "build" / "bench" / "md_lennard_jones"
    build_dir.mkdir(parents=True, exist_ok=True)
    native = build_dir / "md_oracle_ref"
    main_c = md_dir / "cpp" / "md_main.c"
    core_c = md_dir / "common" / "md_core.c"
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


def li_oracle_reference() -> str:
    return "li_sim_scientific_oracle_checksum_md"


def resolve_reference() -> tuple[str, str]:
    broot = benchmarks_root()
    if broot:
        md_dir = tier2_md_dir(broot)
        if md_dir:
            try:
                return native_reference_drift(md_dir), "md_core_native"
            except (RuntimeError, subprocess.CalledProcessError, FileNotFoundError):
                pass
    return li_oracle_reference(), "li_sim_scientific"


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


def write_manifest(*, reference: str, reference_kind: str, mode: str, pending: list[str]) -> Path:
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    manifest = {
        "benchmark": "md_lennard_jones",
        "mode": mode,
        "reference_energy_drift": reference,
        "reference_kind": reference_kind,
        "li_oracle_band": {"min_exclusive": LI_ORACLE_MIN, "max_exclusive": LI_ORACLE_MAX},
        "oracle_ids": load_oracle_ids(),
        "pending_real_drivers": pending,
        "oracle_registry": "benchmarks/competitive/md_oracle.toml",
        "gate_script": "scripts/md-external-oracle-stub.py",
        "li_tests_gate": "li-tests/tooling/md_external_oracle_stub.sh",
        "updated": datetime.now(timezone.utc).isoformat(),
        "plan": "docs/benchmarks/competitive-engines-plan.md",
    }
    OUT_JSON.write_text(json.dumps(manifest, indent=2) + "\n")
    return OUT_JSON


def main() -> int:
    if not ORACLE_TOML.is_file():
        print(f"error: missing {ORACLE_TOML}", file=sys.stderr)
        return 1

    reference, ref_kind = resolve_reference()
    pending = check_real_driver_requested()
    if pending:
        write_manifest(
            reference=reference,
            reference_kind=ref_kind,
            mode="stub_blocked",
            pending=pending,
        )
        names = ", ".join(pending)
        print(
            f"md external oracle: real driver requested for {names} but not implemented (B1/B2)",
            file=sys.stderr,
        )
        return 2

    out = write_manifest(
        reference=reference,
        reference_kind=ref_kind,
        mode="stub_ok",
        pending=[],
    )
    print(f"md external oracle stub ok: reference={reference} ({ref_kind})")
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
