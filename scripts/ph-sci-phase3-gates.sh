#!/usr/bin/env bash
# PH-SCI Phase 3 partial gate — science_gpu + MIR placement (WP-SCI-GPU-VENDOR-03).
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

export PH_SCI_REQUIRE_MIR_GPU=1
bash scripts/ph-sci-gpu-gates.sh

[[ -f data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md ]] \
  || { echo "missing sprint goal file"; exit 1; }

echo "ph-sci-simulation-gap-close: Phase 3 (GPU vendor CI gate) OK"
