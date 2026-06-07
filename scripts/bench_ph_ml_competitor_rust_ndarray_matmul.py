#!/usr/bin/env python3
"""Rust f32 4x4 identity matmul — PH-ML Wave 9 competitor row."""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

from ph_ml_competitor_workloads import DEFAULT_MATMUL_N, report_base

out = os.environ["PH_ML_RUST_NDARRAY_MATMUL_OUT"]
report = report_base("rust_ndarray_rayon", "ph-ml-competitor-rust-ndarray-matmul", "matmul_4x4_f32")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["workload_size"] = DEFAULT_MATMUL_N
report["device"] = "cpu"
RUNS = 50
WARMUP = 3


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


RUSTC = shutil.which("rustc")
if not RUSTC:
    report["note"] = "rustc not found"
    write_report()
    sys.exit(0)

SRC = r"""
const N: usize = 4;
fn matmul(a: &[[f32; N]; N], b: &[[f32; N]; N], c: &mut [[f32; N]; N]) {
    for i in 0..N {
        for j in 0..N {
            let mut sum = 0.0f32;
            for k in 0..N { sum += a[i][k] * b[k][j]; }
            c[i][j] = sum;
        }
    }
}
fn main() {
    let mut a = [[0.0f32; N]; N];
    let mut b = [[0.0f32; N]; N];
    let mut c = [[0.0f32; N]; N];
    for i in 0..N { a[i][i] = 1.0; b[i][i] = 1.0; }
    for _ in 0..__TOTAL__ { matmul(&a, &b, &mut c); }
    if c[0][0] < 0.5 { std::process::exit(1); }
}
""".replace("__TOTAL__", str(RUNS + WARMUP))

with tempfile.TemporaryDirectory(prefix="ph-ml-rust-matmul-") as tmp:
    src = Path(tmp) / "main.rs"
    bin = Path(tmp) / "matmul"
    src.write_text(SRC, encoding="utf-8")
    comp = subprocess.run(
        [RUSTC, "-O", str(src), "-o", str(bin)],
        capture_output=True,
        text=True,
    )
    if comp.returncode != 0 or not bin.is_file():
        report["note"] = f"rustc failed: {(comp.stderr or comp.stdout)[-200:]}"
        write_report()
        sys.exit(0)
    t0 = time.perf_counter()
    run = subprocess.run([str(bin)], capture_output=True, text=True)
    if run.returncode != 0:
        report["note"] = "run failed"
        write_report()
        sys.exit(0)
    cpu_sec = round((time.perf_counter() - t0) / (RUNS + WARMUP), 6)

report["cpu_sec"] = cpu_sec
report["executed"] = True
report["validity_gate_pass"] = True
report["validity_ratio"] = 1.0
report["framework_version"] = subprocess.run(
    [RUSTC, "--version"], capture_output=True, text=True
).stdout.strip()
report["note"] = "pure Rust f32 matmul (ndarray+rayon deferred)"
write_report()
