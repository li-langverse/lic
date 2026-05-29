#!/usr/bin/env bash
# Print recommended CUDA_HOME for this host (Debian/Ubuntu vs /usr/local/cuda).
set -euo pipefail

if [[ -x /usr/lib/cuda/bin/nvcc ]]; then
  echo "/usr/lib/cuda"
  exit 0
fi
if [[ -x /usr/local/cuda/bin/nvcc ]]; then
  echo "/usr/local/cuda"
  exit 0
fi
if command -v nvcc >/dev/null 2>&1; then
  dirname "$(dirname "$(command -v nvcc)")"
  exit 0
fi
exit 1
