#!/usr/bin/env python3
"""Run benchmark tiers and write results/latest.csv."""

from __future__ import annotations

import argparse
import csv
import platform
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
RESULTS = REPO / "benchmarks" / "results"


def git_sha() -> str:
    try:
        return (
            subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd=REPO)
            .decode()
            .strip()
        )
    except Exception:
        return "dev"


def write_sample_csv(path: Path) -> None:
    """Placeholder rows until Tier 1–2 binaries exist — drives plot harness."""
    rows = [
        # benchmark, lang, variant, threads, metric, value, unit, git_sha, cpu_model, flags
        ("three_body", "li", "release", 1, "wall_time", 0.42, "s", git_sha(), platform.processor(), "-O3"),
        ("three_body", "cpp", "release", 1, "wall_time", 0.38, "s", git_sha(), platform.processor(), "-O3 -march=native"),
        ("three_body", "rust", "release", 1, "wall_time", 0.41, "s", git_sha(), platform.processor(), "--release"),
        ("three_body", "julia", "release", 1, "wall_time", 0.55, "s", git_sha(), platform.processor(), "-O3"),
        ("md_lennard_jones", "li", "release", 1, "wall_time", 1.2, "s", git_sha(), platform.processor(), "-O3"),
        ("md_lennard_jones", "cpp", "release", 1, "wall_time", 1.0, "s", git_sha(), platform.processor(), "-O3"),
        ("md_lennard_jones", "li", "release", 8, "wall_time", 0.22, "s", git_sha(), platform.processor(), "-O3 --threads=8"),
        ("simd_dot", "li", "release", 1, "throughput", 4.8, "GFLOPS", git_sha(), platform.processor(), "simd"),
        ("simd_dot", "cpp", "release", 1, "throughput", 5.1, "GFLOPS", git_sha(), platform.processor(), "simd"),
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "benchmark",
                "lang",
                "variant",
                "threads",
                "metric",
                "value",
                "unit",
                "git_sha",
                "cpu_model",
                "flags",
            ]
        )
        w.writerows(rows)
    print(f"wrote sample {path} ({len(rows)} rows) — replace with real timings when codegen lands")


def run_tier0() -> int:
    script = REPO / "li-tests" / "run_all.sh"
    if not script.exists():
        print("li-tests harness missing", file=sys.stderr)
        return 1
    env = {**os.environ, "LIC": str(REPO / "build" / "compiler" / "lic" / "lic")}
    return subprocess.call([str(script)], cwd=REPO / "li-tests", env=env)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tier", type=int, default=0)
    parser.add_argument("--sample", action="store_true", help="write demo CSV for plots")
    parser.add_argument("--ci", action="store_true")
    args = parser.parse_args()

    if args.sample or not (RESULTS / "latest.csv").exists():
        write_sample_csv(RESULTS / "latest.csv")

    if args.tier == 0 and not args.sample:
        return run_tier0()
    if args.tier >= 1:
        print("tier 1+ benchmarks: run after Phase 3 codegen (see master plan)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
