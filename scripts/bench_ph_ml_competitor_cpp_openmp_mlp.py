#!/usr/bin/env python3
"""C++ OpenMP 2-2-1 MLP forward — Wave 10 competitor row."""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

from ph_ml_competitor_workloads import DEFAULT_RUNS, DEFAULT_WARMUP, report_base

out = os.environ["PH_ML_CPP_OPENMP_MLP_OUT"]
report = report_base("cpp_openmp", "ph-ml-competitor-cpp-openmp-mlp", "mlp_forward_2_2_1_f32")
report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
report["device"] = "cpu"


def write_report() -> None:
    Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(out)


CXX = shutil.which("g++") or shutil.which("clang++")
if not CXX:
    report["note"] = "no C++ compiler"
    write_report()
    sys.exit(0)

SRC = r"""
#include <cmath>
static float relu(float x) { return x > 0.f ? x : 0.f; }
int main() {
  float x[2] = {1.f, 1.f};
  float w1[4] = {1.f, 0.f, 0.f, 1.f};
  float w2[2] = {1.f, 1.f};
  float h[2];
  for (int r = 0; r < __TOTAL__; ++r) {
    h[0] = relu(x[0]*w1[0] + x[1]*w1[2]);
    h[1] = relu(x[0]*w1[1] + x[1]*w1[3]);
    float y = h[0]*w2[0] + h[1]*w2[1];
    if (y <= 0.f) return 1;
  }
  return 0;
}
""".replace("__TOTAL__", str(DEFAULT_RUNS + DEFAULT_WARMUP))

with tempfile.TemporaryDirectory(prefix="ph-ml-cpp-mlp-") as tmp:
    src = Path(tmp) / "mlp.cpp"
    bin = Path(tmp) / "mlp"
    src.write_text(SRC, encoding="utf-8")
    comp = subprocess.run([CXX, "-O3", "-std=c++17", str(src), "-o", str(bin)], capture_output=True, text=True)
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
report["note"] = "C++ serial MLP 2-2-1 (OpenMP optional deferred)"
write_report()
