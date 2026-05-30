#!/usr/bin/env bash
# Run goal-directed security research until backlog complete (or fail streak).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

LOG_DIR="$ROOT/data/security-research-loop"
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
export SECURITY_RESEARCH_PR_BRANCH="${SECURITY_RESEARCH_PR_BRANCH:-cursor/security-research-loop}"
export LI_SECURITY_PLAN_AGENT="${LI_SECURITY_PLAN_AGENT:-security_auditor}"
export LI_SECURITY_RESEARCH_AGENT_TIMEOUT_SEC="${LI_SECURITY_RESEARCH_AGENT_TIMEOUT_SEC:-3600}"
export LI_SDK_TERMINAL_STREAM="${LI_SDK_TERMINAL_STREAM:-1}"

log() { echo "$@" | tee -a "$LOG"; }

remaining() {
  python3 - <<PY
import re
from pathlib import Path
text = Path("$ROOT/docs/ecosystem/security-research-backlog.md").read_text()
done = set()
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

log "==> security-research-run-until-done $(date -Iseconds)"
log "    branch=$SECURITY_RESEARCH_PR_BRANCH agent=$LI_SECURITY_PLAN_AGENT log=$LOG"

cd "$ROOT"
git fetch origin "$SECURITY_RESEARCH_PR_BRANCH" 2>/dev/null || true
git checkout -B "$SECURITY_RESEARCH_PR_BRANCH" "origin/${SECURITY_RESEARCH_PR_BRANCH}" 2>/dev/null \
  || git checkout -B "$SECURITY_RESEARCH_PR_BRANCH"

FAIL_STREAK=0
MAX_FAIL="${SECURITY_RESEARCH_MAX_FAIL_STREAK:-5}"

while true; do
  left="$(remaining)"
  if [[ "$left" -eq 0 ]]; then
    log "==> DONE: all security research todos complete"
    "./scripts/security-research-daily-report.sh" 2>/dev/null | tee -a "$LOG" || true
    exit 0
  fi
  log "==> remaining security todos: $left"
  if ! python3 "$ROOT/scripts/security-research-plan-loop.py" --once 2>&1 | tee -a "$LOG"; then
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
