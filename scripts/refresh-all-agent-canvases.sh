#!/usr/bin/env bash
# Refresh all three goal-directed agent canvases (goal + sim + studio).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIC_ROOT="$(cd "${LIC_ROOT:-$SCRIPT_DIR/..}" && pwd)"
LANGVERSE="${LI_LANGVERSE_ROOT:-$(cd "$LIC_ROOT/.." && pwd)}"
SIM_ROOT="${SIM_LIC_ROOT:-$LANGVERSE/lic-worktrees/sim-algo}"
STUDIO_ROOT="${STUDIO_LIC_ROOT:-$LANGVERSE/lic-studio-ui}"

refresh_goal() {
  python3 "${LIC_ROOT}/scripts/goal-directed-agents-snapshot.py"
  python3 "${LIC_ROOT}/scripts/refresh-goal-agents-canvas.py"
}

refresh_sim() {
  if [[ ! -d "$SIM_ROOT" ]]; then
    echo "refresh-all: skip sim (missing $SIM_ROOT)"
    return 0
  fi
  python3 "${SIM_ROOT}/scripts/sim-plan-write-snapshot.py"
  python3 "${SIM_ROOT}/scripts/sim-plan-refresh-canvas.py"
}

refresh_studio() {
  if [[ ! -d "$STUDIO_ROOT" ]]; then
    echo "refresh-all: skip studio (missing $STUDIO_ROOT)"
    return 0
  fi
  python3 "${STUDIO_ROOT}/scripts/studio-ui-ux-write-snapshot.py"
  python3 "${STUDIO_ROOT}/scripts/studio-ui-ux-refresh-canvas.py"
}

refresh_goal
refresh_sim
refresh_studio
echo "refresh-all-agent-canvases: done $(date -Iseconds)"
