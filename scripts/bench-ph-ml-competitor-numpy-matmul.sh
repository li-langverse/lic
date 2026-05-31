#!/usr/bin/env bash
# Honest NumPy matmul timing for PH-ML competitive row (4×4 pilot matching li-ml smoke).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
OUT="${PH_ML_NUMPY_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-numpy-matmul.json}"
mkdir -p "$(dirname "$OUT")"
export PH_ML_NUMPY_OUT="$OUT" PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_numpy_matmul.py"
