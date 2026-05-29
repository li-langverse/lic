#!/usr/bin/env python3
"""NumPy oracle for 784→256→10 MLP forward (matches ml.nn nn_lut17 weight base)."""

from __future__ import annotations

import sys


def lut17(k: int) -> float:
    table = [i * 0.01 for i in range(17)]
    return table[k % 17]


def mod17(v: int) -> int:
    return v % 17


def mod37(v: int) -> int:
    return v % 37


def w1_base(i: int, j: int) -> float:
    ii = mod17(i)
    jj = mod17(j)
    mix = ii * 31 + jj * 17
    rem = mix % 113
    rk = rem % 17
    return 0.001 * lut17(rk) - 0.05


def w2_base(i: int, j: int) -> float:
    ii = mod17(i)
    jj = mod17(j)
    mix = ii * 13 + jj * 7
    rem = mod37(mix)
    rk = rem % 17
    return 0.01 * lut17(rk) - 0.18


def mlp_forward(inp: list[float]) -> list[float]:
    w1_scale = [1.0] * 784
    b1 = [0.0] * 256
    w2 = [[w2_base(i, j) for j in range(10)] for i in range(256)]
    b2 = [0.0] * 10
    h = []
    for j in range(256):
        s = b1[j]
        for i in range(784):
            s += inp[i] * w1_base(i, j) * w1_scale[i]
        h.append(max(0.0, s))
    out = []
    for j in range(10):
        s = b2[j]
        for i in range(256):
            s += h[i] * w2[i][j]
        out.append(s)
    return out


def main() -> int:
    inp = []
    for i in range(784):
        rk = i % 19
        if rk >= 17:
            rk = rk - 17
        inp.append(0.002 * lut17(rk))
    logits = mlp_forward(inp)
    checksum = sum(logits)
    print(f"{checksum:.12f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
