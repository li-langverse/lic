#!/usr/bin/env bash
# Run swarm_observer orchestration loop until backlog complete.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT/data/swarm-observer-plan-loop"
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
export LI_LANGVERSE_ROOT="${LI_LANGVERSE_ROOT:-$(cd "$ROOT/.." && pwd)}"
export BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-$LI_LANGVERSE_ROOT/benchmarks}"
export SWARM_OBSERVER_PR_BRANCH="${SWARM_OBSERVER_PR_BRANCH:-cursor/swarm-observer-plan-loop}"
export LI_SWARM_PLAN_AGENT="${LI_SWARM_PLAN_AGENT:-swarm_observer}"
export LI_SWARM_OBSERVER_AGENT_TIMEOUT_SEC="${LI_SWARM_OBSERVER_AGENT_TIMEOUT_SEC:-2400}"
export LI_SDK_TERMINAL_STREAM="${LI_SDK_TERMINAL_STREAM:-1}"

log() { echo "$@" | tee -a "$LOG"; }

remaining() {
  python3 - <<PY
import re, json
from pathlib import Path
text = Path("$ROOT/docs/ecosystem/swarm-observer-plan-backlog.md").read_text()
done = set()
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

log "==> swarm-observer-plan-run-until-done $(date -Iseconds)"
log "    branch=$SWARM_OBSERVER_PR_BRANCH log=$LOG"

cd "$ROOT"
git fetch origin "$SWARM_OBSERVER_PR_BRANCH" 2>/dev/null || true
git checkout -B "$SWARM_OBSERVER_PR_BRANCH" "origin/${SWARM_OBSERVER_PR_BRANCH}" 2>/dev/null \
  || git checkout -B "$SWARM_OBSERVER_PR_BRANCH"

FAIL_STREAK=0
MAX_FAIL="${SWARM_OBSERVER_MAX_FAIL_STREAK:-5}"

while true; do
  left="$(remaining)"
  if [[ "$left" -eq 0 ]]; then
    log "==> DONE: all orchestrator todos complete"
    exit 0
  fi
  log "==> remaining orchestrator todos: $left"
  if ! python3 "$ROOT/scripts/swarm-observer-plan-loop.py" --once 2>&1 | tee -a "$LOG"; then
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
