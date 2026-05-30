#!/usr/bin/env bash
# Refresh all three goal-directed agent canvases (goal + sim + studio).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIC_ROOT="$(cd "${LIC_ROOT:-$SCRIPT_DIR/..}" && pwd)"
export LIC_ROOT
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

bump_canvas_status() {
  local canvas="$1"
  if [[ -f "${LIC_ROOT}/scripts/lib/write-canvas-status.py" ]]; then
    python3 "${LIC_ROOT}/scripts/lib/write-canvas-status.py" "$canvas" || true
  fi
}

refresh_goal
refresh_sim
refresh_studio

CANVAS_DIR="${CURSOR_CANVAS_DIR:-$HOME/.cursor/projects/home-s4il0r-Documents-Cursor/canvases}"
bump_canvas_status "${CANVAS_DIR}/goal-directed-agents-live.canvas.tsx"
bump_canvas_status "${CANVAS_DIR}/sim-plan-daily-report.canvas.tsx"
bump_canvas_status "${CANVAS_DIR}/studio-ui-ux-daily-report.canvas.tsx"

echo "refresh-all-agent-canvases: done $(date -Iseconds)"
