"""Normative binary search checksum for stdlib_binary_search."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

FULL_N = 1_000_000
FULL_QUERIES = 200_000


def bsearch_spec_sum(n: int, queries: int) -> float:
    sorted_vals = [i * 3 + (i % 7) for i in range(n)]
    acc = 0.0
    for q in range(queries):
        target = (q * 7919) % n
        lo, hi = 0, n - 1
        found = -1
        while lo <= hi:
            mid = lo + (hi - lo) // 2
            v = sorted_vals[mid]
            if v == target:
                found = v
                break
            if v < target:
                lo = mid + 1
            else:
                hi = mid - 1
        acc += float(found)
    return acc


def format_result(value: float) -> str:
    return f"{value:.17g}"


def verify_cpp(bench_dir: Path) -> int:
    main_c = bench_dir / "cpp" / "main.c"
    core_c = bench_dir / "common" / "search_core.c"
    bin_path = bench_dir / "_verify_bin"
    cc = subprocess.check_output(["sh", "-c", "command -v cc || command -v gcc"], text=True).strip() or "cc"
    subprocess.check_call(
        [cc, "-O3", "-march=native", str(main_c), str(core_c), "-o", str(bin_path)],
        cwd=bench_dir,
    )
    out = subprocess.check_output([str(bin_path), "--verify"], text=True).strip()
    expected = format_result(bsearch_spec_sum(FULL_N, FULL_QUERIES))
    if out != expected:
        print(f"FAIL: cpp {out!r} != spec {expected!r}", file=sys.stderr)
        return 1
    print(f"PASS stdlib_binary_search cpp oracle: {out}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--verify-cpp", action="store_true")
    args = parser.parse_args()
    bench_dir = Path(__file__).resolve().parent
    if args.verify_cpp:
        return verify_cpp(bench_dir)
    print(format_result(bsearch_spec_sum(FULL_N, FULL_QUERIES)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
