#!/usr/bin/env python3
"""Add --verify branch to shared-kernel li/main.li drivers (one-time maintenance)."""
from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]

TEMPLATE = '''
extern proc {kernel}()
  requires true
  ensures true

extern proc {checksum}() -> float
  requires true
  ensures true

proc main(args: [string]) raises IO -> int
  requires true
  ensures result == 0
  decreases 0
=
  if len(args) > 0
    if args[0] == "--verify"
      echo {checksum}()
      return 0
  {kernel}()
  return 0
'''

# Map bench rel_dir -> (kernel, checksum) from common/*.h
SPECS = [
    ("tier1_micro/matmul_naive", "li_matmul_naive_kernel", "li_matmul_naive_checksum"),
    ("tier1_micro/matmul_blocked", "li_matmul_blocked_kernel", "li_matmul_blocked_checksum"),
    (
        "tier1_micro/matmul_blocked_n128",
        "li_matmul_blocked_kernel",
        "li_matmul_blocked_checksum",
    ),
    (
        "tier1_micro/matmul_blocked_n1024",
        "li_matmul_blocked_kernel",
        "li_matmul_blocked_checksum",
    ),
    ("tier1_micro/matmul_naive_n128", "li_matmul_naive_kernel", "li_matmul_naive_checksum"),
    ("tier1_micro/reduce_sum", "li_reduce_sum_kernel", "li_reduce_sum_checksum"),
]


def main() -> int:
    for rel, kernel, checksum in SPECS:
        path = REPO / "benchmarks" / rel / "li" / "main.li"
        if not path.parent.exists():
            continue
        text = TEMPLATE.format(kernel=kernel, checksum=checksum).strip() + "\n"
        path.write_text(text)
        print(f"patched {path.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
