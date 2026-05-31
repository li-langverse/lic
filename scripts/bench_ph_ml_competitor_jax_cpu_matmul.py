#!/usr/bin/env python3
"""JAX CPU matmul timing — 4×4 f32 identity (jax.numpy)."""
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

out = os.environ["PH_ML_JAX_CPU_MATMUL_OUT"]
report = report_base("jax_cpu", "ph-ml-competitor-jax-cpu-matmul", "matmul_4x4_f32")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["workload_size"] = DEFAULT_MATMUL_N
report["device"] = "cpu"
report["workload"] = "matmul_4x4_f32"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    import jax
    import jax.numpy as jnp
except ImportError:
    report["note"] = "jax not installed"
    write_report()
    sys.exit(0)

report["framework_version"] = jax.__version__
n = DEFAULT_MATMUL_N
a = jnp.eye(n, dtype=jnp.float32)
b = jnp.eye(n, dtype=jnp.float32)
run_fn = jax.jit(lambda x, y: x @ y)
_ = run_fn(a, b).block_until_ready()


def run():
    return run_fn(a, b)


def sanity(out) -> bool:
    out.block_until_ready()
    return float(out[0, 0]) >= 0.5


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
