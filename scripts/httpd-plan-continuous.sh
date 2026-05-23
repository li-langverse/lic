#!/usr/bin/env bash
# Run httpd plan loop continuously; idle-sleep when no open todos.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT/data/httpd-plan-loop"
LOCK="$LOG_DIR/.systemd.lock"
ENV_SNIPPET="$LOG_DIR/env.sh"
ENV_FILE="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"
DISABLE="$LOG_DIR/DISABLE_AUTOSTART"
LOOP="$ROOT/scripts/httpd-plan-loop.py"

mkdir -p "$LOG_DIR"
exec 8>"$LOCK"
if ! flock -n 8; then
  echo "httpd-plan-continuous: already running — exit" >&2
  exit 0
fi

if [[ -f "$ENV_SNIPPET" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ENV_SNIPPET"
  set +a
elif [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +a
fi

export PATH="${HOME}/.local/node/bin:${PATH:-/usr/bin:/bin}"
export LI_CURSOR_AGENTS_ROOT="${LI_CURSOR_AGENTS_ROOT:-$ROOT/../li-cursor-agents}"
export BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-$ROOT/../benchmarks}"
export LIC_ROOT="$ROOT"
export HTTPD_PLAN_PR_BRANCH="${HTTPD_PLAN_PR_BRANCH:-cursor/httpd-plan-continue}"

IDLE_SEC="${PLAN_LOOP_IDLE_SEC:-1800}"
BATCH_MAX="${PLAN_LOOP_BATCH_MAX:-30}"
RETRY_SEC="${PLAN_LOOP_RETRY_SEC:-120}"
LOG="$LOG_DIR/continuous.log"

log() { echo "[$(date -Iseconds)] $*" | tee -a "$LOG"; }

log "httpd continuous supervisor start branch=$HTTPD_PLAN_PR_BRANCH idle=${IDLE_SEC}s"

while true; do
  if [[ -f "$DISABLE" ]]; then
    log "DISABLE_AUTOSTART — supervisor exit"
    exit 0
  fi

  if ! python3 "$LOOP" --status >>"$LOG" 2>&1; then
    log "idle — no open todos; sleeping ${IDLE_SEC}s"
    sleep "$IDLE_SEC"
    continue
  fi

  STAMP="$(date -u +%Y%m%d-%H%M%S)"
  BATCH_LOG="$LOG_DIR/batch-${STAMP}.log"
  log "batch start → $BATCH_LOG"
  set +e
  python3 "$LOOP" --max "$BATCH_MAX" 2>&1 | tee -a "$BATCH_LOG"
  rc=${PIPESTATUS[0]}
  set -e
  log "batch exit $rc"
  if [[ "$rc" -ne 0 ]]; then
    sleep "$RETRY_SEC"
  else
    sleep 30
  fi
done
