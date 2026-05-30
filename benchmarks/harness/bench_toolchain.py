#!/usr/bin/env python3
"""Toolchain micro-bench + execution-resource flags on lic check."""

from __future__ import annotations

import argparse
import csv
import os
import platform
import subprocess
import sys
import time
from pathlib import Path

_HARNESS = Path(__file__).resolve().parent
if str(_HARNESS) not in sys.path:
    sys.path.insert(0, str(_HARNESS))
from timing_stats import TimingStats, default_bench_runs, time_command

REPO = Path(__file__).resolve().parents[2]
MICRO = REPO / "benchmarks" / "toolchain" / "micro"
LIC = REPO / "build" / "compiler" / "lic" / "lic"
OUT = REPO / "benchmarks" / "results" / "toolchain_latest.csv"
HDR = [
    "tool",
    "command",
    "corpus",
    "jobs",
    "cores",
    "threads_per_core",
    "wall_s",
    "wall_stddev",
    "sample_runs",
    "peak_rss_mb",
    "exit_code",
    "diagnostics_count",
    "cache_hit",
    "git_sha",
    "cpu_model",
    "flags",
]

RESOURCE_CASES = (
    ("baseline", []),
    ("cores_cap", ["--cores=999999"]),
    ("threads_neg", ["--threads=-1"]),
    ("jobs_mem_cap", ["--jobs=999999", "--max-memory=1", "--job-memory-mb=4096"]),
)


def timed(cmd: list[str], *, runs: int | None = None) -> tuple[TimingStats, int]:
    base = runs if runs is not None else default_bench_runs()
    code = 0

    def once() -> float:
        nonlocal code
        start = time.perf_counter()
        proc = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True)
        code = proc.returncode
        return time.perf_counter() - start

    if base <= 1:
        return TimingStats(mean=once(), stddev=0.0, sample_runs=1), code
    return time_command(cmd, cwd=REPO, runs=base), code


def peak_rss_mb(cmd: list[str]) -> float | None:
    if platform.system() == "Darwin" and Path("/usr/bin/time").is_file():
        proc = subprocess.run(
            ["/usr/bin/time", "-l", *cmd],
            cwd=REPO,
            capture_output=True,
            text=True,
        )
        for line in (proc.stderr or "").splitlines():
            if "maximum resident set size" in line:
                parts = line.split()
                if parts:
                    try:
                        return round(int(parts[0]) / (1024 * 1024), 2)
                    except ValueError:
                        pass
    return None


def git_sha() -> str:
    try:
        return (
            subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd=REPO)
            .decode()
            .strip()
        )
    except Exception:
        return "dev"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--smoke", action="store_true")
    parser.add_argument("--runs", type=int, default=default_bench_runs())
    parser.add_argument("--resource-sweep", action="store_true")
    args = parser.parse_args()

    if not LIC.is_file():
        raise SystemExit(f"lic missing at {LIC} — run ./scripts/build.sh")

    rows: list[dict[str, object]] = []
    cpu = platform.processor() or platform.machine()
    sha = git_sha()

    corpus = sorted(MICRO.glob("*.li"))
    if args.smoke and corpus:
        corpus = corpus[:1]

    for p in corpus:
        cmd = [str(LIC), "check", str(p), "--format=json"]
        timing, code = timed(cmd, runs=args.runs)
        rows.append(
            {k: "" for k in HDR}
            | {
                "tool": "lic",
                "command": " ".join(cmd),
                "corpus": "micro/" + p.name,
                "jobs": 1,
                "cores": 1,
                "threads_per_core": 1,
                "wall_s": round(timing.mean, 4),
                "wall_stddev": round(timing.stddev, 6),
                "sample_runs": timing.sample_runs,
                "exit_code": code,
                "diagnostics_count": 0,
                "cache_hit": "false",
                "git_sha": sha,
                "cpu_model": cpu,
                "flags": "--smoke" if args.smoke else "",
            }
        )
        print(p.name, timing.mean, code)

    if args.resource_sweep or args.smoke:
        probe = corpus[0] if corpus else MICRO / "fib.li"
        cases = [RESOURCE_CASES[0]] if args.smoke else RESOURCE_CASES
        for label, extra in cases:
            cmd = [str(LIC), "check", str(probe), *extra]
            timing, code = timed(cmd, runs=args.runs)
            rss = peak_rss_mb(cmd)
            rows.append(
                {k: "" for k in HDR}
                | {
                    "tool": "lic",
                    "command": " ".join(cmd),
                    "corpus": f"resource/{label}",
                    "jobs": 999999 if "jobs=999999" in " ".join(extra) else 1,
                    "cores": 999999 if "cores=999999" in " ".join(extra) else 1,
                    "threads_per_core": 1,
                    "wall_s": round(timing.mean, 4),
                    "wall_stddev": round(timing.stddev, 6),
                    "sample_runs": timing.sample_runs,
                    "peak_rss_mb": rss if rss is not None else "",
                    "exit_code": code,
                    "diagnostics_count": 0,
                    "cache_hit": "false",
                    "git_sha": sha,
                    "cpu_model": cpu,
                    "flags": label,
                }
            )
            print(f"resource {label}", timing.mean, code)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=HDR)
        writer.writeheader()
        writer.writerows(rows)
    print("wrote", OUT, len(rows))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
