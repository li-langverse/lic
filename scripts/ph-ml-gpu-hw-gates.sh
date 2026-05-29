#!/usr/bin/env bash
# Gates for PH-ML GPU hardware (CUDA) goal-directed loop.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export CUDA_HOME="${CUDA_HOME:-/usr/lib/cuda}"
export PATH="$CUDA_HOME/bin:${PATH:-}"

echo "==> ph-ml-gpu-hw-gates $(date -Iseconds)"
echo "    CUDA_HOME=$CUDA_HOME"

./scripts/build.sh

if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi -L | head -3 || true
else
  echo "warn: nvidia-smi missing" >&2
fi

bash scripts/cuda-home-probe.sh
bash scripts/check-lig-ptx-catalog.sh

li-tests/run_all.sh gpu

if [[ -x scripts/lig-cuda-timing-probe.sh ]]; then
  bash scripts/lig-cuda-timing-probe.sh || {
    echo "lig-cuda-timing-probe failed (device timing may be N/A — ok if documented)" >&2
  }
fi

LIG_EMIT_CUDA=1 bash scripts/bench-lig-gpu-suite.sh

bash scripts/lkir-validate.sh

echo "==> ph-ml-gpu-hw-gates OK"
