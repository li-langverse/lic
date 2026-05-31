#!/usr/bin/env bash
# PH-ML Wave 13 milestone gates — Wave 12 baseline + Wave 13 docs/tracker (loop keeps going).
set -euo pipefail
ROOT="${PH_ML_WAVE13_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

bash scripts/ph-ml-wave12-gates.sh

[[ -f data/goal-directed-sprints/ph-ml-dl-rl-llm-wave13-final.md ]] \
  || { echo "missing wave13 goal file"; exit 1; }
grep -q 'Wave 13' docs/game-dev/PH-ML-GPU-battle-plan.md \
  || { echo "battle plan missing Wave 13 section"; exit 1; }
grep -q 'program complete' docs/game-dev/PH-ML-GPU-execution-tracker.md \
  || { echo "tracker missing program-complete row"; exit 1; }

echo "ph-ml-dl-rl-llm-wave13: milestone gate OK (program-complete gate still required to finish)"