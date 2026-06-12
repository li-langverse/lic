#!/usr/bin/env bash
# Phase L: Li ml_mlp_sgd_step_f32 training loop vs PyTorch CPU SGD (same XOR fixture).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_ML_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

run_in_wsl() {
  local wsl_root wsl_bench
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl_bench=""
  if [[ -n "${BENCHMARKS_ROOT:-}" ]]; then
    wsl_bench="$(wsl.exe wslpath -u "$BENCHMARKS_ROOT" 2>/dev/null | tr -d '\r\n')" || wsl_bench=""
  fi
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_TRAIN_COMP_INNER=1 PH_ML_TRAIN_COMP_ROOT='$wsl_root' BENCHMARKS_ROOT='${wsl_bench}' LIC=./build-wsl/compiler/lic/lic CC=clang-22 CXX=clang++-22 && bash scripts/bench-ph-ml-mlp-train-competitive.sh"
}

if [[ "${PH_ML_TRAIN_COMP_INNER:-0}" != "1" ]] \
  && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] \
  && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_export_lic "$ROOT" || true

export PH_ML_TRAIN_COMP_ROOT="$ROOT"
export PH_ML_MLP_TRAIN_COMP_OUT="$BENCHMARKS_RESULTS/ph-ml-mlp-train-competitive.json"
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
python3 "$ROOT/scripts/bench_ph_ml_mlp_train_competitive.py"
echo "bench-ph-ml-mlp-train-competitive: done"
