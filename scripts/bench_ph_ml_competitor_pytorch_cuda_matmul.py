#!/usr/bin/env python3
"""PyTorch CUDA matmul timing — optional when GPU available."""
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
    report_base,
)

out = os.environ["PH_ML_PYTORCH_CUDA_MATMUL_OUT"]
report = report_base("pytorch_cuda", "ph-ml-competitor-pytorch-cuda-matmul", "matmul_4x4_f32")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["workload_size"] = DEFAULT_MATMUL_N
report["device"] = "cuda"


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
if not torch.cuda.is_available():
    report["note"] = "CUDA not available (CI CPU-only OK)"
    write_report()
    sys.exit(0)

n = DEFAULT_MATMUL_N
a = torch.eye(n, dtype=torch.float32, device="cuda")
b = torch.eye(n, dtype=torch.float32, device="cuda")
torch.cuda.synchronize()


def run():
    return a @ b


def sanity(out) -> bool:
    torch.cuda.synchronize()
    return float(out[0, 0].item()) >= 0.5


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
