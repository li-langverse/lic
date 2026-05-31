#!/usr/bin/env python3
"""NumPy manual MLP forward — 2-2-1 f32 matching ml_mlp_forward.li smoke."""
import json
import os
import sys
import time
from pathlib import Path

from ph_ml_competitor_workloads import (
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    MLP_BATCH,
    MLP_HIDDEN,
    MLP_IN_DIM,
    MLP_OUT_DIM,
    bench_loop,
    report_base,
)

out = os.environ["PH_ML_NUMPY_MLP_OUT"]
report = report_base("python_numpy", "ph-ml-competitor-numpy-mlp", "mlp_forward_2_2_1_f32")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
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
x = np.array([[1.0, 1.0]], dtype=np.float32)
w1 = np.array([[1.0, 0.0], [0.0, 1.0]], dtype=np.float32)
w2 = np.array([[1.0], [1.0]], dtype=np.float32)


def forward():
    h = x @ w1.T
    h = np.maximum(h, 0.0)
    return h @ w2


def sanity(y) -> bool:
    return y.shape == (MLP_BATCH, MLP_OUT_DIM) and float(y[0, 0]) > 0.0


cpu_sec, err = bench_loop(DEFAULT_RUNS, DEFAULT_WARMUP, forward, sanity)
if err:
    report["note"] = err
    write_report()
    sys.exit(0)

report["cpu_sec"] = cpu_sec
report["executed"] = True
report["validity_gate_pass"] = True
report["validity_ratio"] = 1.0
report["workload"] = f"mlp_forward_{MLP_IN_DIM}_{MLP_HIDDEN}_{MLP_OUT_DIM}_f32"
write_report()
