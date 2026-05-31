#!/usr/bin/env python3
"""Honest NumPy BLAS matmul timing for PH-ML competitive row (4×4 f32 pilot)."""
import json
import os
import sys
import time
from pathlib import Path

from ph_ml_competitor_workloads import (
    DEFAULT_MATMUL_N,
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    bench_loop,
    make_identity_matmul,
    report_base,
)

out = os.environ["PH_ML_NUMPY_OUT"]
report = report_base("python_numpy", "ph-ml-competitor-numpy-matmul", "matmul_4x4_f32")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["workload_size"] = DEFAULT_MATMUL_N
report["device"] = "cpu"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    import numpy as np
except ImportError:
    report["note"] = "numpy not installed"
    write_report()
    sys.exit(0)

report["framework_version"] = np.__version__
n = DEFAULT_MATMUL_N
run, sanity = make_identity_matmul(
    n,
    lambda: np.eye(n, dtype=np.float32),
    lambda a, b: a @ b,
)
cpu_sec, err = bench_loop(DEFAULT_RUNS, DEFAULT_WARMUP, run, sanity)
if err:
    report["note"] = err
    write_report()
    sys.exit(0)

report["cpu_sec"] = cpu_sec
report["executed"] = True
report["validity_gate_pass"] = True
report["validity_ratio"] = 1.0
write_report()
