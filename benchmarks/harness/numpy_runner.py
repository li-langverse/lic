#!/usr/bin/env python3
"""Run a tier-1/2 benchmark kernel in NumPy (for bench.py timing)."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

HARNESS = Path(__file__).resolve().parent
if str(HARNESS) not in sys.path:
    sys.path.insert(0, str(HARNESS))

from numpy_kernels import KERNELS  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--benchmark", required=True)
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    name = args.benchmark
    if name not in KERNELS:
        print(f"unknown benchmark for numpy: {name}", file=sys.stderr)
        return 2
    checksum = KERNELS[name]()
    if args.verify:
        print(f"{checksum:.17g}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
