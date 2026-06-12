#!/usr/bin/env bash
# Phase M: SB3 PPO train-step bench (honest executed:false when deps missing).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_ML_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
export PH_ML_SB3_TRAIN_STEP_OUT="$BENCHMARKS_RESULTS/ph-ml-sb3-train-step.json"
python3 "$ROOT/scripts/bench_ph_ml_competitor_sb3_train_step.py"
echo "bench-ph-ml-sb3-train-step: done"
