"""Normative int64 sort checksum for stdlib_sort_int (WP0 oracle).

Matches ``sort_core.c``: xorshift fill, ``qsort`` ascending, sum as float64.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

FULL_N = 1_000_000
SMALL_N = 64


def xorshift64(state: int) -> tuple[int, int]:
    x = state & ((1 << 64) - 1)
    x ^= x >> 12
    x ^= (x << 25) & ((1 << 64) - 1)
    x ^= x >> 27
    x &= (1 << 64) - 1
    return x, (x * 0x2545F4914F6CDD1D) & ((1 << 64) - 1)


def sort_spec_sum(n: int) -> float:
    rng = 0x9E3779B97F4A7C15
    buf = []
    for _ in range(n):
        rng, val = xorshift64(rng)
        buf.append(int(val % 1_000_003))
    buf.sort()
    return float(sum(buf))


def format_result(value: float) -> str:
    return f"{value:.17g}"


def verify_cpp(bench_dir: Path) -> int:
    main_c = bench_dir / "cpp" / "main.c"
    core_c = bench_dir / "common" / "sort_core.c"
    bin_path = bench_dir / "_verify_bin"
    cc = subprocess.check_output(["sh", "-c", "command -v cc || command -v gcc"], text=True).strip() or "cc"
    subprocess.check_call(
        [cc, "-O3", "-march=native", str(main_c), str(core_c), "-o", str(bin_path)],
        cwd=bench_dir,
    )
    out = subprocess.check_output([str(bin_path), "--verify"], text=True).strip()
    expected = format_result(sort_spec_sum(FULL_N))
    if out != expected:
        print(f"FAIL: cpp {out!r} != spec {expected!r}", file=sys.stderr)
        return 1
    print(f"PASS stdlib_sort_int cpp oracle: {out}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--verify-cpp", action="store_true")
    parser.add_argument("--small", action="store_true", help="print small-N checksum")
    args = parser.parse_args()
    bench_dir = Path(__file__).resolve().parent
    if args.small:
        print(format_result(sort_spec_sum(SMALL_N)))
        return 0
    if args.verify_cpp:
        return verify_cpp(bench_dir)
    print(format_result(sort_spec_sum(FULL_N)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
