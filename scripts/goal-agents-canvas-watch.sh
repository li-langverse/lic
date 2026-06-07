#!/usr/bin/env bash
# Deprecated wrapper — use agent-canvases-watch.sh (refreshes all three canvases).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export AGENT_CANVASES_INTERVAL_SEC="${GOAL_AGENTS_CANVAS_INTERVAL_SEC:-${AGENT_CANVASES_INTERVAL_SEC:-15}}"
exec "${ROOT}/scripts/agent-canvases-watch.sh"
