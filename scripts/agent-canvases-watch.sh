#!/usr/bin/env bash
# Live refresh for goal-directed-agents-live, sim-plan-daily-report, studio-ui-ux-daily-report.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
INTERVAL="${AGENT_CANVASES_INTERVAL_SEC:-15}"
LOG="${ROOT}/data/goal-directed-agents/watch.log"
mkdir -p data/goal-directed-agents
echo "==> agent-canvases-watch interval=${INTERVAL}s $(date -Iseconds)" | tee -a "$LOG"
while true; do
  if ./scripts/refresh-all-agent-canvases.sh >>"$LOG" 2>&1; then
    :
  else
    echo "watch: refresh failed $(date -Iseconds)" >>"$LOG"
  fi
  sleep "$INTERVAL"
done
