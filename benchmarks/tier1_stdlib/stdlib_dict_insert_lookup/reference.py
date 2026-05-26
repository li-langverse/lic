"""Normative open-addressing dict checksum for stdlib_dict_insert_lookup."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

FULL_OPS = 500_000
CAPACITY = 1 << 20
SMALL_OPS = 32


def hash_key(key: int) -> int:
    x = (key & ((1 << 64) - 1)) * 0x9E3779B97F4A7C15
    x &= (1 << 64) - 1
    x ^= x >> 33
    x = (x * 0xFF51AFD7ED558CCD) & ((1 << 64) - 1)
    x ^= x >> 33
    return int(x)


def dict_spec_sum(ops: int, *, capacity: int = CAPACITY) -> float:
    mask = capacity - 1
    table: list[tuple[int, int] | None] = [None] * capacity

    def insert(key: int, val: int) -> None:
        i = hash_key(key) & mask
        while table[i] is not None:
            k, _ = table[i]  # type: ignore[misc]
            if k == key:
                table[i] = (key, val)
                return
            i = (i + 1) & mask
        table[i] = (key, val)

    def lookup(key: int) -> int:
        i = hash_key(key) & mask
        while table[i] is not None:
            k, v = table[i]  # type: ignore[misc]
            if k == key:
                return v
            i = (i + 1) & mask
        return -1

    for k in range(ops):
        insert(k, k * 3 + 7)
    return float(sum(lookup(k) for k in range(ops)))


def format_result(value: float) -> str:
    return f"{value:.17g}"


def verify_cpp(bench_dir: Path) -> int:
    main_c = bench_dir / "cpp" / "main.c"
    core_c = bench_dir / "common" / "dict_core.c"
    bin_path = bench_dir / "_verify_bin"
    cc = subprocess.check_output(["sh", "-c", "command -v cc || command -v gcc"], text=True).strip() or "cc"
    subprocess.check_call(
        [cc, "-O3", "-march=native", str(main_c), str(core_c), "-o", str(bin_path)],
        cwd=bench_dir,
    )
    out = subprocess.check_output([str(bin_path), "--verify"], text=True).strip()
    expected = format_result(dict_spec_sum(FULL_OPS))
    if out != expected:
        print(f"FAIL: cpp {out!r} != spec {expected!r}", file=sys.stderr)
        return 1
    print(f"PASS stdlib_dict_insert_lookup cpp oracle: {out}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--verify-cpp", action="store_true")
    parser.add_argument("--small", action="store_true")
    args = parser.parse_args()
    bench_dir = Path(__file__).resolve().parent
    if args.small:
        print(format_result(dict_spec_sum(SMALL_OPS, capacity=128)))
        return 0
    if args.verify_cpp:
        return verify_cpp(bench_dir)
    print(format_result(dict_spec_sum(FULL_OPS)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
