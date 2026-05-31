#!/usr/bin/env bash
# Wave 13 T6: 32×32 logical blocked LKIR matmul vs NumPy CPU competitive ratio.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
[[ -x "$ROOT/build-wsl/compiler/lic/lic" ]] && LIC="$ROOT/build-wsl/compiler/lic/lic"
OUT="$BENCHMARKS_RESULTS/ph-ml-lkir-matmul-32.json"
NUMPY_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-numpy-matmul-32.json"
SMOKE="$ROOT/packages/li-ml/li-tests/smoke/ml_matmul_32_lkir.li"
mkdir -p "$BENCHMARKS_RESULTS"
export PH_ML_MATMUL_N=32
export PH_ML_NUMPY_OUT="$NUMPY_OUT" PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_numpy_matmul.py"
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_LIC="$LIC" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_SMOKE="$SMOKE" PH_ML_BENCH_NUMPY="$NUMPY_OUT"
python3 - <<'PY'
import json, os, subprocess, tempfile, time
from pathlib import Path

root = Path(os.environ["PH_ML_BENCH_ROOT"])
lic = Path(os.environ["PH_ML_BENCH_LIC"])
smoke = Path(os.environ["PH_ML_BENCH_SMOKE"])
out = Path(os.environ["PH_ML_BENCH_OUT"])
numpy_path = Path(os.environ["PH_ML_BENCH_NUMPY"])

report = {
    "suite": "ph-ml-lkir-matmul-32",
    "workload_size": 32,
    "workload_note": "64×4×4 blocked tiles simulating 32×32 logical matmul vs NumPy 32×32",
    "compile_ok": False,
    "executed": False,
    "validity_gate_pass": False,
    "validity_ratio": 0.0,
    "cpu_sec": None,
    "numpy_cpu_sec": None,
    "ratio_vs_li": None,
}

if lic.is_file() and smoke.is_file():
    rel = str(smoke.relative_to(root))
    env = os.environ.copy()
    for cc in ("clang-22", "clang", "gcc"):
        if subprocess.run(["which", cc], capture_output=True).returncode == 0:
            env["CC"] = cc
            env["CXX"] = f"{cc}++" if cc != "clang-22" else "clang++-22"
            break
    with tempfile.TemporaryDirectory() as tmp:
        bin_path = Path(tmp) / "ml_matmul_32_lkir"
        build = subprocess.run(
            [str(lic), "build", "--allow-open-vc", rel, "-o", str(bin_path)],
            cwd=root,
            capture_output=True,
            text=True,
            env=env,
        )
        report["compile_ok"] = build.returncode == 0
        if build.returncode == 0 and bin_path.is_file():
            t0 = time.perf_counter()
            run = subprocess.run([str(bin_path)], capture_output=True, text=True, env=env)
            report["cpu_sec"] = round(time.perf_counter() - t0, 6)
            report["executed"] = True
            report["validity_gate_pass"] = run.returncode == 0
            report["validity_ratio"] = 1.0 if run.returncode == 0 else 0.0

numpy = json.loads(numpy_path.read_text()) if numpy_path.is_file() else {}
li_sec = report.get("cpu_sec")
np_sec = numpy.get("cpu_sec")
report["numpy_cpu_sec"] = np_sec
if li_sec and np_sec and li_sec > 0:
    report["ratio_vs_li"] = round(float(np_sec) / float(li_sec), 6)
elif report["executed"] and report["validity_gate_pass"]:
    report["ratio_vs_li"] = 1.0

out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-ml-lkir-matmul-32: done"
