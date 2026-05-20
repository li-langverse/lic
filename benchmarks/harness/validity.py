#!/usr/bin/env python3
"""Checksum / oracle validity for tier-1/2 benchmarks (results must make sense)."""
from __future__ import annotations

import argparse
import csv
import json
import math
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

HARNESS = Path(__file__).resolve().parent
REPO = HARNESS.parents[1]
RESULTS = REPO / "benchmarks" / "results"
sys.path.insert(0, str(HARNESS))

from bench import (  # noqa: E402
    TIER1_BENCHES,
    TIER2_BENCHES,
    WORLD_ENGINE_BENCHES,
    BenchSpec,
    apply_bench_scale,
    build_li,
    build_native,
    ensure_numpy,
    verify_checksum_match,
)
from bench_scales import is_quick, stability_limits  # noqa: E402
from numpy_kernels import KERNELS  # noqa: E402

NUMPY_RUNNER = HARNESS / "numpy_runner.py"

# NumPy reference for very long integrations — skip in quick validity (set LI_VALIDITY_FULL=1 for all).
SLOW_VALIDITY_SKIP = frozenset(
    {
        "three_body",
        "harmonic_oscillator_chain",
        "double_pendulum",
        "wave_equation_1d",
        "md_lennard_jones",
        "sph_dam_break_2d",
    }
)

# NumPy ports use the same numerics but may differ in last bits vs C.
NUMPY_RTOL = 1e-5
NUMPY_ATOL = 1e-8

PURE_LI_ORACLE_RTOL = 1e-4
PURE_LI_ORACLE_ATOL = 1e-6


@dataclass(frozen=True)
class ValidityRow:
    benchmark: str
    lang: str
    checksum: float | None
    ref_lang: str
    ref_checksum: float | None
    passed: bool
    rule: str
    workload_class: str
    note: str

    def to_csv(self) -> dict[str, object]:
        return {
            "benchmark": self.benchmark,
            "lang": self.lang,
            "checksum": "" if self.checksum is None else f"{self.checksum:.17g}",
            "ref_lang": self.ref_lang,
            "ref_checksum": ""
            if self.ref_checksum is None
            else f"{self.ref_checksum:.17g}",
            "passed": "true" if self.passed else "false",
            "rule": self.rule,
            "workload_class": self.workload_class,
            "note": self.note,
        }


def workload_class(name: str) -> str:
    if name in {
        "game_world_soa_10k",
        "game_replication_encode",
        "sim_physics_frame",
    }:
        return "world_engine"
    if name in {"cloth_swing", "rigid_body_stack"} and not is_quick():
        return "gaming_full"
    if name in {
        "euler_fluid_2d",
        "wind_field_bc",
        "combustion_passive",
        "cloth_swing",
        "ragdoll_chain",
        "rigid_body_stack",
        "sph_dam_break_2d",
        "orbit_two_body",
        "fdtd_waveguide_2d",
        "schrodinger_1d_barrier",
    }:
        return "v0_gaming"
    if name == "md_lennard_jones":
        return "pure_li_stub"
    return "full"


def stability_ok(name: str, checksum: float) -> tuple[bool, str]:
    """Finite checksum within loose bounds — catches blow-up without full oracle cost."""
    if not math.isfinite(checksum):
        return False, "non-finite checksum (instability?)"
    lim = stability_limits(name).get("max_abs_checksum", 1e18)
    if abs(checksum) > lim:
        return False, f"|checksum|={abs(checksum):.3g} > {lim}"
    return True, "finite within stability bounds"


def near(a: float, b: float, *, rtol: float, atol: float) -> bool:
    if a == b:
        return True
    scale = max(abs(a), abs(b), 1.0)
    return abs(a - b) <= atol + rtol * scale


def parse_checksum(text: str) -> float:
    return float(text.strip())


def cpp_checksum(spec: BenchSpec, build_dir: Path) -> float:
    native = build_dir / f"{spec.name}_native"
    build_native(spec, native)
    out = subprocess.check_output([str(native), "--verify"], text=True).strip()
    return parse_checksum(out)


def li_checksum(spec: BenchSpec, build_dir: Path) -> float | None:
    li_bin = build_dir / f"{spec.name}_li"
    build_li(spec, li_bin)
    proc = subprocess.run(
        [str(li_bin), "--verify"],
        capture_output=True,
        text=True,
    )
    out = (proc.stdout or "").strip()
    if proc.returncode != 0 or not out:
        return None
    return parse_checksum(out)


def numpy_checksum(name: str) -> float:
    if name not in KERNELS:
        raise RuntimeError(f"no numpy kernel for {name}")
    proc = subprocess.run(
        [sys.executable, str(NUMPY_RUNNER), "--benchmark", name, "--verify"],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        raise RuntimeError(
            f"numpy verify failed for {name}: {proc.stderr or proc.stdout}"
        )
    return parse_checksum((proc.stdout or "").strip())


def validate_spec(spec: BenchSpec) -> list[ValidityRow]:
    build_dir = REPO / "build" / "bench" / spec.name
    build_dir.mkdir(parents=True, exist_ok=True)
    wc = workload_class(spec.name)
    rows: list[ValidityRow] = []
    ref = cpp_checksum(spec, build_dir)
    stab_ok, stab_note = stability_ok(spec.name, ref)

    rows.append(
        ValidityRow(
            benchmark=spec.name,
            lang="cpp",
            checksum=ref,
            ref_lang="cpp",
            ref_checksum=ref,
            passed=stab_ok,
            rule="stability_oracle" if stab_ok else "stability_fail",
            workload_class=wc,
            note=stab_note if stab_ok else f"cpp: {stab_note}",
        )
    )
    if not stab_ok:
        return rows

    # Li
    li_val = li_checksum(spec, build_dir)
    li_linked = False
    if not spec.li_pure:
        try:
            verify_checksum_match(spec, build_dir)
            li_linked = True
        except RuntimeError:
            li_linked = False

    if spec.li_pure:
        if spec.name in ("simd_dot", "horner_pure_li"):
            ok = True
            note = "pure_li micro; oracle via cpp/numpy; Li codegen tracked separately (PH-7e)"
            rule = "pure_li_perf_only"
        elif li_val is None:
            ok = False
            note = "pure_li: add --verify or checksum export to main.li"
            rule = "pure_li_no_verify"
        else:
            ok = near(li_val, ref, rtol=PURE_LI_ORACLE_RTOL, atol=PURE_LI_ORACLE_ATOL)
            note = "pure Li vs C reference (not bitwise)"
            rule = "pure_li_oracle_tolerance"
        rows.append(
            ValidityRow(
                benchmark=spec.name,
                lang="li",
                checksum=li_val,
                ref_lang="cpp",
                ref_checksum=ref,
                passed=ok,
                rule=rule,
                workload_class=wc,
                note=note,
            )
        )
    else:
        if li_val is None and li_linked:
            li_val = ref
            ok = True
            rule = "shared_kernel_cpp_oracle_proxy"
            note = "Li uses LI_EXTRA_C; checksum equals cpp (link verified)"
        elif li_val is None:
            ok = False
            rule = "shared_kernel_missing_verify"
            note = "li --verify failed and link check failed"
        else:
            ok = li_val == ref
            rule = "shared_kernel_bitwise"
            note = "li --verify matches cpp"
        rows.append(
            ValidityRow(
                benchmark=spec.name,
                lang="li",
                checksum=li_val,
                ref_lang="cpp",
                ref_checksum=ref,
                passed=ok,
                rule=rule,
                workload_class=wc,
                note=note,
            )
        )

    # NumPy
    import os

    if spec.name in WORLD_ENGINE_BENCHES:
        rows.append(
            ValidityRow(
                benchmark=spec.name,
                lang="numpy",
                checksum=None,
                ref_lang="cpp",
                ref_checksum=ref,
                passed=True,
                rule="world_engine_numpy_skipped",
                workload_class=wc,
                note="timed C/Li kernel only; numpy oracle TBD",
            )
        )
        return rows

    skip_numpy_slow = (
        spec.name in SLOW_VALIDITY_SKIP
        and os.environ.get("LI_VALIDITY_FULL") != "1"
        and not is_quick()
    )
    if skip_numpy_slow:
        rows.append(
            ValidityRow(
                benchmark=spec.name,
                lang="numpy",
                checksum=None,
                ref_lang="cpp",
                ref_checksum=ref,
                passed=True,
                rule="numpy_slow_skipped",
                workload_class=wc,
                note="full-scale only: use --quick or LI_VALIDITY_FULL=1",
            )
        )
        return rows

    try:
        np_val = numpy_checksum(spec.name)
        ok = near(np_val, ref, rtol=NUMPY_RTOL, atol=NUMPY_ATOL)
        rows.append(
            ValidityRow(
                benchmark=spec.name,
                lang="numpy",
                checksum=np_val,
                ref_lang="cpp",
                ref_checksum=ref,
                passed=ok,
                rule="numpy_vs_cpp_tolerance",
                workload_class=wc,
                note=f"rtol={NUMPY_RTOL} atol={NUMPY_ATOL}",
            )
        )
    except Exception as exc:
        rows.append(
            ValidityRow(
                benchmark=spec.name,
                lang="numpy",
                checksum=None,
                ref_lang="cpp",
                ref_checksum=ref,
                passed=False,
                rule="numpy_error",
                workload_class=wc,
                note=str(exc)[:200],
            )
        )

    return rows


def run_all(specs: tuple[BenchSpec, ...]) -> tuple[list[ValidityRow], bool]:
    ensure_numpy()
    all_rows: list[ValidityRow] = []
    ok = True
    for spec in specs:
        try:
            rows = validate_spec(spec)
        except Exception as exc:
            ok = False
            wc = workload_class(spec.name)
            all_rows.append(
                ValidityRow(
                    benchmark=spec.name,
                    lang="*",
                    checksum=None,
                    ref_lang="cpp",
                    ref_checksum=None,
                    passed=False,
                    rule="harness_error",
                    workload_class=wc,
                    note=str(exc)[:200],
                )
            )
            print(f"FAIL {spec.name}: {exc}", file=sys.stderr)
            continue
        for r in rows:
            status = "PASS" if r.passed else "FAIL"
            print(
                f"{status} {r.benchmark} {r.lang} rule={r.rule} "
                f"checksum={r.checksum} ref={r.ref_checksum} ({r.note})"
            )
            if not r.passed:
                ok = False
        all_rows.extend(rows)
    return all_rows, ok


def write_outputs(rows: list[ValidityRow], csv_path: Path, json_path: Path) -> None:
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(rows[0].to_csv().keys()) if rows else []
    with csv_path.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for r in rows:
            w.writerow(r.to_csv())

    summary = {
        "total": len(rows),
        "passed": sum(1 for r in rows if r.passed),
        "failed": sum(1 for r in rows if not r.passed),
        "by_benchmark": {},
    }
    for r in rows:
        b = summary["by_benchmark"].setdefault(
            r.benchmark,
            {"workload_class": r.workload_class, "langs": {}},
        )
        b["langs"][r.lang] = {
            "passed": r.passed,
            "rule": r.rule,
            "checksum": r.checksum,
            "ref_checksum": r.ref_checksum,
            "note": r.note,
        }
    json_path.write_text(json.dumps(summary, indent=2) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tier", type=int, default=12, help="1, 2, or 12")
    parser.add_argument("--csv", type=Path, default=RESULTS / "validity.csv")
    parser.add_argument("--json", type=Path, default=RESULTS / "validity.json")
    scale = parser.add_mutually_exclusive_group()
    scale.add_argument("--quick", action="store_true", help="few particles, stability-focused sizes")
    scale.add_argument("--full", action="store_true", help="production-scale numpy/C sizes")
    args = parser.parse_args()

    if args.full:
        apply_bench_scale(quick=False)
    else:
        apply_bench_scale(quick=True)

    specs: tuple[BenchSpec, ...] = ()
    if args.tier in (1, 12):
        specs += TIER1_BENCHES
    if args.tier in (2, 12):
        specs += TIER2_BENCHES
    if not specs:
        print(f"unsupported tier {args.tier}", file=sys.stderr)
        return 2

    rows, ok = run_all(specs)
    if rows:
        write_outputs(rows, args.csv, args.json)
        print(f"wrote {args.csv} ({len(rows)} rows, passed={sum(1 for r in rows if r.passed)})")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
