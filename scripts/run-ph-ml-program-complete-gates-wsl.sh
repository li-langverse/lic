#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-/mnt/c/Users/Julian/Documents/Programming/li/benchmarks}"
export PH_ML_WEIGHTS_FIXTURE="${PH_ML_WEIGHTS_FIXTURE:-$ROOT/benchmarks/fixtures/ph-ml-weights}"
export PH_ML_WAVE12_INNER=1
export LIG_EMIT_CUDA=1
cd "$ROOT"
bash scripts/ph-ml-program-complete-gates.sh
