#!/usr/bin/env bash
# Sprint completion: engineering (killer gate) + proofs (G-par Done) at 100%.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel goal-complete gate (engineering + proofs 100%)"

bash "$ROOT/scripts/check-li-parallel-killer-gate.sh"
bash "$ROOT/scripts/check-li-parallel-proofs-complete-gate.sh"

li_ok "check-li-parallel-goal-complete-gate.sh: PASS (GOAL_COMPLETE — engineering + proofs 100%)"
