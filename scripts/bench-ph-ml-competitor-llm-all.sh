#!/usr/bin/env bash
# Stage 8: LLM competitor drivers (llama.cpp, vLLM, transformers).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"
python3 "$ROOT/scripts/prepare_ph_ml_weights_fixture.py"

export PH_ML_LLAMACPP_OUT="${PH_ML_LLAMACPP_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-llamacpp.json}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_llamacpp.py" || true

export PH_ML_VLLM_OUT="${PH_ML_VLLM_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-vllm.json}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_vllm.py" || true

export PH_ML_TRANSFORMERS_OUT="${PH_ML_TRANSFORMERS_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-transformers.json}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_transformers.py" || true

echo "bench-ph-ml-competitor-llm-all: done"
