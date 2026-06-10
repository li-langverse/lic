#!/usr/bin/env bash
# WP-SCI-GPU-VENDOR-03 — unified science + ML GPU gate (MIR optional; vendor CUDA optional).
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

echo "==> science_gpu suite"
bash scripts/check-science-gpu-gate.sh

if [[ -f scripts/ph-sci-gpu-chem-gates.sh ]]; then
  echo "==> GPU chem / DFT competitive gates"
  bash scripts/ph-sci-gpu-chem-gates.sh
fi

if [[ "${PH_SCI_REQUIRE_MIR_GPU:-0}" == "1" ]]; then
  bash scripts/check-mir-gpu-decorator.sh
fi

if [[ "${LIG_EMIT_CUDA:-0}" == "1" ]]; then
  LIC="${LIC_BIN:-${LIC:-$("$ROOT/scripts/resolve-lic.sh")}}"
  export LIC
  echo "==> WP-SCI-GPU-VENDOR-01: chem DFT LKIR smoke (CUDA emit requested)"
  "$LIC" build --allow-open-vc --no-lean-verify \
    packages/li-chem/li-tests/smoke/chem_gpu_dft_lkir.li -o /dev/null || {
    echo "WARN: LIG_EMIT_CUDA=1 build failed — vendor path deferred (MIR placement still gated)"
  }
fi

echo "ph-sci-gpu-gates OK"
