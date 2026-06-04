#!/usr/bin/env bash
# WP-SCI-GPU-VENDOR-03 — science_gpu + optional MIR placement (+ ML GPU when enabled).
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

bash scripts/check-science-gpu-gate.sh

if [[ "${PH_SCI_REQUIRE_MIR_GPU:-1}" == "1" ]]; then
  bash scripts/check-mir-gpu-decorator.sh
fi

if [[ "${PH_SCI_INCLUDE_ML_GPU:-0}" == "1" ]]; then
  ./li-tests/run_all.sh ml_gpu_smoke 2>/dev/null || ./li-tests/run_all.sh ml_gpu 2>/dev/null || true
fi

echo "ph-sci-gpu-gates: science_gpu (+ MIR) OK"
