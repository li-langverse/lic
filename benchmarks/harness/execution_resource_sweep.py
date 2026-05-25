#!/usr/bin/env python3
"""Execution-resource sweep: cores × threads-per-core vs li_native / cpp_omp / cpp_pthread."""

from __future__ import annotations

import argparse
import csv
import os
import platform
import statistics
import subprocess
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
REF_ROOT = REPO / "benchmarks" / "runtime_refs" / "reduce_parallel"
TIER1_SIMD = REPO / "benchmarks" / "tier1_micro" / "simd_dot"
BUILD = REPO / "build" / "bench" / "execution_resource"
DEFAULT_OUT = REPO / "benchmarks" / "results" / "execution_resource_sweep.csv"

SWEEP_HDR = [
    "benchmark",
    "implementation",
    "cores",
    "threads_per_core",
    "parallelism",
    "metric",
    "value",
    "unit",
    "git_sha",
    "cpu_model",
    "flags",
]

IMPLS = (
    ("li_native", REF_ROOT / "li_native", "common/reduce_parallel_core.c"),
    ("cpp_omp", REF_ROOT / "cpp_omp", "common/reduce_parallel_omp.c"),
    ("cpp_pthread", REF_ROOT / "cpp_pthread", "common/reduce_parallel_pthread.c"),
)

CORE_GRID = (1, 2, 4, "host")
TPC_GRID = (1, 2)


def git_sha() -> str:
    try:
        return (
            subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd=REPO)
            .decode()
            .strip()
        )
    except Exception:
        return "dev"


def cpu_model() -> str:
    return platform.processor() or platform.machine()


def host_cores() -> int:
    return os.cpu_count() or 1


def resolve_cores(spec: int | str) -> int:
    if spec == "host":
        return host_cores()
    return int(spec)


def peak_rss_mb(cmd: list[str], *, cwd: Path | None = None) -> float | None:
    if platform.system() == "Darwin" and Path("/usr/bin/time").is_file():
        proc = subprocess.run(
            ["/usr/bin/time", "-l", *cmd],
            cwd=cwd,
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
    proc = subprocess.run(
        ["/usr/bin/time", "-v", *cmd],
        cwd=cwd,
        capture_output=True,
        text=True,
    )
    for line in (proc.stderr or "").splitlines():
        if "Maximum resident set size" in line:
            parts = line.split()
            if len(parts) >= 2:
                try:
                    return round(int(parts[-2]) / 1024, 2)
                except ValueError:
                    pass
    return None


def time_median(cmd: list[str], *, cwd: Path | None = None, runs: int = 3) -> float:
    warmup = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if warmup.returncode != 0:
        raise RuntimeError(f"warmup failed: {' '.join(cmd)}\n{warmup.stderr or warmup.stdout}")
    samples: list[float] = []
    for _ in range(runs):
        start = time.perf_counter()
        proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
        elapsed = time.perf_counter() - start
        if proc.returncode != 0:
            raise RuntimeError(f"run failed: {' '.join(cmd)}\n{proc.stderr or proc.stdout}")
        samples.append(elapsed)
    return statistics.median(samples)


def omp_compile_flags(cc: str) -> list[str] | None:
    if os.environ.get("LI_BENCH_OMP_FLAGS"):
        return os.environ["LI_BENCH_OMP_FLAGS"].split()
    if platform.system() == "Darwin":
        try:
            prefix = (
                subprocess.check_output(["brew", "--prefix", "libomp"], text=True).strip()
            )
            return [
                "-Xpreprocessor",
                "-fopenmp",
                f"-I{prefix}/include",
                f"-L{prefix}/lib",
                "-lomp",
            ]
        except (subprocess.CalledProcessError, FileNotFoundError):
            return None
    probe = subprocess.run(
        [cc, "-fopenmp", "-x", "c", "-", "-o", os.devnull],
        input=b"int main(void){return 0;}\n",
        capture_output=True,
    )
    return ["-fopenmp"] if probe.returncode == 0 else None


def build_impl(name: str, main_dir: Path, core_rel: str, bin_path: Path) -> bool:
    cc = os.environ.get("CC", "clang")
    main_c = main_dir / "main.c"
    core_c = REF_ROOT / core_rel
    flags = ["-O3", "-march=native", "-ffast-math"]
    libs: list[str] = []
    if name == "cpp_omp":
        omp = omp_compile_flags(cc)
        if omp is None:
            return False
        flags.extend(omp)
    if name == "cpp_pthread":
        libs.append("-pthread")
    subprocess.check_call(
        [cc, *flags, str(main_c), str(core_c), "-lm", *libs, "-o", str(bin_path)],
        cwd=REPO,
    )
    return True


def sweep_reduce_parallel(*, runs: int, smoke: bool) -> list[dict[str, object]]:
    BUILD.mkdir(parents=True, exist_ok=True)
    bins: dict[str, Path] = {}
    for impl, main_dir, core_rel in IMPLS:
        out = BUILD / f"reduce_parallel_{impl}"
        if not build_impl(impl, main_dir, core_rel, out):
            print(f"warn: skip {impl} (OpenMP toolchain unavailable)", file=sys.stderr)
            continue
        bins[impl] = out

    if "li_native" not in bins:
        raise RuntimeError("li_native build failed")

    # checksum parity (tier-0 style invariant for this kernel)
    ref = subprocess.check_output([str(bins["li_native"]), "--verify"], text=True).strip()
    for impl in ("cpp_omp", "cpp_pthread"):
        if impl not in bins:
            continue
        got = subprocess.check_output([str(bins[impl]), "--verify"], text=True).strip()
        if got != ref:
            raise RuntimeError(f"checksum mismatch {impl}: {got} vs {ref}")

    sha = git_sha()
    cpu = cpu_model()
    rows: list[dict[str, object]] = []
    baseline_wall: float | None = None
    grid = [(1, 1)] if smoke else [
        (resolve_cores(c), tpc) for c in CORE_GRID for tpc in TPC_GRID
    ]

    for cores, tpc in grid:
        threads = cores * tpc
        for impl in (name for name, _, _ in IMPLS if name in bins):
            bin_path = bins[impl]
            env = os.environ.copy()
            env["LI_OMP_THREADS"] = str(threads)
            env["OMP_NUM_THREADS"] = str(threads)
            cmd = [str(bin_path), f"--threads={threads}"]
            wall = time_median(cmd, cwd=REPO, runs=1 if smoke else runs)
            rss = peak_rss_mb(cmd, cwd=REPO)
            if baseline_wall is None and cores == 1 and tpc == 1 and impl == "li_native":
                baseline_wall = wall
            speedup = (baseline_wall / wall) if baseline_wall and wall > 0 else 1.0
            denom = max(1, cores * tpc)
            efficiency = speedup / denom
            flags = f"cores={cores} tpc={tpc} threads={threads}"
            base = {
                "benchmark": "reduce_sum_parallel",
                "implementation": impl,
                "cores": cores,
                "threads_per_core": tpc,
                "parallelism": "openmp" if impl == "cpp_omp" else ("pthread" if impl == "cpp_pthread" else "serial_ref"),
                "git_sha": sha,
                "cpu_model": cpu,
                "flags": flags,
            }
            rows.append({**base, "metric": "wall_s", "value": round(wall, 4), "unit": "s"})
            if rss is not None:
                rows.append({**base, "metric": "peak_rss_mb", "value": rss, "unit": "MiB"})
            rows.append({**base, "metric": "speedup", "value": round(speedup, 4), "unit": "x"})
            rows.append(
                {**base, "metric": "efficiency", "value": round(efficiency, 4), "unit": "x_per_hw_thread"}
            )
            print(f"reduce_sum_parallel {impl} cores={cores} tpc={tpc} wall={wall:.4f}s eff={efficiency:.3f}")

    return rows


def sweep_simd_dot(*, runs: int) -> list[dict[str, object]]:
    """Single-thread SIMD dot — intrathread vector lanes only (not OS threads)."""
    BUILD.mkdir(parents=True, exist_ok=True)
    cc = os.environ.get("CC", "clang")
    native = BUILD / "simd_dot_native"
    subprocess.check_call(
        [
            cc,
            "-O3",
            "-march=native",
            "-ffast-math",
            str(TIER1_SIMD / "cpp" / "main.c"),
            str(TIER1_SIMD / "common" / "dot_core.c"),
            "-lm",
            "-o",
            str(native),
        ],
        cwd=REPO,
    )
    wall = time_median([str(native)], cwd=REPO, runs=runs)
    sha = git_sha()
    cpu = cpu_model()
    print(f"simd_dot li_native parallelism=simd_intrathread wall={wall:.4f}s")
    return [
        {
            "benchmark": "simd_dot",
            "implementation": "li_native",
            "cores": 1,
            "threads_per_core": 1,
            "parallelism": "simd_intrathread",
            "metric": "wall_s",
            "value": round(wall, 4),
            "unit": "s",
            "git_sha": sha,
            "cpu_model": cpu,
            "flags": "tier1_micro/simd_dot single-thread vector lanes",
        }
    ]


def write_csv(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=SWEEP_HDR)
        w.writeheader()
        for row in rows:
            w.writerow({k: row[k] for k in SWEEP_HDR})


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--runs", type=int, default=3)
    parser.add_argument("--smoke", action="store_true")
    args = parser.parse_args()

    rows = sweep_reduce_parallel(runs=args.runs, smoke=args.smoke)
    if not args.smoke:
        rows.extend(sweep_simd_dot(runs=args.runs))
    write_csv(args.out, rows)
    print(f"wrote {args.out} ({len(rows)} rows)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
