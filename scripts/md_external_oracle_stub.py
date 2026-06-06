#!/usr/bin/env python3
"""Lic-side MD external oracle stub — validates md_oracle.toml and writes manifest.

No LAMMPS/GROMACS or benchmarks tier-2 checkout required on default CI.
When BENCHMARKS_ROOT is set, delegates to benchmarks/harness/md_external_oracle.py.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ORACLE_TOML = ROOT / "benchmarks" / "competitive" / "md_oracle.toml"
OUT_JSON = ROOT / "benchmarks" / "results" / "md_lennard_jones" / "oracle_stub.json"
README = ROOT / "benchmarks" / "competitive" / "README-md-oracle.md"


def load_oracles() -> list[dict]:
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib  # type: ignore

    data = tomllib.loads(ORACLE_TOML.read_text(encoding="utf-8"))
    rows = data.get("oracle") or []
    return [r for r in rows if isinstance(r, dict)]


def validate_registry() -> None:
    if not ORACLE_TOML.is_file():
        raise FileNotFoundError(f"missing {ORACLE_TOML}")
    rows = load_oracles()
    if len(rows) < 2:
        raise ValueError("md_oracle.toml: expected at least 2 [[oracle]] rows")
    required = (
        "id",
        "csv_lang",
        "oracle",
        "driver",
        "status",
        "li_smoke",
        "compare_metric",
    )
    for row in rows:
        for key in required:
            if key not in row:
                raise ValueError(f"{row.get('id', '?')}: missing {key}")
        if row["oracle"] != "external_binary":
            raise ValueError(f"{row['id']}: oracle must be external_binary")
    if not README.is_file():
        raise FileNotFoundError(f"missing {README}")
    text = README.read_text(encoding="utf-8")
    if "md_external_oracle.py" not in text:
        raise ValueError(f"{README}: must cite md_external_oracle.py driver path")


def try_benchmarks_driver() -> dict | None:
    bench_root = os.environ.get("BENCHMARKS_ROOT", "").strip()
    if not bench_root:
        return None
    driver = Path(bench_root) / "harness" / "md_external_oracle.py"
    if not driver.is_file():
        return None
    proc = subprocess.run(
        [sys.executable, str(driver)],
        cwd=bench_root,
        capture_output=True,
        text=True,
    )
    return {
        "delegated": True,
        "driver": str(driver),
        "exit_code": proc.returncode,
        "stdout": (proc.stdout or "")[-500:],
        "stderr": (proc.stderr or "")[-500:],
    }


def write_manifest(*, mode: str, delegated: dict | None) -> Path:
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    rows = load_oracles()
    manifest = {
        "schema": "li_md_oracle_stub_v1",
        "benchmark": "md_lennard_jones",
        "catalog_id": "md_oracle_external",
        "mode": mode,
        "oracle_ids": [str(r["id"]) for r in rows],
        "csv_langs": [str(r["csv_lang"]) for r in rows],
        "li_smoke": str(rows[0].get("li_smoke", "")),
        "driver": "benchmarks/harness/md_external_oracle.py",
        "gate_script": "scripts/md-oracle-competitive-gates.sh",
        "plan": "docs/benchmarks/competitive-engines-plan.md",
        "delegated_benchmarks": delegated,
        "updated": datetime.now(timezone.utc).isoformat(),
    }
    OUT_JSON.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return OUT_JSON


def main() -> int:
    try:
        validate_registry()
    except (OSError, ValueError) as exc:
        print(f"md_external_oracle_stub: {exc}", file=sys.stderr)
        return 1

    delegated = try_benchmarks_driver()
    if delegated and delegated.get("exit_code") == 0:
        mode = "benchmarks_driver_ok"
    elif delegated and delegated.get("exit_code") == 2:
        mode = "benchmarks_driver_blocked"
    else:
        mode = "lic_stub_ok"

    out = write_manifest(mode=mode, delegated=delegated)
    print(f"md_external_oracle_stub: ok mode={mode}")
    print(f"wrote {out}")
    if delegated and delegated.get("exit_code") not in (0, None):
        if delegated.get("exit_code") == 2:
            print("note: benchmarks driver reserved for B1/B2 (exit 2)", file=sys.stderr)
            return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
