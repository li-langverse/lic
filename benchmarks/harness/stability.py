#!/usr/bin/env python3
"""Numerical stability stress tests for md_lennard_jones (NVE / harmonic / halving)."""

from __future__ import annotations

import argparse
import csv
import os
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
MD_DIR = REPO / "benchmarks" / "tier2_physics" / "md_lennard_jones"
BUILD_DIR = REPO / "build" / "bench" / "md_lennard_jones"
RESULTS = REPO / "benchmarks" / "results"
DEFAULT_OUT = RESULTS / "stability.csv"

STRICT_TESTS = {"harmonic_energy", "momentum_drift"}
ADVISORY_TESTS = {"nve_energy_msd", "timestep_halving_ratio"}

CSV_HEADER = [
    "test",
    "metric",
    "value",
    "threshold",
    "passed",
    "reference",
]


def build_stress_bin(path: Path) -> None:
    cc = os.environ.get("CC", "clang")
    subprocess.check_call(
        [
            cc,
            "-O2",
            "-march=native",
            str(MD_DIR / "cpp" / "md_stress_main.c"),
            str(MD_DIR / "common" / "md_stress.c"),
            "-o",
            str(path),
        ],
        cwd=REPO,
    )


def run_stress(bin_path: Path) -> list[dict[str, object]]:
    proc = subprocess.run([str(bin_path), "--all"], capture_output=True, text=True)
    if proc.stdout.strip():
        lines = [ln for ln in proc.stdout.strip().splitlines() if ln and not ln.startswith("name,")]
    else:
        raise RuntimeError(f"md_stress failed: {proc.stderr}")
    rows: list[dict[str, object]] = []
    refs = {
        "harmonic_energy": "Swope 1997: qlf=dt^2/2",
        "nve_energy_msd": "Allen-Tildesley: MSD(E/N)<3e-8 @ dt=0.004",
        "timestep_halving_ratio": "Allen-Tildesley: MSD scales dt^4, ratio~16",
        "momentum_drift": "NVE invariant: |P|/N < 1e-8",
    }
    for line in lines:
        name, value, threshold, passed = line.split(",")
        rows.append(
            {
                "test": name,
                "metric": name,
                "value": float(value),
                "threshold": float(threshold),
                "passed": bool(int(passed)),
                "reference": refs.get(name, ""),
            }
        )
    return rows


def write_csv(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=CSV_HEADER)
        w.writeheader()
        for row in rows:
            w.writerow({k: row[k] for k in CSV_HEADER})


def main() -> int:
    parser = argparse.ArgumentParser(description="MD Lennard-Jones stability stress suite")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--strict", action="store_true", help="exit 1 if any test fails")
    args = parser.parse_args()

    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    stress_bin = BUILD_DIR / "md_stress"
    build_stress_bin(stress_bin)
    rows = run_stress(stress_bin)
    write_csv(args.out, rows)

    ok = True
    for row in rows:
        status = "PASS" if row["passed"] else "FAIL"
        tier = "strict" if row["test"] in STRICT_TESTS else "advisory"
        print(
            f"{status} [{tier}] {row['test']}: {row['value']:.6e} "
            f"(threshold {row['threshold']:.6e}) — {row['reference']}"
        )
        if row["test"] in STRICT_TESTS:
            ok = ok and bool(row["passed"])

    print(f"wrote {args.out}")
    if args.strict and not ok:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
