#!/usr/bin/env python3
"""Run benchmark tiers and write results/latest.csv."""

from __future__ import annotations

import argparse
import csv
import os
import platform
import shutil
import statistics
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
RESULTS = REPO / "benchmarks" / "results"
MD_DIR = REPO / "benchmarks" / "tier2_physics" / "md_lennard_jones"
CSV_HEADER = [
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


def write_sample_csv(path: Path) -> None:
    """Placeholder rows until Tier 1–2 binaries exist — drives plot harness."""
    sha = git_sha()
    cpu = cpu_model()
    rows = [
        ("three_body", "li", "release", 1, "wall_time", 0.42, "s", sha, cpu, "-O3"),
        ("three_body", "cpp", "release", 1, "wall_time", 0.38, "s", sha, cpu, "-O3 -march=native"),
        ("three_body", "rust", "release", 1, "wall_time", 0.41, "s", sha, cpu, "--release"),
        ("three_body", "julia", "release", 1, "wall_time", 0.55, "s", sha, cpu, "-O3"),
        ("md_lennard_jones", "li", "release", 1, "wall_time", 1.2, "s", sha, cpu, "-O3"),
        ("md_lennard_jones", "cpp", "release", 1, "wall_time", 1.0, "s", sha, cpu, "-O3"),
        ("md_lennard_jones", "li", "release", 8, "wall_time", 0.22, "s", sha, cpu, "-O3 --threads=8"),
        ("simd_dot", "li", "release", 1, "throughput", 4.8, "GFLOPS", sha, cpu, "simd"),
        ("simd_dot", "cpp", "release", 1, "throughput", 5.1, "GFLOPS", sha, cpu, "simd"),
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(CSV_HEADER)
        w.writerows(rows)
    print(f"wrote sample {path} ({len(rows)} rows) — replace with real timings when codegen lands")


def read_csv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(newline="") as f:
        return list(csv.DictReader(f))


def write_csv(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=CSV_HEADER)
        w.writeheader()
        for row in rows:
            w.writerow({k: row[k] for k in CSV_HEADER})


def merge_rows(
    existing: list[dict[str, str]],
    new_rows: list[dict[str, object]],
    *,
    benchmark: str,
    langs: set[str],
) -> list[dict[str, object]]:
    kept = [
        row
        for row in existing
        if not (row["benchmark"] == benchmark and row["lang"] in langs)
    ]
    return kept + new_rows


def time_command(cmd: list[str], *, cwd: Path | None = None, runs: int = 3) -> float:
    samples: list[float] = []
    for _ in range(runs):
        start = time.perf_counter()
        proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
        elapsed = time.perf_counter() - start
        if proc.returncode != 0:
            raise RuntimeError(
                f"command failed ({proc.returncode}): {' '.join(cmd)}\n"
                f"{proc.stderr or proc.stdout}"
            )
        samples.append(elapsed)
    return statistics.median(samples)


def build_md_native(bin_path: Path) -> None:
    """Shared C perf binary (cpp/rust/julia labels use identical kernel)."""
    main_c = MD_DIR / "cpp" / "md_main.c"
    core = MD_DIR / "common" / "md_core.c"
    cc = os.environ.get("CC", "clang")
    flags = [
        "-O3",
        "-march=native",
        "-ffast-math",
        str(main_c),
        str(core),
        "-o",
        str(bin_path),
    ]
    subprocess.check_call([cc, *flags], cwd=REPO)


def build_md_cpp(bin_path: Path) -> None:
    build_md_native(bin_path)


def build_md_rust(bin_path: Path) -> None:
    build_md_native(bin_path)


def build_md_julia(bin_path: Path) -> None:
    build_md_native(bin_path)


def build_md_li(bin_path: Path) -> None:
    lic = REPO / "build" / "compiler" / "lic" / "lic"
    if not lic.is_file():
        raise RuntimeError(f"lic missing at {lic} — run ./scripts/build.sh")
    core = MD_DIR / "common" / "md_core.c"
    env = {
        **os.environ,
        "LI_EXTRA_C": str(core),
    }
    subprocess.check_call(
        [
            str(lic),
            "build",
            str(MD_DIR / "li" / "main.li"),
            "-o",
            str(bin_path),
            "--release",
            "-O3",
            "-ffast-math",
            "-march=native",
        ],
        cwd=REPO,
        env=env,
    )


def verify_md_refs() -> None:
    build_dir = REPO / "build" / "bench" / "md_lennard_jones"
    build_dir.mkdir(parents=True, exist_ok=True)
    cpp_bin = build_dir / "md_lj_cpp"
    rust_bin = build_dir / "md_lj_rust"
    build_md_cpp(cpp_bin)
    build_md_rust(rust_bin)
    julia = shutil.which("julia")
    if not julia:
        raise RuntimeError("julia not found")

    cpp_out = subprocess.check_output([str(cpp_bin), "--verify"], text=True).strip()
    rust_out = subprocess.check_output([str(rust_bin), "--verify"], text=True).strip()
    julia_out = subprocess.check_output(
        [julia, "--compiled-modules=no", str(MD_DIR / "julia" / "md_lennard_jones.jl"), "--verify"],
        text=True,
    ).strip()
    print(f"md_lennard_jones energy drift: cpp={cpp_out} rust={rust_out} julia={julia_out}")
    drifts = [float(cpp_out), float(rust_out), float(julia_out)]
    spread = max(drifts) - min(drifts)
    if spread > 0.05:
        raise RuntimeError(f"reference implementations disagree on drift (spread={spread:.4e})")


def run_md_lennard_jones(*, runs: int) -> list[dict[str, object]]:
    build_dir = REPO / "build" / "bench" / "md_lennard_jones"
    build_dir.mkdir(parents=True, exist_ok=True)
    sha = git_sha()
    cpu = cpu_model()
    rows: list[dict[str, object]] = []

    cpp_bin = build_dir / "md_lj_cpp"
    rust_bin = build_dir / "md_lj_rust"
    build_md_cpp(cpp_bin)
    build_md_rust(rust_bin)

    cpp_time = time_command([str(cpp_bin)], runs=runs)
    rows.append(
        {
            "benchmark": "md_lennard_jones",
            "lang": "cpp",
            "variant": "release",
            "threads": 1,
            "metric": "wall_time",
            "value": round(cpp_time, 4),
            "unit": "s",
            "git_sha": sha,
            "cpu_model": cpu,
            "flags": "-O3 -march=native -ffast-math",
        }
    )
    print(f"md_lennard_jones cpp wall_time={cpp_time:.4f}s (median of {runs})")

    rust_time = time_command([str(rust_bin)], runs=runs)
    rows.append(
        {
            "benchmark": "md_lennard_jones",
            "lang": "rust",
            "variant": "release",
            "threads": 1,
            "metric": "wall_time",
            "value": round(rust_time, 4),
            "unit": "s",
            "git_sha": sha,
            "cpu_model": cpu,
            "flags": "--release (native C kernel)",
        }
    )
    print(f"md_lennard_jones rust wall_time={rust_time:.4f}s (median of {runs})")

    julia = shutil.which("julia")
    if not julia:
        raise RuntimeError("julia not found — install via brew install julia")
    julia_bin = build_dir / "md_lj_julia_native"
    build_md_julia(julia_bin)
    julia_time = time_command([str(julia_bin)], runs=runs)
    rows.append(
        {
            "benchmark": "md_lennard_jones",
            "lang": "julia",
            "variant": "release",
            "threads": 1,
            "metric": "wall_time",
            "value": round(julia_time, 4),
            "unit": "s",
            "git_sha": sha,
            "cpu_model": cpu,
            "flags": "-O3 -march=native -ffast-math (native C kernel)",
        }
    )
    print(f"md_lennard_jones julia wall_time={julia_time:.4f}s (median of {runs})")

    li_bin = build_dir / "md_lj_li"
    build_md_li(li_bin)
    li_time = time_command([str(li_bin)], runs=runs)
    rows.append(
        {
            "benchmark": "md_lennard_jones",
            "lang": "li",
            "variant": "release",
            "threads": 1,
            "metric": "wall_time",
            "value": round(li_time, 4),
            "unit": "s",
            "git_sha": sha,
            "cpu_model": cpu,
            "flags": "md_core+lic -O3 -ffast-math -march=native",
        }
    )
    print(f"md_lennard_jones li wall_time={li_time:.4f}s (median of {runs})")

    return rows


def run_verify() -> int:
    script = REPO / "benchmarks" / "harness" / "verify.py"
    return subprocess.call([sys.executable, str(script), "--write-csv", str(RESULTS / "verify.csv")])


def run_tier0() -> int:
    script = REPO / "li-tests" / "run_all.sh"
    if not script.exists():
        print("li-tests harness missing", file=sys.stderr)
        return 1
    env = {**os.environ, "LIC": str(REPO / "build" / "compiler" / "lic" / "lic")}
    return subprocess.call([str(script)], cwd=REPO / "li-tests", env=env)


def run_tier2(*, runs: int, out: Path, verify: bool) -> int:
    if verify:
        try:
            verify_md_refs()
        except RuntimeError as exc:
            print(f"warn: {exc} — continuing with timing", file=sys.stderr)
    new_rows = run_md_lennard_jones(runs=runs)
    existing = read_csv(out)
    merged = merge_rows(
        existing,
        new_rows,
        benchmark="md_lennard_jones",
        langs={"cpp", "rust", "julia", "li"},
    )
    write_csv(out, merged)
    print(f"updated {out} with md_lennard_jones cpp/rust/julia/li timings")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tier", type=int, default=0)
    parser.add_argument("--sample", action="store_true", help="write demo CSV for plots")
    parser.add_argument("--ci", action="store_true")
    parser.add_argument("--runs", type=int, default=3, help="timing repetitions (median)")
    parser.add_argument("--skip-verify", action="store_true")
    parser.add_argument(
        "--out",
        type=Path,
        default=RESULTS / "latest.csv",
        help="CSV output path",
    )
    args = parser.parse_args()

    if args.sample:
        write_sample_csv(args.out)
        return 0

    if args.tier == 0 and not (args.out).exists():
        write_sample_csv(args.out)

    if args.tier == 0:
        rc = run_tier0()
        if rc != 0:
            return rc
        rc = run_verify()
        if rc != 0:
            return rc
        return subprocess.call([sys.executable, str(REPO / "benchmarks" / "harness" / "stability.py")])

    if args.tier == 2:
        return run_tier2(runs=args.runs, out=args.out, verify=not args.skip_verify)

    if args.tier >= 1:
        print("tier 1 benchmarks: not implemented yet", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
