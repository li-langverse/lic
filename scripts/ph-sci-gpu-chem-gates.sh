#!/usr/bin/env bash
# PH-SCI-GPU-CHEM — DFT @gpu smokes + full science_gpu suite.
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

echo "==> chem DFT lib compile (li-chem)"
./build-wsl/compiler/lic/lic build packages/li-chem/src/lib.li --allow-open-vc

echo "==> science_gpu suite (includes PH-SCI-GPU-16/17/18)"
bash scripts/check-science-gpu-gate.sh

echo "==> chem DFT competitive bench (PySCF oracle; ORCA external-only)"
bash scripts/ph-sci-chem-dft-competitive-gates.sh

echo "ph-sci-gpu-chem-gates OK"
