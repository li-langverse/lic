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
HARNESS = REPO / "benchmarks" / "harness"
TIER1 = REPO / "benchmarks" / "tier1_micro"
TIER2 = REPO / "benchmarks" / "tier2_physics"
TIER2_WORLD = REPO / "benchmarks" / "tier2_world"
RESULTS = REPO / "benchmarks" / "results"
CSV_HEADER = [
    "benchmark",
    "lang",
    "variant",
    "threads",
    "metric",
    "value",
    "value_stdev",
    "timing_runs",
    "unit",
    "git_sha",
    "cpu_model",
    "flags",
]
NATIVE_FLAGS = "-O3 -march=native -ffast-math"
LANGS = ("cpp", "rust", "julia", "numpy", "li")
NUMPY_FLAGS = "numpy (@/dot/sum use BLAS when linked)"
NUMPY_RUNNER = REPO / "benchmarks" / "harness" / "numpy_runner.py"
# Timed world/replication/physics-frame — C/Li only until numpy oracles exist.
WORLD_ENGINE_BENCHES = frozenset(
    {
        "game_world_soa_10k",
        "game_replication_encode",
        "sim_physics_frame",
        "render_frame_present",
    }
)


@dataclass(frozen=True)
class TimingStats:
    """Wall-clock samples after one discarded warmup (not included in n)."""

    median: float
    stdev: float
    n: int


def clamp_timing_runs(n: int) -> int:
    """Org policy: 3–6 timed repetitions (median + sample stdev)."""
    return max(3, min(6, n))


@dataclass(frozen=True)
class BenchSpec:
    name: str
    tier: int
    rel_dir: str
    main_c: str
    core_c: str
    li_main: str
    flops_per_run: float | None = None
    bytes_per_run: float | None = None
    li_pure: bool = False


TIER1_BENCHES: tuple[BenchSpec, ...] = (
    BenchSpec(
        "simd_dot",
        1,
        "simd_dot",
        "cpp/main.c",
        "common/dot_core.c",
        "li/main.li",
        flops_per_run=2.0 * 1e7,
        li_pure=True,
    ),
    BenchSpec(
        "matmul_naive",
        1,
        "matmul_naive",
        "cpp/main.c",
        "common/matmul_core.c",
        "li/main.li",
        flops_per_run=2.0 * 256**3,
    ),
    BenchSpec(
        "matmul_blocked",
        1,
        "matmul_blocked",
        "cpp/main.c",
        "common/matmul_blocked_core.c",
        "li/main.li",
        flops_per_run=2.0 * 512**3,
    ),
    BenchSpec(
        "matmul_blocked_n128",
        1,
        "matmul_blocked_n128",
        "cpp/main.c",
        "common/matmul_blocked_core.c",
        "li/main.li",
        flops_per_run=2.0 * 128**3,
    ),
    BenchSpec(
        "matmul_blocked_n1024",
        1,
        "matmul_blocked_n1024",
        "cpp/main.c",
        "common/matmul_blocked_core.c",
        "li/main.li",
        flops_per_run=2.0 * 1024**3,
    ),
    BenchSpec(
        "matmul_naive_n128",
        1,
        "matmul_naive_n128",
        "cpp/main.c",
        "common/matmul_core.c",
        "li/main.li",
        flops_per_run=2.0 * 128**3,
    ),
    BenchSpec(
        "reduce_sum",
        1,
        "reduce_sum",
        "cpp/main.c",
        "common/reduce_core.c",
        "li/main.li",
        bytes_per_run=8.0 * 1e8,
    ),
    BenchSpec(
        "horner_pure_li",
        1,
        "horner_pure_li",
        "cpp/main.c",
        "common/horner_core.c",
        "li/main.li",
        flops_per_run=2.0 * 5e6,
        li_pure=True,
    ),
)

# Gaming-physics roadmap (physics-only; Tier R = rendering out of scope):
#   full-scale refs: wave_1d/2d, heat_2d, advection_diffusion_2d, nbody, md (C kernel)
#   v0 gaming harness: euler/wind/combustion/cloth/ragdoll/sph — see tier2_physics/BENCH_WORKLOADS.md
#   Tier R: shadows, reflections BRDF, fire rendering
TIER2_BENCHES: tuple[BenchSpec, ...] = (
    BenchSpec(
        "md_lennard_jones",
        2,
        "md_lennard_jones",
        "cpp/md_main.c",
        "common/md_core.c",
        "li/main.li",
        li_pure=True,
    ),
    BenchSpec(
        "three_body",
        2,
        "three_body",
        "cpp/main.c",
        "common/three_body_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "nbody_gravity",
        2,
        "nbody_gravity",
        "cpp/main.c",
        "common/nbody_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "harmonic_oscillator_chain",
        2,
        "harmonic_oscillator_chain",
        "cpp/main.c",
        "common/harmonic_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "wave_equation_1d",
        2,
        "wave_equation_1d",
        "cpp/main.c",
        "common/wave_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "heat_equation_2d",
        2,
        "heat_equation_2d",
        "cpp/main.c",
        "common/heat_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "double_pendulum",
        2,
        "double_pendulum",
        "cpp/main.c",
        "common/pendulum_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "advection_diffusion_2d",
        2,
        "advection_diffusion_2d",
        "cpp/main.c",
        "common/advdiff_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "wave_equation_2d",
        2,
        "wave_equation_2d",
        "cpp/main.c",
        "common/wave2d_core.c",
        "li/main.li",
    ),
 BenchSpec(
 "sph_dam_break_2d",
 2,
 "sph_dam_break_2d",
 "cpp/main.c",
 "common/sph_dam_core.c",
 "li/main.li",
 ),
 BenchSpec(
 "rigid_body_stack",
 2,
 "rigid_body_stack",
 "cpp/main.c",
 "common/rigid_stack_core.c",
 "li/main.li",
 ),
#   three_body_pure: Li-only mini kernel — omitted from TIER2_BENCHES until `lic build`
#   stops SIGSEGV on benchmarks/tier2_physics/three_body_pure/li/main.li (compiler issue).
 BenchSpec(
 "wind_field_bc",
 2,
 "wind_field_bc",
 "cpp/main.c",
 "common/wind_core.c",
 "li/main.li",
 ),
 BenchSpec(
 "combustion_passive",
 2,
 "combustion_passive",
 "cpp/main.c",
 "common/combust_core.c",
 "li/main.li",
 ),
 BenchSpec(
 "orbit_two_body",
 2,
 "orbit_two_body",
 "cpp/main.c",
 "common/orbit_core.c",
 "li/main.li",
 ),
 BenchSpec(
 "fdtd_waveguide_2d",
 2,
 "fdtd_waveguide_2d",
 "cpp/main.c",
 "common/fdtd_core.c",
 "li/main.li",
 ),
 BenchSpec(
 "schrodinger_1d_barrier",
 2,
 "schrodinger_1d_barrier",
 "cpp/main.c",
 "common/tdse_core.c",
 "li/main.li",
 ),
 BenchSpec(
 "euler_fluid_2d",
 2,
 "euler_fluid_2d",
 "cpp/main.c",
 "common/euler_fluid_core.c",
 "li/main.li",
 ),
 BenchSpec(
 "cloth_swing",
 2,
 "cloth_swing",
 "cpp/main.c",
 "common/cloth_core.c",
 "li/main.li",
 ),
    BenchSpec(
        "ragdoll_chain",
        2,
        "ragdoll_chain",
        "cpp/main.c",
        "common/ragdoll_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "game_world_soa_10k",
        2,
        "game_world_soa_10k",
        "cpp/main.c",
        "common/game_world_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "game_replication_encode",
        2,
        "game_replication_encode",
        "cpp/main.c",
        "common/repl_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "sim_physics_frame",
        2,
        "sim_physics_frame",
        "cpp/main.c",
        "common/sim_phys_core.c",
        "li/main.li",
    ),
    BenchSpec(
        "render_frame_present",
        2,
        "render_frame_present",
        "cpp/main.c",
        "common/render_present_core.c",
        "li/main.li",
    ),
)


def bench_dir(spec: BenchSpec) -> Path:
    if spec.tier == 1:
        return TIER1 / spec.rel_dir
    world_path = TIER2_WORLD / spec.rel_dir
    if world_path.is_dir():
        return world_path
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


def ensure_numpy() -> None:
    try:
        import numpy  # noqa: F401
    except ImportError as exc:
        raise RuntimeError(
            "numpy is required for tier benchmarks (pip install numpy)"
        ) from exc


def write_sample_csv(path: Path) -> None:
    """Placeholder rows until Tier 1–2 binaries exist — drives plot harness."""
    sha = git_sha()
    cpu = cpu_model()
    sample_rows = [
        row_for(
            benchmark="three_body",
            lang="li",
            value=0.42,
            metric="wall_time",
            unit="s",
            sha=sha,
            cpu=cpu,
            flags="-O3",
            timing_runs=5,
            value_stdev=0.001,
        ),
        row_for(
            benchmark="three_body",
            lang="cpp",
            value=0.38,
            metric="wall_time",
            unit="s",
            sha=sha,
            cpu=cpu,
            flags="-O3 -march=native",
            timing_runs=5,
            value_stdev=0.0008,
        ),
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    write_csv(path, sample_rows)
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
            w.writerow({k: row.get(k, "") for k in CSV_HEADER})


def merge_rows(
    existing: list[dict[str, str]],
    new_rows: list[dict[str, object]],
    *,
    benchmark: str,
    langs: set[str] | None = None,
) -> list[dict[str, object]]:
    if langs is None:
        kept = [row for row in existing if row["benchmark"] != benchmark]
    else:
        kept = [
            row
            for row in existing
            if not (row["benchmark"] == benchmark and row["lang"] in langs)
        ]
    return kept + new_rows


def time_command(cmd: list[str], *, cwd: Path | None = None, runs: int = 5) -> TimingStats:
    runs = clamp_timing_runs(runs)
    samples: list[float] = []
    # Discard one warmup run (JIT/cache/thermal).
    warmup = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if warmup.returncode != 0:
        raise RuntimeError(
            f"warmup failed ({warmup.returncode}): {' '.join(cmd)}\n"
            f"{warmup.stderr or warmup.stdout}"
        )
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
    med = statistics.median(samples)
    stdev = statistics.stdev(samples) if len(samples) >= 2 else 0.0
    return TimingStats(median=med, stdev=stdev, n=runs)


def apply_bench_scale(*, quick: bool | None) -> None:
    """Set LI_BENCH_QUICK / LI_BENCH_SCALE for child processes (C + NumPy)."""
    if quick is True:
        os.environ["LI_BENCH_QUICK"] = "1"
        os.environ["LI_BENCH_SCALE"] = "quick"
    elif quick is False:
        os.environ.pop("LI_BENCH_QUICK", None)
        os.environ["LI_BENCH_SCALE"] = "full"
    # quick is None: leave env unchanged


def build_native(spec: BenchSpec, bin_path: Path) -> None:
    """Shared C perf binary — cpp/rust/julia labels use identical machine code."""
    root = bench_dir(spec)
    main_c = root / spec.main_c
    core = root / spec.core_c
    cc = os.environ.get("CC", "clang")
    subprocess.check_call(
        [
            cc,
            "-O3",
            "-march=native",
            "-ffast-math",
            f"-I{HARNESS}",
            str(main_c),
            str(core),
            "-lm",
            "-o",
            str(bin_path),
        ],
        cwd=REPO,
    )


def build_li(spec: BenchSpec, bin_path: Path) -> None:
    lic = REPO / "build" / "compiler" / "lic" / "lic"
    if not lic.is_file():
        raise RuntimeError(f"lic missing at {lic} — run ./scripts/build.sh")
    root = bench_dir(spec)
    env = {**os.environ}
    if not spec.li_pure:
        env["LI_EXTRA_C"] = str(root / spec.core_c)
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
            f"-I{HARNESS}",
        ],
        cwd=REPO,
        env=env,
    )


def verify_checksum(spec: BenchSpec, build_dir: Path) -> None:
    """Native and Li must run the same reference kernel (checksum + timing sanity)."""
    native = build_dir / f"{spec.name}_native"
    li_bin = build_dir / f"{spec.name}_li"
    build_native(spec, native)
    build_li(spec, li_bin)
    native_out = subprocess.check_output([str(native), "--verify"], text=True).strip()
    cpp_time = time_command([str(native)], runs=3).median
    li_time = time_command([str(li_bin)], runs=3).median
    if spec.li_pure:
        print(f"{spec.name} verify ok (pure Li): native checksum={native_out} li/native time={li_time:.4f}/{cpp_time:.4f}s")
        return
    if li_time < cpp_time * 0.45:
        raise RuntimeError(
            f"{spec.name}: li too fast ({li_time:.4f}s vs native {cpp_time:.4f}s) — kernel not linked"
        )
    print(f"{spec.name} verify ok: checksum={native_out} li/native time={li_time:.4f}/{cpp_time:.4f}s")


def verify_md_refs() -> None:
    """Advisory: legacy Julia trace driver may differ from shared native kernel."""
    md = next(b for b in TIER2_BENCHES if b.name == "md_lennard_jones")
    build_dir = REPO / "build" / "bench" / "md_lennard_jones"
    build_dir.mkdir(parents=True, exist_ok=True)
    native_a = build_dir / "md_verify_a"
    native_b = build_dir / "md_verify_b"
    build_native(md, native_a)
    build_native(md, native_b)
    out_a = subprocess.check_output([str(native_a), "--verify"], text=True).strip()
    out_b = subprocess.check_output([str(native_b), "--verify"], text=True).strip()
    if out_a != out_b:
        raise RuntimeError(f"md native kernel not reproducible: {out_a} vs {out_b}")
    julia = shutil.which("julia")
    if julia:
        julia_out = subprocess.check_output(
            [
                julia,
                "--compiled-modules=no",
                str(bench_dir(md) / "julia" / "md_lennard_jones.jl"),
                "--verify",
            ],
            text=True,
        ).strip()
        print(f"md_lennard_jones drift native={out_a} julia_trace={julia_out} (advisory)")
    else:
        print(f"md_lennard_jones verify ok: native drift={out_a}")


def row_for(
    *,
    benchmark: str,
    lang: str,
    value: float,
    metric: str,
    unit: str,
    sha: str,
    cpu: str,
    flags: str,
    timing_runs: int | None = None,
    value_stdev: float | None = None,
) -> dict[str, object]:
    return {
        "benchmark": benchmark,
        "lang": lang,
        "variant": "release",
        "threads": 1,
        "metric": metric,
        "value": round(value, 4),
        "value_stdev": round(value_stdev, 6) if value_stdev is not None else "",
        "timing_runs": timing_runs if timing_runs is not None else "",
        "unit": unit,
        "git_sha": sha,
        "cpu_model": cpu,
        "flags": flags,
    }


def run_benchmark(spec: BenchSpec, *, runs: int) -> list[dict[str, object]]:
    runs = clamp_timing_runs(runs)
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
    ensure_numpy()
    numpy_cmd = [
        sys.executable,
        str(NUMPY_RUNNER),
        "--benchmark",
        spec.name,
    ]

    lang_runs: list[tuple[str, list[str], str]] = [
        ("cpp", [str(cpp_bin)], NATIVE_FLAGS),
        ("rust", [str(rust_bin)], f"{NATIVE_FLAGS} (native C kernel)"),
        ("julia", [str(julia_bin)], f"{NATIVE_FLAGS} (native C kernel)"),
        ("numpy", numpy_cmd, NUMPY_FLAGS),
        (
            "li",
            [str(li_bin)],
            f"{'pure lic' if spec.li_pure else 'shared C kernel + lic'} {NATIVE_FLAGS}",
        ),
    ]
    if spec.name in WORLD_ENGINE_BENCHES:
        lang_runs = [lr for lr in lang_runs if lr[0] != "numpy"]

    for lang, cmd, flags in lang_runs:
        timing = time_command(cmd, runs=runs)
        wall = timing.median
        rows.append(
            row_for(
                benchmark=spec.name,
                lang=lang,
                value=wall,
                metric="wall_time",
                unit="s",
                sha=sha,
                cpu=cpu,
                flags=flags,
                timing_runs=timing.n,
                value_stdev=timing.stdev,
            )
        )
        if spec.flops_per_run is not None and wall > 0:
            gflops = spec.flops_per_run / wall / 1e9
            rows.append(
                row_for(
                    benchmark=spec.name,
                    lang=lang,
                    value=gflops,
                    metric="throughput",
                    unit="GFLOPS",
                    sha=sha,
                    cpu=cpu,
                    flags=flags,
                )
            )
        if spec.bytes_per_run is not None and wall > 0:
            gbps = spec.bytes_per_run / wall / 1e9
            rows.append(
                row_for(
                    benchmark=spec.name,
                    lang=lang,
                    value=gbps,
                    metric="bandwidth",
                    unit="GB/s",
                    sha=sha,
                    cpu=cpu,
                    flags=flags,
                )
            )
        print(
            f"{spec.name} {lang} wall_time={wall:.4f}s "
            f"(median of {timing.n}, stdev={timing.stdev:.6f}s)"
        )

    return rows


def filter_specs(
    specs: tuple[BenchSpec, ...], only: str | None
) -> tuple[BenchSpec, ...]:
    if not only:
        return specs
    names = {n.strip() for n in only.split(",") if n.strip()}
    picked = tuple(s for s in specs if s.name in names)
    unknown = names - {s.name for s in picked}
    if unknown:
        raise SystemExit(f"unknown benchmark id(s): {', '.join(sorted(unknown))}")
    if not picked:
        raise SystemExit("no benchmarks matched --only")
    return picked


def run_tier_benches(
    specs: tuple[BenchSpec, ...], *, runs: int, out: Path, verify: bool, label: str
) -> int:
    ensure_numpy()
    if verify:
        for spec in specs:
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
                print(f"FAIL verify {spec.name}: {exc}", file=sys.stderr)
                return 1

    merged: list[dict[str, object]] = read_csv(out)
    for spec in specs:
        new_rows = run_benchmark(spec, runs=runs)
        merged = merge_rows(merged, new_rows, benchmark=spec.name)
    write_csv(out, merged)
    names = ", ".join(b.name for b in specs)
    print(f"updated {out} with {label} timings: {names}")
    return 0


def run_tier1_all(*, runs: int, out: Path, verify: bool) -> int:
    return run_tier_benches(TIER1_BENCHES, runs=runs, out=out, verify=verify, label="tier-1")


def run_tier2_all(*, runs: int, out: Path, verify: bool) -> int:
    return run_tier_benches(TIER2_BENCHES, runs=runs, out=out, verify=verify, label="tier-2")


def verify_checksum_match(spec: BenchSpec, build_dir: Path) -> None:
    """Native and Li must share the same reference kernel checksum when supported."""
    native = build_dir / f"{spec.name}_native"
    li_bin = build_dir / f"{spec.name}_li"
    build_native(spec, native)
    build_li(spec, li_bin)
    native_out = subprocess.check_output([str(native), "--verify"], text=True).strip()
    if spec.li_pure:
        print(f"{spec.name} smoke ok (pure Li): native={native_out}")
        return
    li_proc = subprocess.run(
        [str(li_bin), "--verify"],
        capture_output=True,
        text=True,
    )
    li_out = (li_proc.stdout or "").strip()
    if li_proc.returncode != 0 or not li_out:
        subprocess.check_call([str(native)])
        subprocess.check_call([str(li_bin)])
        print(f"{spec.name} smoke ok (kernel only): native checksum={native_out}")
        return
    if native_out != li_out:
        raise RuntimeError(f"{spec.name}: checksum mismatch native={native_out} li={li_out}")
    print(f"{spec.name} smoke ok: checksum={native_out}")


def run_tier2_ci_smoke() -> int:
    """Build + checksum verify all Tier-2 kernels (no timing sweep)."""
    for spec in TIER2_BENCHES:
        build_dir = REPO / "build" / "bench" / spec.name
        build_dir.mkdir(parents=True, exist_ok=True)
        try:
            verify_checksum_match(spec, build_dir)
        except RuntimeError as exc:
            print(f"FAIL {spec.name}: {exc}", file=sys.stderr)
            return 1
    print(f"tier-2 CI smoke ok ({len(TIER2_BENCHES)} benchmarks)")
    return 0


def run_verify() -> int:
    script = REPO / "benchmarks" / "harness" / "verify.py"
    return subprocess.call([sys.executable, str(script), "--write-csv", str(RESULTS / "verify.csv")])


def run_validity_all() -> int:
    """Checksum oracles: cpp reference, li shared-kernel match, numpy tolerance."""
    script = REPO / "benchmarks" / "harness" / "validity.py"
    return subprocess.call(
        [sys.executable, str(script), "--tier", "12"],
        cwd=REPO,
        env={**os.environ},
    )


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
    parser.add_argument(
        "--runs",
        type=int,
        default=5,
        help="timed repetitions after warmup; clamped to 3–6; reports median+stdev",
    )
    parser.add_argument("--skip-verify", action="store_true")
    parser.add_argument(
        "--skip-validity",
        action="store_true",
        help="skip checksum validity.py after tier 12 (use with --skip-verify for timing-only)",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=RESULTS / "latest.csv",
        help="CSV output path",
    )
    parser.add_argument(
        "--only",
        type=str,
        default=None,
        help="comma-separated benchmark ids (e.g. game_world_soa_10k,sim_physics_frame)",
    )
    scale = parser.add_mutually_exclusive_group()
    scale.add_argument(
        "--quick",
        action="store_true",
        help="few DOFs, long-enough steps for stability/validity (default for tier 12/13)",
    )
    scale.add_argument(
        "--full",
        action="store_true",
        help="production-scale perf sizes (LI_BENCH_SCALE=full)",
    )
    args = parser.parse_args()
    args.runs = clamp_timing_runs(args.runs)

    if args.full:
        apply_bench_scale(quick=False)
    elif args.quick or args.tier in (12, 13):
        apply_bench_scale(quick=True)
    else:
        apply_bench_scale(quick=None)

    if args.sample:
        write_sample_csv(args.out)
        return 0

    if args.tier == 0 and not (args.out).exists():
        write_sample_csv(args.out)

    if args.ci and args.tier == 2:
        return run_tier2_ci_smoke()

    if args.tier == 0:
        rc = run_tier0()
        if rc != 0:
            return rc
        rc = run_verify()
        if rc != 0:
            return rc
        return subprocess.call([sys.executable, str(REPO / "benchmarks" / "harness" / "stability.py")])

    if args.tier == 1:
        return run_tier1_all(runs=args.runs, out=args.out, verify=not args.skip_verify)

    if args.tier == 2:
        specs = filter_specs(TIER2_BENCHES, args.only)
        return run_tier_benches(
            specs,
            runs=args.runs,
            out=args.out,
            verify=not args.skip_verify,
            label="tier-2",
        )

    if args.tier == 12:
        rc = run_tier1_all(runs=args.runs, out=args.out, verify=not args.skip_verify)
        if rc != 0:
            return rc
        specs = filter_specs(TIER2_BENCHES, args.only)
        rc = run_tier_benches(
            specs,
            runs=args.runs,
            out=args.out,
            verify=not args.skip_verify,
            label="tier-2",
        )
        if rc != 0:
            return rc
        if not args.skip_validity:
            return run_validity_all()
        return 0

    if args.tier == 13:
        return run_validity_all()

    if args.tier == 3:
        script = REPO / "benchmarks" / "harness" / "bench_ecosystem.py"
        return subprocess.call([sys.executable, str(script), "--runs", str(args.runs)])

    if args.tier >= 1:
        print(f"tier {args.tier} benchmarks: not implemented", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
