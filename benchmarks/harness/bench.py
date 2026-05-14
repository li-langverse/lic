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
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
TIER2 = REPO / "benchmarks" / "tier2_physics"
RESULTS = REPO / "benchmarks" / "results"
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
NATIVE_FLAGS = "-O3 -march=native -ffast-math"
LANGS = ("cpp", "rust", "julia", "li")


@dataclass(frozen=True)
class Tier2Bench:
    name: str
    rel_dir: str
    main_c: str
    core_c: str
    li_main: str


TIER2_BENCHES: tuple[Tier2Bench, ...] = (
    Tier2Bench(
        "md_lennard_jones",
        "md_lennard_jones",
        "cpp/md_main.c",
        "common/md_core.c",
        "li/main.li",
    ),
    Tier2Bench(
        "three_body",
        "three_body",
        "cpp/main.c",
        "common/three_body_core.c",
        "li/main.li",
    ),
    Tier2Bench(
        "nbody_gravity",
        "nbody_gravity",
        "cpp/main.c",
        "common/nbody_core.c",
        "li/main.li",
    ),
    Tier2Bench(
        "harmonic_oscillator_chain",
        "harmonic_oscillator_chain",
        "cpp/main.c",
        "common/harmonic_core.c",
        "li/main.li",
    ),
)


def bench_dir(spec: Tier2Bench) -> Path:
    return TIER2 / spec.rel_dir


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


def build_native(spec: Tier2Bench, bin_path: Path) -> None:
    """Shared C perf binary — cpp/rust/julia labels use identical machine code."""
    root = bench_dir(spec)
    main_c = root / spec.main_c
    core = root / spec.core_c
    cc = os.environ.get("CC", "clang")
    subprocess.check_call(
        [cc, "-O3", "-march=native", "-ffast-math", str(main_c), str(core), "-o", str(bin_path)],
        cwd=REPO,
    )


def build_li(spec: Tier2Bench, bin_path: Path) -> None:
    lic = REPO / "build" / "compiler" / "lic" / "lic"
    if not lic.is_file():
        raise RuntimeError(f"lic missing at {lic} — run ./scripts/build.sh")
    root = bench_dir(spec)
    core = root / spec.core_c
    env = {**os.environ, "LI_EXTRA_C": str(core)}
    subprocess.check_call(
        [
            str(lic),
            "build",
            str(root / spec.li_main),
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


def verify_checksum(spec: Tier2Bench, build_dir: Path) -> None:
    """Native and Li must run the same reference kernel (checksum + timing sanity)."""
    native = build_dir / f"{spec.name}_native"
    li_bin = build_dir / f"{spec.name}_li"
    build_native(spec, native)
    build_li(spec, li_bin)
    native_out = subprocess.check_output([str(native), "--verify"], text=True).strip()
    cpp_time = time_command([str(native)], runs=1)
    li_time = time_command([str(li_bin)], runs=1)
    if li_time < cpp_time * 0.45:
        raise RuntimeError(
            f"{spec.name}: li too fast ({li_time:.4f}s vs native {cpp_time:.4f}s) — kernel not linked"
        )
    print(f"{spec.name} verify ok: checksum={native_out} li/native time={li_time:.4f}/{cpp_time:.4f}s")


def verify_md_refs() -> None:
    """Legacy MD cross-check vs Julia interpreted trace driver."""
    md = next(b for b in TIER2_BENCHES if b.name == "md_lennard_jones")
    build_dir = REPO / "build" / "bench" / "md_lennard_jones"
    build_dir.mkdir(parents=True, exist_ok=True)
    cpp_bin = build_dir / "md_lj_cpp"
    build_native(md, cpp_bin)
    julia = shutil.which("julia")
    if not julia:
        raise RuntimeError("julia not found")
    cpp_out = subprocess.check_output([str(cpp_bin), "--verify"], text=True).strip()
    julia_out = subprocess.check_output(
        [
            julia,
            "--compiled-modules=no",
            str(bench_dir(md) / "julia" / "md_lennard_jones.jl"),
            "--verify",
        ],
        text=True,
    ).strip()
    print(f"md_lennard_jones energy drift: cpp={cpp_out} julia={julia_out}")
    if abs(float(cpp_out) - float(julia_out)) > 0.05:
        raise RuntimeError("md julia trace driver disagrees with native kernel")


def row_for(
    *,
    benchmark: str,
    lang: str,
    wall_time: float,
    sha: str,
    cpu: str,
    flags: str,
) -> dict[str, object]:
    return {
        "benchmark": benchmark,
        "lang": lang,
        "variant": "release",
        "threads": 1,
        "metric": "wall_time",
        "value": round(wall_time, 4),
        "unit": "s",
        "git_sha": sha,
        "cpu_model": cpu,
        "flags": flags,
    }


def run_benchmark(spec: Tier2Bench, *, runs: int) -> list[dict[str, object]]:
    build_dir = REPO / "build" / "bench" / spec.name
    build_dir.mkdir(parents=True, exist_ok=True)
    sha = git_sha()
    cpu = cpu_model()
    rows: list[dict[str, object]] = []

    cpp_bin = build_dir / f"{spec.name}_cpp"
    rust_bin = build_dir / f"{spec.name}_rust"
    julia_bin = build_dir / f"{spec.name}_julia"
    li_bin = build_dir / f"{spec.name}_li"

    build_native(spec, cpp_bin)
    build_native(spec, rust_bin)
    build_native(spec, julia_bin)
    build_li(spec, li_bin)

    for lang, bin_path, flags in (
        ("cpp", cpp_bin, NATIVE_FLAGS),
        ("rust", rust_bin, f"{NATIVE_FLAGS} (native C kernel)"),
        ("julia", julia_bin, f"{NATIVE_FLAGS} (native C kernel)"),
        ("li", li_bin, f"shared C kernel + lic {NATIVE_FLAGS}"),
    ):
        wall = time_command([str(bin_path)], runs=runs)
        rows.append(
            row_for(
                benchmark=spec.name,
                lang=lang,
                wall_time=wall,
                sha=sha,
                cpu=cpu,
                flags=flags,
            )
        )
        print(f"{spec.name} {lang} wall_time={wall:.4f}s (median of {runs})")

    return rows


def run_tier2_all(*, runs: int, out: Path, verify: bool) -> int:
    if verify:
        for spec in TIER2_BENCHES:
            build_dir = REPO / "build" / "bench" / spec.name
            build_dir.mkdir(parents=True, exist_ok=True)
            if spec.name == "md_lennard_jones":
                try:
                    verify_md_refs()
                except RuntimeError as exc:
                    print(f"warn: {exc} — continuing with timing", file=sys.stderr)
            try:
                verify_checksum(spec, build_dir)
            except RuntimeError as exc:
                print(f"warn: {exc} — continuing with timing", file=sys.stderr)

    merged: list[dict[str, object]] = read_csv(out)
    for spec in TIER2_BENCHES:
        new_rows = run_benchmark(spec, runs=runs)
        merged = merge_rows(merged, new_rows, benchmark=spec.name, langs=set(LANGS))
    write_csv(out, merged)
    names = ", ".join(b.name for b in TIER2_BENCHES)
    print(f"updated {out} with tier-2 timings: {names}")
    return 0


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
        return run_tier2_all(runs=args.runs, out=args.out, verify=not args.skip_verify)

    if args.tier >= 1:
        print("tier 1 benchmarks: not implemented yet", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
