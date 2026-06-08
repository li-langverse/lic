#!/usr/bin/env python3
"""External QM oracle for qm_dft_scf_energy (algo 418) — Psi4/PySCF subprocess drivers.

Family template lineage: schrodinger_1d_barrier (WP4 catalog smoke). Tier-2 bench dirs
live in li-langverse/benchmarks post lic#632; this module is the lic-side oracle hook
for verify.py / bench-qm-dft-scf-energy.sh.

Usage:
  python3 benchmarks/harness/qm_external_oracle.py --external-oracle psi4
  python3 benchmarks/harness/qm_external_oracle.py --external-oracle pyscf
  python3 benchmarks/harness/qm_external_oracle.py --external-oracle skip
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
COMP = REPO / "benchmarks" / "competitive"
RESULTS = Path(
    os.environ.get(
        "QM_DFT_SCF_BENCHMARKS_RESULTS",
        os.environ.get("BENCHMARKS_RESULTS", str(REPO / "benchmarks" / "results")),
    )
)

DRIVERS = {
    "psi4": COMP / "psi4_sto3g_h2_energy.py",
    "pyscf": COMP / "pyscf_sto3g_h2_energy.py",
}

OUT_ENV = {
    "psi4": "PH_SCI_CHEM_PSI4_H2_OUT",
    "pyscf": "PH_SCI_CHEM_PYSCF_H2_OUT",
}

OUT_FILES = {
    "psi4": "ph-sci-chem-competitor-psi4-h2.json",
    "pyscf": "ph-sci-chem-competitor-pyscf-h2.json",
}


def run_driver(oracle: str) -> dict:
    driver = DRIVERS[oracle]
    if not driver.is_file():
        return {"oracle": oracle, "executed": False, "note": f"missing driver {driver}"}

    out_path = RESULTS / OUT_FILES[oracle]
    env = os.environ.copy()
    env[OUT_ENV[oracle]] = str(out_path)
    env["PYTHONPATH"] = str(COMP) + (
        f":{env['PYTHONPATH']}" if env.get("PYTHONPATH") else ""
    )
    RESULTS.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [sys.executable, str(driver)],
        cwd=REPO,
        env=env,
        capture_output=True,
        text=True,
    )
    if proc.returncode not in (0,):
        return {
            "oracle": oracle,
            "executed": False,
            "note": (proc.stderr or proc.stdout or "driver failed").strip()[:500],
        }
    if not out_path.is_file():
        return {"oracle": oracle, "executed": False, "note": f"missing {out_path}"}
    doc = json.loads(out_path.read_text(encoding="utf-8"))
    doc["oracle"] = oracle
    doc["driver"] = str(driver.relative_to(REPO))
    return doc


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="qm_dft_scf_energy external oracle (418)")
    parser.add_argument(
        "--external-oracle",
        choices=("psi4", "pyscf", "skip", "auto"),
        default=os.environ.get("QM_DFT_EXTERNAL_ORACLE", "auto"),
        help="Oracle engine (auto: psi4 then pyscf)",
    )
    parser.add_argument(
        "--manifest",
        default=str(RESULTS / "qm_dft_scf_energy-external-oracle.json"),
        help="Write combined oracle manifest JSON",
    )
    args = parser.parse_args(argv)

    manifest = {
        "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "catalog_row": "qm_dft_scf_energy",
        "algo_id": 418,
        "family_template": "schrodinger_1d_barrier",
        "external_oracle": args.external_oracle,
        "oracles": {},
    }

    if args.external_oracle == "skip":
        manifest["note"] = "external oracle skipped (CI default without chem-external-oracle profile)"
        Path(args.manifest).write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
        print(args.manifest)
        return 0

    targets = (
        ["psi4", "pyscf"]
        if args.external_oracle == "auto"
        else [args.external_oracle]
    )
    for name in targets:
        manifest["oracles"][name] = run_driver(name)

    executed = [k for k, v in manifest["oracles"].items() if v.get("executed")]
    manifest["primary_oracle"] = executed[0] if executed else None
    Path(args.manifest).write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(args.manifest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
