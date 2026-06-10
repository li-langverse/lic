#!/usr/bin/env python3
"""External MD oracle stub for md_lennard_jones (LAMMPS/GROMACS column plan).

Default: emit stub manifest JSON; no domain binary required.
Set LI_MD_ORACLE_LAMMPS=1 or LI_MD_ORACLE_GROMACS=1 to reserve exit 2 until B1 driver ships.
"""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
ORACLE_TOML = REPO / "benchmarks" / "competitive" / "md_oracle.toml"
OUT_JSON = REPO / "benchmarks" / "results" / "md_external_oracle_stub.json"


def _stub_manifest(engine: str) -> dict:
    return {
        "engine": engine,
        "status": "stub",
        "benchmark": "md_lennard_jones",
        "metric": "energy_drift",
        "value": None,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "oracle_toml": str(ORACLE_TOML.relative_to(REPO)),
        "notes": "WP-PLAT-05 stub column — no external binary invoked",
    }


def main() -> int:
    engines = []
    if os.environ.get("LI_MD_ORACLE_LAMMPS") == "1":
        engines.append("lammps")
    if os.environ.get("LI_MD_ORACLE_GROMACS") == "1":
        engines.append("gromacs")
    if not engines:
        engines = ["lammps", "gromacs"]

    reserved = os.environ.get("LI_MD_ORACLE_LAMMPS") == "1" or os.environ.get("LI_MD_ORACLE_GROMACS") == "1"
    if reserved:
        print("md_external_oracle: real driver not yet implemented (B1)", file=sys.stderr)
        return 2

    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    payload = {"oracles": [_stub_manifest(e) for e in engines]}
    OUT_JSON.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"md_external_oracle: wrote {OUT_JSON}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
