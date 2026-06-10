#!/usr/bin/env bash
# WP-SCI-GPU-00 — run science_gpu manifest suite (+ optional MIR placement gate).
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

./li-tests/run_all.sh science_gpu

if [[ "${PH_SCI_REQUIRE_MIR_GPU:-0}" == "1" ]]; then
  bash scripts/check-mir-gpu-decorator.sh
fi

echo "science_gpu gate OK"
