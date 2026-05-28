#!/usr/bin/env python3
"""Shared wall-clock timing: mean, sample stddev, adaptive run counts."""

from __future__ import annotations

import math
import os
import statistics
from collections.abc import Callable
import subprocess
import sys
import time
from dataclasses import dataclass


@dataclass(frozen=True)
class TimingStats:
    """Aggregate of repeated wall-clock samples (value column = mean)."""

    mean: float
    stddev: float
    sample_runs: int


def bench_env_flag(name: str, default: str = "1") -> bool:
    return os.environ.get(name, default).strip().lower() not in ("0", "false", "no", "off")


def min_runs_for_duration(mean_sec: float) -> int:
    """At least 6 runs; sub-second kernels need at least 20."""
    floor = int(os.environ.get("BENCH_MIN_RUNS", "6"))
    subsec = int(os.environ.get("BENCH_SUBSEC_MIN_RUNS", "20"))
    if mean_sec > 0 and mean_sec < 1.0:
        return max(floor, subsec)
    return floor


def resolve_timing_runs(base_runs: int, mean_sec: float) -> int:
    """Scale repetitions for short kernels (≥min runs, ~BENCH_TARGET_SAMPLE_SEC total)."""
    if not bench_env_flag("BENCH_ADAPTIVE_RUNS", "1"):
        return max(base_runs, min_runs_for_duration(mean_sec))
    min_runs = min_runs_for_duration(mean_sec)
    max_runs = int(os.environ.get("BENCH_MAX_RUNS", "200"))
    target = float(os.environ.get("BENCH_TARGET_SAMPLE_SEC", "1.0"))
    runs = max(base_runs, min_runs)
    if mean_sec > 0:
        needed = math.ceil(target / mean_sec)
        runs = max(runs, min(needed, max_runs))
    return runs


def stats_from_samples(samples: list[float]) -> TimingStats:
    n = len(samples)
    if n == 0:
        return TimingStats(mean=0.0, stddev=0.0, sample_runs=0)
    mean = statistics.mean(samples)
    stddev = statistics.stdev(samples) if n > 1 else 0.0
    return TimingStats(mean=mean, stddev=stddev, sample_runs=n)


def run_timed_once(cmd: list[str], *, cwd: str | os.PathLike[str] | None) -> float:
    start = time.perf_counter()
    proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    elapsed = time.perf_counter() - start
    if proc.returncode != 0:
        raise RuntimeError(
            f"command failed ({proc.returncode}): {' '.join(cmd)}\n"
            f"{proc.stderr or proc.stdout}"
        )
    return elapsed


def default_bench_runs() -> int:
    return int(os.environ.get("BENCH_RUNS", "6"))


def measure_repeated(measure: Callable[[], float], *, runs: int | None = None) -> TimingStats:
    """Repeated scalar samples (e.g. wrk RPS, TTFB ms); mean ± stddev with adaptive count."""
    base = runs if runs is not None else default_bench_runs()
    probe_n = min(3, base)
    samples: list[float] = []
    for _ in range(probe_n):
        samples.append(float(measure()))
    probe_mean = statistics.mean(samples)
    total = resolve_timing_runs(base, probe_mean)
    extra = max(0, total - probe_n)
    if extra:
        samples.extend(float(measure()) for _ in range(extra))
    return stats_from_samples(samples)


def time_command(
    cmd: list[str],
    *,
    cwd: str | os.PathLike[str] | None = None,
    runs: int = 6,
) -> TimingStats:
    """Warmup + adaptive repetitions; returns mean and sample stddev."""
    if runs <= 1:
        warmup = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
        if warmup.returncode != 0:
            raise RuntimeError(
                f"warmup failed ({warmup.returncode}): {' '.join(cmd)}\n"
                f"{warmup.stderr or warmup.stdout}"
            )
        return stats_from_samples([run_timed_once(cmd, cwd=cwd)])

    warmup = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if warmup.returncode != 0:
        raise RuntimeError(
            f"warmup failed ({warmup.returncode}): {' '.join(cmd)}\n"
            f"{warmup.stderr or warmup.stdout}"
        )

    probe_n = min(3, runs)
    samples = [run_timed_once(cmd, cwd=cwd) for _ in range(probe_n)]
    probe_mean = statistics.mean(samples)
    total_runs = resolve_timing_runs(runs, probe_mean)
    extra = max(0, total_runs - probe_n)
    if extra:
        samples.extend(run_timed_once(cmd, cwd=cwd) for _ in range(extra))

    stats = stats_from_samples(samples)
    if bench_env_flag("BENCH_TIMING_VERBOSE", "0"):
        print(
            f"timing: runs={stats.sample_runs} mean={stats.mean:.6f}s "
            f"stddev={stats.stddev:.6f}s cmd={' '.join(cmd)}",
            file=sys.stderr,
        )
    return stats
