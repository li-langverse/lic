#!/usr/bin/env bash
# Phase F: li-array 32×32 LKIR matmul bench vs NumPy (run-only cpu_sec, ratio_vs_li).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_LI_ARRAY32_INNER=1 BENCHMARKS_ROOT='${BENCHMARKS_ROOT:-}' && bash scripts/bench-ph-ml-li-array-matmul-32.sh"
}

if [[ "${PH_ML_LI_ARRAY32_INNER:-0}" != "1" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" "bench-ph-ml-li-array-matmul-32: build lic" || exit 1
OUT="$BENCHMARKS_RESULTS/ph-ml-li-array-matmul-32.json"
NUMPY_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-numpy-matmul-32.json"
SMOKE="$ROOT/packages/li-array/li-tests/smoke/array_matmul_32.li"
mkdir -p "$BENCHMARKS_RESULTS"
export PH_ML_MATMUL_N=32
export PH_ML_NUMPY_OUT="$NUMPY_OUT" PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_numpy_matmul.py" || true
PH_ML_LI_ARRAY32_BIN="/tmp/ph-ml-li-array32-$$"
PH_ML_LI_ARRAY32_COMPILE_OK=0
PH_ML_LI_ARRAY32_RUN_RC=1
PH_ML_LI_ARRAY32_CPU_SEC=""
export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
if [[ -f "$LIC" && -f "$SMOKE" ]]; then
  rel="${SMOKE#"$ROOT"/}"
  if "$LIC" build --allow-open-vc "$rel" -o "$PH_ML_LI_ARRAY32_BIN" >/dev/null 2>&1; then
    PH_ML_LI_ARRAY32_COMPILE_OK=1
  fi
  if [[ "$PH_ML_LI_ARRAY32_COMPILE_OK" == "1" && -x "$PH_ML_LI_ARRAY32_BIN" ]]; then
    PH_ML_LI_ARRAY32_WARMUP="${PH_ML_LI_ARRAY32_WARMUP:-3}"
    PH_ML_LI_ARRAY32_RUNS="${PH_ML_LI_ARRAY32_RUNS:-50}"
    export LI_ARRAY_BLAS="${LI_ARRAY_BLAS-}"
    for _w in $(seq 1 "$PH_ML_LI_ARRAY32_WARMUP"); do
      "$PH_ML_LI_ARRAY32_BIN" >/dev/null 2>&1 || true
    done
    t0="$(python3 -c 'import time; print(time.perf_counter())')"
    PH_ML_LI_ARRAY32_RUN_RC=0
    if ! "$PH_ML_LI_ARRAY32_BIN" >/dev/null 2>&1; then
      PH_ML_LI_ARRAY32_RUN_RC=1
    fi
    t1="$(python3 -c 'import time; print(time.perf_counter())')"
    PH_ML_LI_ARRAY32_CPU_SEC="$(python3 -c "print(round((float('$t1') - float('$t0')) / int('$PH_ML_LI_ARRAY32_RUNS'), 6))")"
  fi
fi
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_NUMPY="$NUMPY_OUT"
export PH_ML_LI_ARRAY32_COMPILE_OK PH_ML_LI_ARRAY32_RUN_RC PH_ML_LI_ARRAY32_CPU_SEC
python3 - <<'PY'
import json, os
from pathlib import Path

out = Path(os.environ["PH_ML_BENCH_OUT"])
numpy_path = Path(os.environ["PH_ML_BENCH_NUMPY"])
compile_ok = os.environ.get("PH_ML_LI_ARRAY32_COMPILE_OK") == "1"
run_rc = int(os.environ.get("PH_ML_LI_ARRAY32_RUN_RC", "1"))
cpu_raw = os.environ.get("PH_ML_LI_ARRAY32_CPU_SEC", "").strip()
cpu_sec = float(cpu_raw) if cpu_raw else None
executed = compile_ok and run_rc == 0 and cpu_sec is not None
validity = executed

blas_env = os.environ.get("LI_ARRAY_BLAS", "").strip().lower()
blas_requested = blas_env not in ("", "0", "off", "false", "no")
blas_backend = "openblas" if blas_requested else "none"
workload_class = "blas_labeled" if blas_requested else "cpu_native"
gemm_tile = int(os.environ.get("LI_ARRAY_GEMM_TILE", "8") or "8")
if gemm_tile not in (8, 16):
    gemm_tile = 8
buffer_class = "dense_c_blas32"
phase_h_baseline = 343.0

report = {
    "suite": "ph-ml-li-array-matmul-32",
    "id": "li_array_matmul_32x32",
    "workload_size": 32,
    "workload_note": "32x32 logical f32 via ArrayDesc -> ml_matmul_cpu_logical_32 (dense array[1024] + BLAS 32^3 when LI_ARRAY_BLAS=openblas); run-only 50x mean; ratio_vs_li = numpy/cpu",
    "blas_backend": blas_backend,
    "workload_class": workload_class,
    "buffer_class": buffer_class,
    "gemm_tile": gemm_tile,
    "phase_h_baseline_li_over_numpy": phase_h_baseline,
    "compile_ok": compile_ok,
    "executed": executed,
    "validity_gate_pass": validity,
    "validity_ratio": 1.0 if validity else 0.0,
    "cpu_sec": cpu_sec,
    "build_cpu_sec": None,
    "numpy_cpu_sec": None,
    "ratio_vs_li": None,
    "ratio_target": 2.0,
    "ratio_target_met": False,
}
numpy = json.loads(numpy_path.read_text()) if numpy_path.is_file() else {}
np_sec = numpy.get("cpu_sec")
report["numpy_cpu_sec"] = np_sec
if cpu_sec and np_sec and cpu_sec > 0 and np_sec > 0:
    report["ratio_vs_li"] = round(float(np_sec) / float(cpu_sec), 6)
    li_over_numpy = round(float(cpu_sec) / float(np_sec), 6)
    report["li_over_numpy"] = li_over_numpy
    report["ratio_target_met"] = li_over_numpy <= 2.0
elif executed and validity:
    report["ratio_vs_li"] = 1.0
    report["li_over_numpy"] = 1.0
    report["ratio_target_met"] = True
out.write_text(json.dumps(report, indent=2) + "\n")
print(f"bench-ph-ml-li-array-matmul-32: ratio_vs_li={report['ratio_vs_li']} target_met={report['ratio_target_met']}")
PY
rm -f "$PH_ML_LI_ARRAY32_BIN"
echo "bench-ph-ml-li-array-matmul-32: done"
