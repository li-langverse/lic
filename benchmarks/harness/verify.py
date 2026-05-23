#!/usr/bin/env python3
"""Correctness gate for benchmark sources (Tier 0 compile + Tier 2 physics smokes)."""

from __future__ import annotations

import argparse
import csv
import os
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
LIC = REPO / "build" / "compiler" / "lic" / "lic"
RESULTS = REPO / "benchmarks" / "results"

# Wave B tier-2 verify: Lennard-Jones MD + one PDE (heat 2D).
# Wave D tier-2 verify: rigid_body_stack (gaming_rigid proxy; physics.rigid floor+gravity).
#   Not UE5/Bullet parity — checksum vs native rigid_stack_core.c only.
TIER2_SMOKE: tuple[str, ...] = (
    "md_lennard_jones",
    "heat_equation_2d",
    "rigid_body_stack",
)


def lic_build(path: Path) -> bool:
    if not LIC.is_file():
        print(f"lic missing at {LIC}", file=sys.stderr)
        return False
    env = {**os.environ, "LIC": str(LIC)}
    # Tier-0 physics smokes track open VC in li-tests manifest (`verify_open_ok`).
    cmd = [str(LIC), "build", "--allow-open-vc", "--no-lean-verify", str(path), "-o", "/dev/null"]
    proc = subprocess.run(
        cmd,
        cwd=REPO,
        env=env,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        print(proc.stderr or proc.stdout, file=sys.stderr)
    return proc.returncode == 0


def tier0_sources() -> list[Path]:
    root = REPO / "li-tests" / "benchmarks" / "tier0_correctness"
    return sorted(root.glob("*.li"))


def tier2_smoke_verify() -> list[tuple[str, bool, str]]:
    """Build native+Li checksum parity for md_lennard_jones, heat_equation_2d, rigid_body_stack."""
    if not LIC.is_file():
        print(f"lic missing at {LIC}", file=sys.stderr)
        return [(name, False, "lic missing") for name in TIER2_SMOKE]

    os.environ.setdefault("CC", "clang-22")
    os.environ.setdefault("CXX", "clang++-22")

    sys.path.insert(0, str(REPO / "benchmarks" / "harness"))
    from bench import TIER2_BENCHES, verify_benchmark_results, verify_md_refs

    out: list[tuple[str, bool, str]] = []
    for name in TIER2_SMOKE:
        spec = next(b for b in TIER2_BENCHES if b.name == name)
        build_dir = REPO / "build" / "bench" / spec.name
        build_dir.mkdir(parents=True, exist_ok=True)
        try:
            if name == "md_lennard_jones":
                verify_md_refs()
            verify_benchmark_results(spec, build_dir)
            out.append((name, True, "checksum ok"))
            print(f"PASS verify tier2 {name}")
        except Exception as exc:
            out.append((name, False, str(exc)))
            print(f"FAIL verify tier2 {name}: {exc}", file=sys.stderr)
    return out


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write-csv", type=Path, default=RESULTS / "verify.csv")
    parser.add_argument(
        "--tier0-only",
        action="store_true",
        help="skip tier-2 physics smokes (md_lennard_jones, heat_equation_2d, rigid_body_stack)",
    )
    args = parser.parse_args()

    rows: list[list[object]] = []
    ok = True
    for src in tier0_sources():
        passed = lic_build(src)
        ok = ok and passed
        rows.append(
            [
                src.stem,
                "li",
                "verify",
                1,
                "invariant",
                1 if passed else 0,
                "bool",
                "",
                "",
                "",
                passed,
            ]
        )
        status = "PASS" if passed else "FAIL"
        print(f"{status} verify {src.relative_to(REPO)}")

    if not args.tier0_only:
        for name, passed, detail in tier2_smoke_verify():
            ok = ok and passed
            rows.append(
                [
                    name,
                    "li",
                    "verify",
                    1,
                    "checksum",
                    1 if passed else 0,
                    "bool",
                    "",
                    "",
                    detail,
                    passed,
                ]
            )

    args.write_csv.parent.mkdir(parents=True, exist_ok=True)
    with args.write_csv.open("w", newline="") as f:
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
                "passed",
            ]
        )
        w.writerows(rows)

    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
