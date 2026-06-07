#!/usr/bin/env python3
"""PyTorch CPU matmul timing — 4×4 f32 identity (matches NumPy pilot)."""
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

out = os.environ["PH_ML_PYTORCH_CPU_MATMUL_OUT"]
report = report_base("pytorch_cpu", "ph-ml-competitor-pytorch-cpu-matmul", "matmul_4x4_f32")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["workload_size"] = DEFAULT_MATMUL_N
report["device"] = "cpu"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    import torch
except ImportError:
    report["note"] = "torch not installed"
    write_report()
    sys.exit(0)

report["framework_version"] = torch.__version__
torch.set_num_threads(max(1, os.cpu_count() or 1))
n = DEFAULT_MATMUL_N
run, sanity = make_identity_matmul(
    n,
    lambda: torch.eye(n, dtype=torch.float32),
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
