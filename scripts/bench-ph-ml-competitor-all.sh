#!/usr/bin/env bash
# Run all PH-ML SOTA competitor drivers (Wave 8).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"

run_driver() {
  local name="$1"
  local out_var="$2"
  local py="$3"
  local out="${!out_var:-$BENCHMARKS_RESULTS/${name}.json}"
  export "$out_var=$out"
  python3 "$ROOT/scripts/$py"
}

export PH_ML_NUMPY_OUT="${PH_ML_NUMPY_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-numpy-matmul.json}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_numpy_matmul.py" || true

export PH_ML_PYTORCH_CPU_MATMUL_OUT="${PH_ML_PYTORCH_CPU_MATMUL_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-pytorch-cpu-matmul.json}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_pytorch_cpu_matmul.py" || true

export PH_ML_PYTORCH_CUDA_MATMUL_OUT="${PH_ML_PYTORCH_CUDA_MATMUL_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-pytorch-cuda-matmul.json}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_pytorch_cuda_matmul.py" || true

export PH_ML_JAX_CPU_MATMUL_OUT="${PH_ML_JAX_CPU_MATMUL_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-jax-cpu-matmul.json}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_jax_cpu_matmul.py" || true

export PH_ML_TENSORFLOW_CPU_MATMUL_OUT="${PH_ML_TENSORFLOW_CPU_MATMUL_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-tensorflow-cpu-matmul.json}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_tensorflow_cpu_matmul.py" || true

export PH_ML_TRITON_MATMUL_OUT="${PH_ML_TRITON_MATMUL_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-triton-matmul.json}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_triton_matmul.py" || true

export PH_ML_PYTORCH_CPU_MLP_OUT="${PH_ML_PYTORCH_CPU_MLP_OUT:-$BENCHMARKS_RESULTS/ph-ml-competitor-pytorch-cpu-mlp.json}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_pytorch_cpu_mlp.py" || true

echo "bench-ph-ml-competitor-all: done"
