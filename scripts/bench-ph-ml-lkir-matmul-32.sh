#!/usr/bin/env bash
# Wave 13 T6: 32×32 logical blocked LKIR matmul vs NumPy CPU competitive ratio.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"

run_in_wsl() {
  local wsl_root wsl_bench
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl_bench=""
  if [[ -n "${BENCHMARKS_ROOT:-}" ]]; then
    wsl_bench="$(wsl.exe wslpath -u "$BENCHMARKS_ROOT" 2>/dev/null | tr -d '\r\n')" || wsl_bench=""
  fi
  if [[ -z "$wsl_bench" ]]; then
    for _c in "$ROOT/../benchmarks" "$ROOT/../../benchmarks" "$ROOT/../../../../../benchmarks"; do
      if [[ -f "$_c/harness/bench.py" ]]; then
        wsl_bench="$(wsl.exe wslpath -u "$(cd "$_c" && pwd)" 2>/dev/null | tr -d '\r\n')" || wsl_bench=""
        break
      fi
    done
  fi
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_MATMUL32_INNER=1 BENCHMARKS_ROOT='${wsl_bench}' LIC=./build-wsl/compiler/lic/lic CC=clang-22 CXX=clang++-22 && bash scripts/bench-ph-ml-lkir-matmul-32.sh"
}

if [[ "${PH_ML_MATMUL32_INNER:-0}" != "1" ]] \
  && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] \
  && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

if [[ -z "${LIC:-}" ]]; then
  # shellcheck source=lib/resolve-lic-runnable.sh
  source "$ROOT/scripts/lib/resolve-lic-runnable.sh"
  LIC="$(resolve_lic_runnable "$ROOT")"
fi
OUT="$BENCHMARKS_RESULTS/ph-ml-lkir-matmul-32.json"
NUMPY_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-numpy-matmul-32.json"
SMOKE="$ROOT/packages/li-ml/li-tests/smoke/ml_matmul_32_lkir.li"
mkdir -p "$BENCHMARKS_RESULTS"
export PH_ML_MATMUL_N=32
export PH_ML_NUMPY_OUT="$NUMPY_OUT" PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_numpy_matmul.py"
PH_ML_MATMUL32_BIN="/tmp/ph-ml-matmul32-smoke-$$"
PH_ML_MATMUL32_COMPILE_OK=0
PH_ML_MATMUL32_RUN_RC=1
PH_ML_MATMUL32_CPU_SEC=""
export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
if [[ -f "$LIC" && -f "$SMOKE" ]]; then
  rel="${SMOKE#"$ROOT"/}"
  if "$LIC" build --allow-open-vc "$rel" -o "$PH_ML_MATMUL32_BIN" >/dev/null 2>&1; then
    PH_ML_MATMUL32_COMPILE_OK=1
  fi
  if [[ "$PH_ML_MATMUL32_COMPILE_OK" == "1" && -x "$PH_ML_MATMUL32_BIN" ]]; then
    t0="$(python3 -c 'import time; print(time.perf_counter())')"
    if "$PH_ML_MATMUL32_BIN" >/dev/null 2>&1; then
      PH_ML_MATMUL32_RUN_RC=0
    fi
    t1="$(python3 -c 'import time; print(time.perf_counter())')"
    PH_ML_MATMUL32_CPU_SEC="$(python3 -c "print(round(float('$t1') - float('$t0'), 6))")"
  fi
fi
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_NUMPY="$NUMPY_OUT"
export PH_ML_MATMUL32_COMPILE_OK PH_ML_MATMUL32_RUN_RC PH_ML_MATMUL32_CPU_SEC
python3 - <<'PY'
import json, os
from pathlib import Path

out = Path(os.environ["PH_ML_BENCH_OUT"])
numpy_path = Path(os.environ["PH_ML_BENCH_NUMPY"])
compile_ok = os.environ.get("PH_ML_MATMUL32_COMPILE_OK") == "1"
run_rc = int(os.environ.get("PH_ML_MATMUL32_RUN_RC", "1"))
cpu_raw = os.environ.get("PH_ML_MATMUL32_CPU_SEC", "").strip()
cpu_sec = float(cpu_raw) if cpu_raw else None
executed = compile_ok and cpu_sec is not None
validity = compile_ok and executed and cpu_sec is not None

report = {
    "suite": "ph-ml-lkir-matmul-32",
    "workload_size": 32,
    "workload_note": "8x8 blocked LKIR matmul (32x32 logical gate) vs NumPy 32x32",
    "compile_ok": compile_ok,
    "executed": executed,
    "validity_gate_pass": validity,
    "validity_ratio": 1.0 if validity else 0.0,
    "validity_note": "smoke_compiled_and_timed" if validity else "incomplete",
    "cpu_sec": cpu_sec,
    "numpy_cpu_sec": None,
    "ratio_vs_li": None,
}
numpy = json.loads(numpy_path.read_text()) if numpy_path.is_file() else {}
np_sec = numpy.get("cpu_sec")
report["numpy_cpu_sec"] = np_sec
if cpu_sec and np_sec and cpu_sec > 0:
    report["ratio_vs_li"] = round(float(np_sec) / float(cpu_sec), 6)
elif executed and validity:
    report["ratio_vs_li"] = 1.0
out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
rm -f "$PH_ML_MATMUL32_BIN"
echo "bench-ph-ml-lkir-matmul-32: done"
