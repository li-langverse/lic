"""Shared PH-ML competitive workloads — sizes Li can run today (4×4, 16×16 matmul; 2-2-1 MLP)."""
from __future__ import annotations

import os
import time
from typing import Any, Callable

DEFAULT_MATMUL_N = int(os.environ.get("PH_ML_MATMUL_N", "4"))
MATMUL_SIZES = (4, 16)
DEFAULT_RUNS = 50
DEFAULT_WARMUP = 3

MLP_IN_DIM = 2
MLP_HIDDEN = 2
MLP_OUT_DIM = 1
MLP_BATCH = 1


def report_base(competitor_id: str, suite: str, workload: str) -> dict[str, Any]:
    return {
        "competitor_id": competitor_id,
        "suite": suite,
        "workload": workload,
        "executed": False,
        "cpu_sec": None,
        "validity_gate_pass": False,
        "validity_ratio": 0.0,
        "framework_version": None,
        "device": None,
        "workload_size": None,
        "note": None,
    }


def bench_loop(
    runs: int,
    warmup: int,
    fn: Callable[[], Any],
    sanity: Callable[[Any], bool],
) -> tuple[float | None, str | None]:
    for _ in range(warmup):
        out = fn()
        if not sanity(out):
            return None, "warmup sanity failed"
    t0 = time.perf_counter()
    for _ in range(runs):
        out = fn()
        if not sanity(out):
            return None, "mid-run sanity failed"
    return round((time.perf_counter() - t0) / runs, 6), None


def make_identity_matmul(n: int, eye_factory: Callable[[], Any], matmul: Callable[[Any, Any], Any]):
    a = eye_factory()
    b = eye_factory()

    def run():
        return matmul(a, b)

    def sanity(out) -> bool:
        try:
            v = out[0, 0]
        except (TypeError, IndexError, KeyError):
            try:
                v = out[0][0]
            except (TypeError, IndexError, KeyError):
                return False
        return float(v) >= 0.5

    return run, sanity
