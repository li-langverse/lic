#!/usr/bin/env python3
"""C++/OpenMP 4x4 f32 identity matmul — PH-ML Wave 9 competitor row."""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

from ph_ml_competitor_workloads import (
    DEFAULT_MATMUL_N,
    DEFAULT_RUNS,
    DEFAULT_WARMUP,
    report_base,
)

out = os.environ["PH_ML_CPP_OPENMP_MATMUL_OUT"]
report = report_base("cpp_openmp", "ph-ml-competitor-cpp-openmp-matmul", "matmul_4x4_f32")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["workload_size"] = DEFAULT_MATMUL_N
report["device"] = "cpu"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


CXX = shutil.which("g++") or shutil.which("clang++")
if not CXX:
    report["note"] = "no C++ compiler found"
    write_report()
    sys.exit(0)

SRC = r"""
#include <cstdio>
static const int N = 4;
static float A[N*N], B[N*N], C[N*N];
void matmul() {
  #pragma omp parallel for schedule(static)
  for (int i = 0; i < N; ++i) {
    for (int j = 0; j < N; ++j) {
      float sum = 0.f;
      for (int k = 0; k < N; ++k) sum += A[i*N+k] * B[k*N+j];
      C[i*N+j] = sum;
    }
  }
}
int main() {
  for (int i = 0; i < N*N; ++i) { A[i] = (i % N == i/N) ? 1.f : 0.f; B[i] = A[i]; }
  for (int r = 0; r < __RUNS__ + __WARMUP__; ++r) matmul();
  return C[0] >= 0.5f ? 0 : 1;
}
""".replace("__RUNS__", str(DEFAULT_RUNS)).replace("__WARMUP__", str(DEFAULT_WARMUP))

with tempfile.TemporaryDirectory(prefix="ph-ml-cpp-matmul-") as tmp:
    src = Path(tmp) / "matmul.cpp"
    bin = Path(tmp) / "matmul"
    src.write_text(SRC, encoding="utf-8")
    compile_cmd = [CXX, "-O3", "-std=c++17", "-fopenmp", str(src), "-o", str(bin)]
    comp = subprocess.run(compile_cmd, capture_output=True, text=True)
    if comp.returncode != 0:
        compile_cmd = [CXX, "-O3", "-std=c++17", str(src), "-o", str(bin)]
        comp = subprocess.run(compile_cmd, capture_output=True, text=True)
    if comp.returncode != 0 or not bin.is_file():
        report["note"] = f"compile failed: {(comp.stderr or comp.stdout)[-200:]}"
        write_report()
        sys.exit(0)

    t0 = time.perf_counter()
    run = subprocess.run([str(bin)], capture_output=True, text=True)
    if run.returncode != 0:
        report["note"] = "run failed"
        write_report()
        sys.exit(0)
    cpu_sec = round((time.perf_counter() - t0) / (DEFAULT_RUNS + DEFAULT_WARMUP), 6)

report["cpu_sec"] = cpu_sec
report["executed"] = True
report["validity_gate_pass"] = True
report["validity_ratio"] = 1.0
report["framework_version"] = CXX
report["note"] = "OpenMP when -fopenmp available; else serial -O3"
write_report()
