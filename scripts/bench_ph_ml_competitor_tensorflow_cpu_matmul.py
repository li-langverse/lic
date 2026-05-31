#!/usr/bin/env python3
"""TensorFlow CPU matmul timing — optional (heavy dep; skip if not installed)."""
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

out = os.environ["PH_ML_TENSORFLOW_CPU_MATMUL_OUT"]
report = report_base("tensorflow_cpu", "ph-ml-competitor-tensorflow-cpu-matmul", "matmul_4x4_f32")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["workload_size"] = DEFAULT_MATMUL_N
report["device"] = "cpu"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


try:
    import tensorflow as tf
except ImportError:
    report["note"] = "tensorflow not installed (optional Wave 8 dep)"
    write_report()
    sys.exit(0)

report["framework_version"] = tf.__version__
tf.config.set_visible_devices([], "GPU")
n = DEFAULT_MATMUL_N
a = tf.eye(n, dtype=tf.float32)
b = tf.eye(n, dtype=tf.float32)


def run():
    return tf.matmul(a, b)


def sanity(out) -> bool:
    return float(out[0, 0].numpy()) >= 0.5


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
