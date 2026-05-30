#!/usr/bin/env python3
"""Run benchmark tiers and write results/latest.csv."""

from __future__ import annotations

import argparse
import csv
import math
import os
import platform
import shutil
import statistics
import subprocess
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

_HARNESS = Path(__file__).resolve().parent
if str(_HARNESS) not in sys.path:
    sys.path.insert(0, str(_HARNESS))
from timing_stats import TimingStats, time_command as _time_command_stats

REPO = Path(__file__).resolve().parents[2]
TIER1 = REPO / "benchmarks" / "tier1_micro"
TIER_STDLIB = REPO / "benchmarks" / "tier1_stdlib"
TIER2 = REPO / "benchmarks" / "tier2_physics"
RESULTS = REPO / "benchmarks" / "results"
CSV_HEADER = [
    "benchmark",
    "lang",
    "variant",
    "threads",
    "metric",
    "value",
    "stddev",
    "sample_runs",
    "unit",
    "git_sha",
    "cpu_model",
    "flags",
    "os",
    "passed",
    "oracle_kind",
    "verify_abs_err",
    "verify_rel_err",
    "verify_ulps",
    "verify_within_1ulp",
]
NATIVE_FLAGS = "-O3 -march=native -ffast-math"
LANGS = ("cpp", "rust", "julia", "li")


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
    li_enabled: bool = True


_WP1_NUM_IDS: tuple[str, ...] = (
    "num_cg",
    "num_cholesky",
    "num_eig_symmetric",
    "num_fft_r2c",
    "num_gmres",
    "num_integ_euler",
    "num_integ_rk4",
    "num_integ_semi_implicit",
    "num_integ_symplectic",
    "num_integ_verlet",
    "num_opt_bfgs",
    "num_opt_line_search",
    "num_quadrature_gauss",
    "num_rng_pcg",
    "num_root_newton",
    "num_sparse_mv",
    "fft_1d_fixed",
)


def _wp1_num_bench_specs() -> tuple[BenchSpec, ...]:
    """Catalog num_* + fft_1d_fixed smoke harnesses (shared C oracle)."""
    return tuple(
        BenchSpec(
            name=bench_id,
            tier=1,
            rel_dir=bench_id,
            main_c="cpp/main.c",
            core_c=f"common/{bench_id}_core.c",
            li_main="li/main.li",
            li_pure=False,
        )
        for bench_id in _WP1_NUM_IDS
    )


TIER1_BENCHES: tuple[BenchSpec, ...] = (
    BenchSpec(
        "simd_dot",
        1,
        "simd_dot",
        "cpp/main.c",
        "common/dot_core.c",
        "li/main.li",
        flops_per_run=2.0 * 1e7,
        li_pure=False,
    ),
    BenchSpec(
        "matmul_naive",
        1,
        "matmul_naive",
        "cpp/main.c",
        "common/matmul_core.c",
        "li/main.li",
        flops_per_run=2.0 * 256**3,
        li_pure=True,
    ),
    BenchSpec(
        "matmul_blocked",
        1,
        "matmul_blocked",
        "cpp/main.c",
        "common/matmul_blocked_core.c",
        "li/main.li",
        flops_per_run=2.0 * 512**3,
        li_pure=True,
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
) + _wp1_num_bench_specs()

# Stdlib ADT tier-1 (WP0-C): native oracles only until WP1 Li drivers land.
TIER_STDLIB_BENCHES: tuple[BenchSpec, ...] = (
    BenchSpec(
        "stdlib_sort_int",
        1,
        "stdlib_sort_int",
        "cpp/main.c",
        "common/sort_core.c",
        "li/main.li",
        li_enabled=False,
    ),
    BenchSpec(
        "stdlib_dict_insert_lookup",
        1,
        "stdlib_dict_insert_lookup",
        "cpp/main.c",
        "common/dict_core.c",
        "li/main.li",
        li_enabled=False,
    ),
    BenchSpec(
        "stdlib_binary_search",
        1,
        "stdlib_binary_search",
        "cpp/main.c",
        "common/search_core.c",
        "li/main.li",
        li_enabled=False,
    ),
)

# Gaming-physics roadmap (physics-only; Tier R = rendering out of scope):
#   exists: md_lennard_jones + catalog md_* aliases, nbody, wave_1d/2d, heat_2d, advection_diffusion_2d, sph_dam_break_2d (stub)
#   planned: euler_fluid_2d, combustion_passive, wind_field_bc, rigid_body, cloth, mls_mpm
#   Tier R: shadows, reflections BRDF, fire rendering
TIER2_BENCHES: tuple[BenchSpec, ...] = (
    BenchSpec(
        "md_lennard_jones",
        2,
        "md_lennard_jones",
        "cpp/md_main.c",
        "common/md_core.c",
        "li/main.li",
        li_pure=False,
    ),
    *(
        BenchSpec(
            md_id,
            2,
            md_id,
            "cpp/md_main.c",
            "common/md_core.c",
            "li/main.li",
        )
        for md_id in (
            "md_barostat_parrinello_rahman",
            "md_constraints_rattle",
            "md_constraints_shake",
            "md_energy_drift",
            "md_init_fcc_mb",
            "md_integrator_leapfrog",
            "md_integrator_verlet",
            "md_longrange_ewald",
            "md_longrange_pme",
            "md_neighbor_cell_list",
            "md_neighbor_verlet_skin",
            "md_oracle_external",
            "md_thermostat_berendsen",
            "md_thermostat_nose_hoover",
        )
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
 BenchSpec(
 "three_body_pure",
 2,
 "three_body_pure",
 "cpp/main.c",
 "common/three_body_core.c",
 "li/main.li",
 ),
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
)


def bench_dir(spec: BenchSpec) -> Path:
    if spec.name.startswith("stdlib_"):
        return TIER_STDLIB / spec.rel_dir
    root = TIER1 if spec.tier == 1 else TIER2
    return root / spec.rel_dir


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
        ("advection_diffusion_2d", "li", "release", 1, "wall_time", 0.65, "s", sha, cpu, "-O3"),
        ("advection_diffusion_2d", "cpp", "release", 1, "wall_time", 0.60, "s", sha, cpu, "-O3"),
        ("wave_equation_2d", "li", "release", 1, "wall_time", 0.90, "s", sha, cpu, "-O3"),
        ("wave_equation_2d", "cpp", "release", 1, "wall_time", 0.85, "s", sha, cpu, "-O3"),
        ("sph_dam_break_2d", "li", "release", 1, "wall_time", 1.5, "s", sha, cpu, "-O3"),
        ("sph_dam_break_2d", "cpp", "release", 1, "wall_time", 1.4, "s", sha, cpu, "-O3"),
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


def normalize_csv_row(row: dict[str, object]) -> dict[str, str]:
    """Backfill new columns when merging rows from older latest.csv files."""
    out: dict[str, str] = {}
    for key in CSV_HEADER:
        val = row.get(key, "")
        out[key] = "" if val is None else str(val)
    if not out.get("os"):
        out["os"] = host_os_tag()
    return out


def write_csv(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=CSV_HEADER)
        w.writeheader()
        for row in rows:
            w.writerow(normalize_csv_row(row))


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


def _bench_env_flag(name: str, default: str = "1") -> bool:
    return os.environ.get(name, default).strip().lower() not in ("0", "false", "no", "off")


def time_command(cmd: list[str], *, cwd: Path | None = None, runs: int = 6) -> TimingStats:
    return _time_command_stats(cmd, cwd=cwd, runs=runs)


def build_native(spec: BenchSpec, bin_path: Path) -> None:
    """Shared C perf binary — cpp/rust/julia labels use identical machine code."""
    root = bench_dir(spec)
    main_c = root / spec.main_c
    core = root / spec.core_c
    cc = os.environ.get("CC", "clang")
    subprocess.check_call(
        [cc, "-O3", "-march=native", "-ffast-math", str(main_c), str(core), "-lm", "-o", str(bin_path)],
        cwd=REPO,
    )


def build_li(spec: BenchSpec, bin_path: Path) -> None:
    lic = REPO / "build" / "compiler" / "lic" / "lic"
    if not lic.is_file():
        raise RuntimeError(f"lic missing at {lic} — run ./scripts/build.sh")
    root = bench_dir(spec)
    env = dict(os.environ)
    if not spec.li_pure:
        env["LI_EXTRA_C"] = str(root / spec.core_c)
    subprocess.check_call(
        [
            str(lic),
            "build",
            str(root / spec.li_main),
            "-o",
            str(bin_path),
            "--allow-open-vc",
            "--no-lean-verify",
            "--release",
            "-O3",
            "-ffast-math",
            "-march=native",
        ],
        cwd=REPO,
        env=env,
    )


# Li and native are different programs (e.g. reduced steps); only check native reproducibility.
SKIP_LI_NATIVE_RESULT_PARITY: frozenset[str] = frozenset({"three_body_pure"})


def native_result_checksum(native_bin: Path) -> str:
    return subprocess.check_output([str(native_bin), "--verify"], text=True).strip()


def li_result_checksum(li_bin: Path, *, try_argv_verify: bool) -> str:
    """Read benchmark result via --verify or LI_PRINT_SINK_F64 (last line of stdout)."""
    if try_argv_verify:
        proc = subprocess.run(
            [str(li_bin), "--verify"],
            capture_output=True,
            text=True,
            check=False,
        )
        if proc.returncode == 0 and (proc.stdout or "").strip():
            lines = (proc.stdout or "").strip().splitlines()
            return lines[-1].strip()
    env = {**os.environ, "LI_PRINT_SINK_F64": "1"}
    proc = subprocess.run(
        [str(li_bin)],
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )
    if proc.returncode != 0:
        raise RuntimeError(
            f"Li result run failed (rc={proc.returncode}, stderr={(proc.stderr or '')!r})"
        )
    lines = (proc.stdout or "").strip().splitlines()
    if not lines:
        raise RuntimeError("Li result run produced no stdout (set li_rt_volatile_sink_f64 on final value)")
    return lines[-1].strip()


def verify_stdlib_benchmark(spec: BenchSpec, build_dir: Path) -> None:
    """WP0: per-bench reference.py + native --verify (no Li until WP1)."""
    root = bench_dir(spec)
    ref_script = root / "reference.py"
    if not ref_script.is_file():
        raise RuntimeError(f"{spec.name}: missing {ref_script}")
    proc = subprocess.run(
        [sys.executable, str(ref_script), "--verify-cpp"],
        cwd=root,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        raise RuntimeError(
            f"{spec.name}: reference.py --verify-cpp failed\n{proc.stderr or proc.stdout}"
        )
    native = build_dir / f"{spec.name}_native"
    build_native(spec, native)
    native_out = native_result_checksum(native)
    print(f"{spec.name} verify ok (stdlib native oracle): checksum={native_out}")


@dataclass
class BenchmarkVerifyOutcome:
    deviation_reports: list = field(default_factory=list)
    oracle_kind: str = "iterative"


def host_os_tag() -> str:
    sys_name = platform.system().lower()
    if sys_name == "darwin":
        return "darwin"
    if sys_name == "windows":
        return "windows"
    if sys_name == "linux":
        return "linux"
    return "unknown"


def verify_csv_rows(
    spec: BenchSpec,
    outcome: BenchmarkVerifyOutcome,
    *,
    sha: str,
    cpu: str,
    flags: str,
    lang: str,
) -> list[dict[str, object]]:
    """Export verify metrics for dashboard ingest (one row per metric)."""
    from reference import TIER1_REFERENCE, float_close, primary_report_for_label

    label_for_lang = {"li": "Li", "cpp": "native", "rust": "native", "julia": "native"}
    report_label = label_for_lang.get(lang, lang)
    primary = primary_report_for_label(outcome.deviation_reports, report_label)
    if primary is None:
        return []
    ref_case = TIER1_REFERENCE.get(spec.name)
    if ref_case is not None:
        spec_pass = float_close(
            primary.actual,
            primary.reference,
            rtol=ref_case.rtol,
            atol=ref_case.atol,
        )
    else:
        spec_pass = primary.within_machine_epsilon
    passed = "true" if spec_pass else "false"
    shared = dict(
        benchmark=spec.name,
        lang=lang,
        sha=sha,
        cpu=cpu,
        flags=flags,
        passed=passed,
        oracle_kind=outcome.oracle_kind,
        verify_abs_err=f"{primary.abs_error:.6e}",
        verify_rel_err=f"{primary.rel_error:.6e}",
        verify_ulps=f"{primary.ulps:.4f}",
        verify_within_1ulp="1" if primary.within_machine_epsilon else "0",
    )
    rows: list[dict[str, object]] = []

    def add(metric: str, value: float, unit: str) -> None:
        rows.append(row_for(metric=metric, value=value, unit=unit, **shared))

    add("verify_checksum", primary.actual, "f64")
    add("verify_analytical", primary.reference, "f64")
    add("verify_abs_err", primary.abs_error, "f64")
    add("verify_rel_err", primary.rel_error, "ratio")
    add("verify_ulps", primary.ulps, "ulp")
    add("verify_within_1ulp", 1.0 if primary.within_machine_epsilon else 0.0, "bool")
    return rows


def verify_benchmark_results(spec: BenchSpec, build_dir: Path) -> BenchmarkVerifyOutcome:
    """Verify results against normative spec (reference.py), then Li vs native when applicable."""
    if not spec.li_enabled:
        verify_stdlib_benchmark(spec, build_dir)
        return BenchmarkVerifyOutcome()
    from reference import (
        TIER1_REFERENCE,
        assert_checksum_against_spec,
        assert_spec_small_matches_table,
        float_close,
        format_result,
        parse_result,
        print_deviation_reports,
    )

    native = build_dir / f"{spec.name}_native"
    li_bin = build_dir / f"{spec.name}_li"
    build_native(spec, native)
    build_li(spec, li_bin)

    ref_case = TIER1_REFERENCE.get(spec.name)
    oracle_kind = ref_case.oracle if ref_case is not None else "iterative"
    deviation_logs: list = []
    if ref_case is not None and os.environ.get("BENCH_VERIFY_REFERENCE", "1").strip() not in (
        "0",
        "false",
        "no",
    ):
        assert_spec_small_matches_table(spec.name, ref_case)
        small_expected = format_result(ref_case.compute_small())
        oracle = ref_case.oracle
        print(f"{spec.name} spec small ok ({oracle}): {small_expected}")

    native_out = native_result_checksum(native)
    if ref_case is not None and os.environ.get("BENCH_VERIFY_REFERENCE", "1").strip() not in (
        "0",
        "false",
        "no",
    ):
        deviation_logs.extend(
            assert_checksum_against_spec(
                spec.name,
                native_out,
                label="native",
                size="full",
                ref=ref_case,
                use_small=False,
            )
        )

    if spec.name in SKIP_LI_NATIVE_RESULT_PARITY:
        native_b = build_dir / f"{spec.name}_native_b"
        build_native(spec, native_b)
        native_b_out = native_result_checksum(native_b)
        if native_out != native_b_out:
            raise RuntimeError(f"{spec.name}: native checksum not reproducible")
        print(f"{spec.name} verify ok (native only): checksum={native_out}")
        return BenchmarkVerifyOutcome(
            deviation_reports=deviation_logs,
            oracle_kind=oracle_kind,
        )

    t0 = time.perf_counter()
    li_out = li_result_checksum(li_bin, try_argv_verify=not spec.li_pure)
    li_elapsed = time.perf_counter() - t0
    native_elapsed_for_guard: float | None = None
    if ref_case is not None and os.environ.get("BENCH_VERIFY_REFERENCE", "1").strip() not in (
        "0",
        "false",
        "no",
    ):
        if spec.li_pure and li_elapsed < ref_case.min_li_seconds:
            # Absolute floors catch optimized-away kernels on normal loop lowerings, but
            # closed-form codegen (for example Horner chunking) can legitimately fall
            # below a fixed wall-time threshold on fast machines. Confirm against the
            # native oracle before reporting DCE / wrong-size suspicion.
            native_elapsed_for_guard = time_command([str(native)], runs=1).mean
            if li_elapsed < native_elapsed_for_guard * 0.45:
                raise RuntimeError(
                    f"{spec.name}: Li ran in {li_elapsed:.4f}s < "
                    f"{ref_case.min_li_seconds}s and <45% of native "
                    f"({native_elapsed_for_guard:.4f}s), likely DCE / wrong problem size"
                )
        deviation_logs.extend(
            assert_checksum_against_spec(
                spec.name,
                li_out,
                label="Li",
                size="full",
                ref=ref_case,
                use_small=False,
            )
        )

    if deviation_logs:
        print_deviation_reports(deviation_logs, bench=spec.name)

    if li_out != native_out:
        if ref_case is not None:
            li_value = parse_result(li_out)
            native_value = parse_result(native_out)
            if not float_close(li_value, native_value, rtol=ref_case.rtol, atol=ref_case.atol):
                raise RuntimeError(
                    f"{spec.name}: Li vs native mismatch li={li_out!r} native={native_out!r} "
                    f"(rtol={ref_case.rtol}, atol={ref_case.atol})"
                )
        else:
            raise RuntimeError(
                f"{spec.name}: Li vs native mismatch li={li_out!r} native={native_out!r} "
                "(both should match normative spec; fix codegen or kernel)"
            )

    if os.environ.get("BENCH_VERIFY_TIMING", "").strip() in ("1", "true", "yes"):
        cpp_time = native_elapsed_for_guard or time_command([str(native)], runs=1).mean
        li_time = time_command([str(li_bin)], runs=1).mean
        if li_time < cpp_time * 0.45:
            raise RuntimeError(
                f"{spec.name}: suspiciously fast Li ({li_time:.4f}s vs native {cpp_time:.4f}s)"
            )

    variant = "pure Li" if spec.li_pure else "shared C kernel"
    print(f"{spec.name} verify ok ({variant}): result={li_out}")
    return BenchmarkVerifyOutcome(
        deviation_reports=deviation_logs,
        oracle_kind=oracle_kind,
    )


def verify_checksum(spec: BenchSpec, build_dir: Path) -> BenchmarkVerifyOutcome:
    return verify_benchmark_results(spec, build_dir)


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
    passed: str = "",
    oracle_kind: str = "",
    verify_abs_err: str = "",
    verify_rel_err: str = "",
    verify_ulps: str = "",
    verify_within_1ulp: str = "",
    stddev: float | None = None,
    sample_runs: int | None = None,
) -> dict[str, object]:
    row: dict[str, object] = {
        "benchmark": benchmark,
        "lang": lang,
        "variant": "release",
        "threads": 1,
        "metric": metric,
        "value": round(value, 4),
        "stddev": round(stddev, 6) if stddev is not None else "",
        "sample_runs": sample_runs if sample_runs is not None else "",
        "unit": unit,
        "git_sha": sha,
        "cpu_model": cpu,
        "flags": flags,
        "os": host_os_tag(),
        "passed": passed,
        "oracle_kind": oracle_kind,
        "verify_abs_err": verify_abs_err,
        "verify_rel_err": verify_rel_err,
        "verify_ulps": verify_ulps,
        "verify_within_1ulp": verify_within_1ulp,
    }
    return row


def _timing_row_fields(timing: TimingStats) -> dict[str, object]:
    return {"stddev": timing.stddev, "sample_runs": timing.sample_runs}


def run_benchmark(spec: BenchSpec, *, runs: int) -> list[dict[str, object]]:
    build_dir = REPO / "build" / "bench" / spec.name
    build_dir.mkdir(parents=True, exist_ok=True)
    sha = git_sha()
    cpu = cpu_model()
    rows: list[dict[str, object]] = []

    cpp_bin = build_dir / f"{spec.name}_cpp"
    build_native(spec, cpp_bin)
    if not spec.li_enabled:
        timing = time_command([str(cpp_bin)], runs=runs)
        rows.append(
            row_for(
                benchmark=spec.name,
                lang="cpp",
                value=timing.mean,
                metric="wall_time",
                unit="s",
                sha=sha,
                cpu=cpu,
                flags=NATIVE_FLAGS,
                **_timing_row_fields(timing),
            )
        )
        print(
            f"{spec.name} cpp wall_time={timing.mean:.4f}s ± {timing.stddev:.4f}s "
            f"(n={timing.sample_runs}); Li column pending WP1"
        )
        return rows

    rust_bin = build_dir / f"{spec.name}_rust"
    julia_bin = build_dir / f"{spec.name}_julia"
    li_bin = build_dir / f"{spec.name}_li"

    build_native(spec, rust_bin)
    build_native(spec, julia_bin)
    build_li(spec, li_bin)

    for lang, bin_path, flags in (
        ("cpp", cpp_bin, NATIVE_FLAGS),
        ("rust", rust_bin, f"{NATIVE_FLAGS} (native C kernel)"),
        ("julia", julia_bin, f"{NATIVE_FLAGS} (native C kernel)"),
        ("li", li_bin, f"{'pure lic' if spec.li_pure else 'shared C kernel + lic'} {NATIVE_FLAGS}"),
    ):
        timing = time_command([str(bin_path)], runs=runs)
        rows.append(
            row_for(
                benchmark=spec.name,
                lang=lang,
                value=timing.mean,
                metric="wall_time",
                unit="s",
                sha=sha,
                cpu=cpu,
                flags=flags,
                **_timing_row_fields(timing),
            )
        )
        if spec.flops_per_run is not None and timing.mean > 0:
            gflops = spec.flops_per_run / timing.mean / 1e9
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
        if spec.bytes_per_run is not None and timing.mean > 0:
            gbps = spec.bytes_per_run / timing.mean / 1e9
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
            f"{spec.name} {lang} wall_time={timing.mean:.4f}s ± {timing.stddev:.4f}s "
            f"(n={timing.sample_runs})"
        )

    return rows


def filter_specs(
    specs: tuple[BenchSpec, ...], only: set[str] | None
) -> tuple[BenchSpec, ...]:
    if not only:
        return specs
    filtered = tuple(s for s in specs if s.name in only)
    if not filtered:
        print(f"bench: no benchmarks in scope for --only {sorted(only)}", file=sys.stderr)
    return filtered


def run_tier_benches(
    specs: tuple[BenchSpec, ...], *, runs: int, out: Path, verify: bool, label: str
) -> int:
    if not specs:
        return 1
    verify_outcomes: dict[str, BenchmarkVerifyOutcome] = {}
    sha = git_sha()
    cpu = cpu_model()
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
                verify_outcomes[spec.name] = verify_checksum(spec, build_dir)
            except RuntimeError as exc:
                print(f"FAIL verify {spec.name}: {exc}", file=sys.stderr)
                return 1

    merged: list[dict[str, object]] = read_csv(out)
    for spec in specs:
        new_rows = run_benchmark(spec, runs=runs)
        outcome = verify_outcomes.get(spec.name)
        if outcome is not None:
            for lang in ("li", "cpp"):
                new_rows.extend(
                    verify_csv_rows(
                        spec,
                        outcome,
                        sha=sha,
                        cpu=cpu,
                        flags=NATIVE_FLAGS,
                        lang=lang,
                    )
                )
        merged = merge_rows(merged, new_rows, benchmark=spec.name)
    write_csv(out, merged)
    names = ", ".join(b.name for b in specs)
    print(f"updated {out} with {label} timings: {names}")
    return 0


def run_tier1_all(
    *, runs: int, out: Path, verify: bool, only: set[str] | None = None
) -> int:
    specs = filter_specs(TIER1_BENCHES, only)
    return run_tier_benches(specs, runs=runs, out=out, verify=verify, label="tier-1")


def run_tier_stdlib_all(
    *, runs: int, out: Path, verify: bool, only: set[str] | None = None
) -> int:
    specs = filter_specs(TIER_STDLIB_BENCHES, only)
    return run_tier_benches(specs, runs=runs, out=out, verify=verify, label="tier-stdlib")


def run_tier2_all(
    *, runs: int, out: Path, verify: bool, only: set[str] | None = None
) -> int:
    specs = filter_specs(TIER2_BENCHES, only)
    return run_tier_benches(specs, runs=runs, out=out, verify=verify, label="tier-2")


def verify_checksum_match(spec: BenchSpec, build_dir: Path) -> None:
    verify_benchmark_results(spec, build_dir)


def run_verify_results(
    specs: tuple[BenchSpec, ...], *, label: str, only: set[str] | None = None
) -> int:
    specs = filter_specs(specs, only)
    """Verify numerical results only (no timing CSV update)."""
    failures: list[str] = []
    for spec in specs:
        build_dir = REPO / "build" / "bench" / spec.name
        build_dir.mkdir(parents=True, exist_ok=True)
        if spec.name == "md_lennard_jones":
            try:
                verify_md_refs()
            except RuntimeError as exc:
                print(f"warn: {exc}", file=sys.stderr)
        try:
            verify_benchmark_results(spec, build_dir)
        except RuntimeError as exc:
            failures.append(f"{spec.name}: {exc}")
            print(f"FAIL verify {spec.name}: {exc}", file=sys.stderr)
    if failures:
        print(f"result verify: {len(failures)} failure(s) in {label}", file=sys.stderr)
        return 1
    print(f"result verify ok ({label}, {len(specs)} benchmarks)")
    return 0


def run_tier2_ci_smoke(*, only: set[str] | None = None) -> int:
    """Build + checksum verify all Tier-2 kernels (no timing sweep)."""
    specs = filter_specs(TIER2_BENCHES, only)
    for spec in specs:
        build_dir = REPO / "build" / "bench" / spec.name
        build_dir.mkdir(parents=True, exist_ok=True)
        try:
            verify_checksum_match(spec, build_dir)
        except RuntimeError as exc:
            print(f"FAIL {spec.name}: {exc}", file=sys.stderr)
            return 1
    print(f"tier-2 CI smoke ok ({len(specs)} benchmarks)")
    return 0


def run_verify() -> int:
    script = REPO / "benchmarks" / "harness" / "verify.py"
    # Tier-0 CI gate: compile smokes only; tier-2 checksum parity runs via `bench.py --tier 2 --ci`.
    return subprocess.call(
        [
            sys.executable,
            str(script),
            "--write-csv",
            str(RESULTS / "verify.csv"),
            "--tier0-only",
        ]
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
        default=int(os.environ.get("BENCH_RUNS", "6")),
        help="timing repetitions (mean; adaptive min 6, sub-second min 20)",
    )
    parser.add_argument("--skip-verify", action="store_true")
    parser.add_argument(
        "--verify-results",
        action="store_true",
        help="verify numerical results only (no timing CSV); tier 1, 2, or 12",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=RESULTS / "latest.csv",
        help="CSV output path",
    )
    parser.add_argument(
        "--only",
        default="",
        help="comma-separated benchmark ids (subset of tier list)",
    )
    parser.add_argument(
        "--package",
        action="append",
        default=[],
        help="workspace package(s) from benchmarks/manifest.toml",
    )
    parser.add_argument(
        "--changed",
        action="store_true",
        help="scope benches to packages touched in git worktree",
    )
    args = parser.parse_args()

    only: set[str] | None = None
    if args.only.strip():
        only = {x.strip() for x in args.only.split(",") if x.strip()}
    elif args.package or args.changed:
        sys.path.insert(0, str(REPO / "benchmarks" / "harness"))
        from bench_scope import resolve_scope

        scope = resolve_scope(packages=args.package or None, changed=args.changed)
        if scope["benches"]:
            only = set(scope["benches"])
        else:
            print("bench: no benches for scope (nothing to time)", file=sys.stderr)
            return 0

    if args.sample:
        write_sample_csv(args.out)
        return 0

    if args.tier == 0 and not (args.out).exists():
        write_sample_csv(args.out)

    if args.ci and args.tier == 2:
        return run_tier2_ci_smoke(only=only)

    if args.verify_results:
        if args.tier in (1, 12):
            rc = run_verify_results(TIER1_BENCHES, label="tier-1", only=only)
            if rc != 0:
                return rc
            if args.tier == 1:
                return 0
        if args.tier in (4, 12):
            rc = run_verify_results(TIER_STDLIB_BENCHES, label="tier-stdlib", only=only)
            if rc != 0:
                return rc
            if args.tier == 4:
                return 0
        if args.tier in (2, 12):
            return run_verify_results(TIER2_BENCHES, label="tier-2", only=only)
        if args.tier == 0:
            print("verify-results: use --tier 1, 2, 4, or 12", file=sys.stderr)
            return 1
        print(f"verify-results: use --tier 1, 2, 4, or 12 (got {args.tier})", file=sys.stderr)
        return 1

    if args.tier == 0:
        rc = run_tier0()
        if rc != 0:
            return rc
        rc = run_verify()
        if rc != 0:
            return rc
        return subprocess.call([sys.executable, str(REPO / "benchmarks" / "harness" / "stability.py")])

    if args.tier == 1:
        return run_tier1_all(
            runs=args.runs, out=args.out, verify=not args.skip_verify, only=only
        )

    if args.tier == 4:
        return run_tier_stdlib_all(
            runs=args.runs, out=args.out, verify=not args.skip_verify, only=only
        )

    if args.tier == 2:
        return run_tier2_all(
            runs=args.runs, out=args.out, verify=not args.skip_verify, only=only
        )

    if args.tier == 12:
        rc = run_tier1_all(
            runs=args.runs, out=args.out, verify=not args.skip_verify, only=only
        )
        if rc != 0:
            return rc
        return run_tier2_all(
            runs=args.runs, out=args.out, verify=not args.skip_verify, only=only
        )

    if args.tier == 7:
        from bench_registry import run_registry_family_benches

        return run_registry_family_benches(
            runs=args.runs,
            out=args.out,
            verify=not args.skip_verify,
            only=only,
        )

    if args.tier == 3:
        print(
            "tier 3 is HTTP (run from li-langverse/benchmarks: run-tier5-http-bench.sh)",
            file=sys.stderr,
        )
        return 0

    if args.tier == 5:
        script = REPO / "benchmarks" / "harness" / "bench_ecosystem.py"
        return subprocess.call([sys.executable, str(script), "--runs", str(args.runs)])

    if args.tier >= 1:
        print(f"tier {args.tier} benchmarks: not implemented", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
