#!/usr/bin/env python3
"""PyTorch CPU baseline harness for tier-3 ML benches (WP-BENCH-ML-04).

Honest: prints N/A when torch is unavailable — no fake timing columns.
"""

from __future__ import annotations

import sys


def main() -> int:
    try:
        import torch
    except ImportError:
        print("N/A")
        print("reason=torch_not_installed", file=sys.stderr)
        return 0

    torch.set_num_threads(1)
    inp = torch.randn(1, 784)
    net = torch.nn.Sequential(
        torch.nn.Linear(784, 256),
        torch.nn.ReLU(),
        torch.nn.Linear(256, 10),
    )
    net.eval()
    with torch.no_grad():
        out = net(inp)
    checksum = float(out.sum().item())
    print(f"{checksum:.12f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
