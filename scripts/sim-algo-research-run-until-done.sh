#!/usr/bin/env bash
# Run goal-directed sim algorithm research until backlog complete (or fail streak).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERT="${SIM_RESEARCH_VERTICAL:-}"
if [[ "$VERT" != "md" && "$VERT" != "chem" ]]; then
  echo "sim-algo-research-run-until-done: set SIM_RESEARCH_VERTICAL=md|chem" >&2
  exit 1
fi

LOG_DIR="$ROOT/data/sim-${VERT}-research-loop"
mkdir -p "$LOG_DIR"
STAMP="$(date -u +%Y%m%d-%H%M%S)"
LOG="$LOG_DIR/runner-${STAMP}.log"
ln -sf "$(basename "$LOG")" "$LOG_DIR/runner.log"

ENV_FILE="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +a
fi

export PATH="${HOME}/.local/node/bin:${PATH:-/usr/bin:/bin}"
export LI_CURSOR_AGENTS_ROOT="${LI_CURSOR_AGENTS_ROOT:-$ROOT/../li-cursor-agents}"
export LIC_ROOT="$ROOT"
export SIM_RESEARCH_VERTICAL="$VERT"
export SIM_RESEARCH_PR_BRANCH="${SIM_RESEARCH_PR_BRANCH:-cursor/sim-${VERT}-research-loop}"
export LI_SIM_RESEARCH_AGENT="${LI_SIM_RESEARCH_AGENT:-numerics_researcher}"
export LI_SIM_RESEARCH_AGENT_TIMEOUT_SEC="${LI_SIM_RESEARCH_AGENT_TIMEOUT_SEC:-3600}"
export LI_SDK_TERMINAL_STREAM="${LI_SDK_TERMINAL_STREAM:-1}"

log() { echo "$@" | tee -a "$LOG"; }

remaining() {
  python3 - <<PY
import re
from pathlib import Path
text = Path("$ROOT/docs/ecosystem/sim-${VERT}-research-backlog.md").read_text()
done = set()
# state completed
import json
sf = Path("$LOG_DIR/state.json")
if sf.is_file():
    done = set(json.loads(sf.read_text()).get("completed_ids", []))
pending = 0
for m in re.finditer(r"- id: (\S+)\n\s+content: \"[^\"]+\"\n\s+status: (\w+)", text):
    if m.group(2) in ("pending", "in_progress") and m.group(1) not in done:
        pending += 1
print(pending)
PY
}

log "==> sim-algo-research-run-until-done vertical=$VERT $(date -Iseconds)"
log "    branch=$SIM_RESEARCH_PR_BRANCH log=$LOG"

cd "$ROOT"
git fetch origin "$SIM_RESEARCH_PR_BRANCH" 2>/dev/null || true
git checkout -B "$SIM_RESEARCH_PR_BRANCH" "origin/${SIM_RESEARCH_PR_BRANCH}" 2>/dev/null \
  || git checkout -B "$SIM_RESEARCH_PR_BRANCH"

FAIL_STREAK=0
MAX_FAIL="${SIM_RESEARCH_MAX_FAIL_STREAK:-5}"

while true; do
  left="$(remaining)"
  if [[ "$left" -eq 0 ]]; then
    log "==> DONE: all research todos complete"
    "./scripts/sim-${VERT}-research-daily-report.sh" 2>/dev/null | tee -a "$LOG" || true
    exit 0
  fi
  log "==> remaining research todos: $left"
  if ! python3 "$ROOT/scripts/sim-algo-research-plan-loop.py" --once 2>&1 | tee -a "$LOG"; then
    FAIL_STREAK=$((FAIL_STREAK + 1))
    log "==> iteration failed (streak=$FAIL_STREAK)"
    if [[ "$FAIL_STREAK" -ge "$MAX_FAIL" ]]; then
      log "==> stop: max fail streak $MAX_FAIL"
      exit 1
    fi
    sleep 120
    continue
  fi
  FAIL_STREAK=0
  sleep 30
done
