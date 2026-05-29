#!/usr/bin/env bash
# WP-HW-09 / wave 6: probe NVIDIA tooling and suggest CUDA_HOME (no GPU timing).
set -euo pipefail

suggest=""
if [[ -n "${CUDA_HOME:-}" && -d "${CUDA_HOME}" ]]; then
  suggest="$CUDA_HOME"
elif [[ -n "${CUDA_PATH:-}" && -d "${CUDA_PATH}" ]]; then
  suggest="$CUDA_PATH"
elif command -v nvcc >/dev/null 2>&1; then
  nvcc_dir="$(dirname "$(dirname "$(readlink -f "$(command -v nvcc)")")")"
  if [[ -d "$nvcc_dir" ]]; then
    suggest="$nvcc_dir"
  fi
else
  for candidate in /usr/local/cuda /usr/local/cuda-12 /usr/local/cuda-12.4 /opt/cuda; do
    if [[ -d "$candidate" ]]; then
      suggest="$candidate"
      break
    fi
  done
fi

nvidia_smi="absent"
if command -v nvidia-smi >/dev/null 2>&1; then
  if nvidia-smi -L >/dev/null 2>&1; then
    nvidia_smi="visible"
  else
    nidia_smi="present_no_gpu"
  fi
fi

echo "nvidia_smi=$nvidia_smi"
echo "cuda_home_env=${CUDA_HOME:-}"
echo "cuda_path_env=${CUDA_PATH:-}"
if [[ -n "$suggest" ]]; then
  echo "suggested_CUDA_HOME=$suggest"
  echo "export CUDA_HOME=$suggest"
else
  echo "suggested_CUDA_HOME="
  echo "# No CUDA toolkit found; WP-HW-09 PTX emit remains blocked on GPU runners."
fi
