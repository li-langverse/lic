#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_inner() {
  export BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-$ROOT/../benchmarks}"
  export PH_ML_WEIGHTS_FIXTURE="${PH_ML_WEIGHTS_FIXTURE:-$ROOT/benchmarks/fixtures/ph-ml-weights}"
  export PH_ML_WAVE12_INNER=1
  export LIG_EMIT_CUDA=1
  export LIC="${LIC:-./build-wsl/compiler/lic/lic}"
  cd "$ROOT"
  bash scripts/ph-ml-program-complete-gates.sh
}

if [[ "$(uname -s)" != "Linux" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl_bench="$(wsl.exe wslpath -u "${BENCHMARKS_ROOT:-$ROOT/../benchmarks}" 2>/dev/null | tr -d '\r\n' || true)"
  wsl_fixture="$(wsl.exe wslpath -u "${PH_ML_WEIGHTS_FIXTURE:-$ROOT/benchmarks/fixtures/ph-ml-weights}" 2>/dev/null | tr -d '\r\n' || true)"
  wsl.exe bash -lc "cd '$wsl_root' && export BENCHMARKS_ROOT='${wsl_bench}' PH_ML_WEIGHTS_FIXTURE='${wsl_fixture}' PH_ML_WAVE12_INNER=1 LIG_EMIT_CUDA=1 LIC=./build-wsl/compiler/lic/lic && bash scripts/ph-ml-program-complete-gates.sh"
else
  run_inner
fi
