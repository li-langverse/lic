#!/usr/bin/env bash
# Run compiler+Studio plan loop continuously; idle-sleep when no open todos.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT/data/compiler-studio-plan-loop"
LOCK="$LOG_DIR/.systemd.lock"
ENV_SNIPPET="$LOG_DIR/env.sh"
ENV_FILE="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"
DISABLE="$LOG_DIR/DISABLE_AUTOSTART"
LOOP="$ROOT/scripts/compiler-studio-plan-loop.py"

mkdir -p "$LOG_DIR"
exec 8>"$LOCK"
if ! flock -n 8; then
  echo "compiler-studio-plan-continuous: already running — exit" >&2
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

export PATH="${HOME}/.local/node/bin:${HOME}/.local/bin:${PATH:-/usr/bin:/bin}"
export LI_CURSOR_AGENTS_ROOT="${LI_CURSOR_AGENTS_ROOT:-$ROOT/../li-cursor-agents}"
export BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-$ROOT/../benchmarks}"
export LIC_ROOT="$ROOT"
export LLVM_DIR="${LLVM_DIR:-/usr/lib/llvm-22/lib/cmake/llvm}"
export CC="${CC:-clang-22}"
export CXX="${CXX:-clang++-22}"
export COMPILER_STUDIO_PR_BRANCH="${COMPILER_STUDIO_PR_BRANCH:-cursor/compiler-studio-plan-loop}"

IDLE_SEC="${PLAN_LOOP_IDLE_SEC:-1800}"
BATCH_MAX="${PLAN_LOOP_BATCH_MAX:-30}"
RETRY_SEC="${PLAN_LOOP_RETRY_SEC:-120}"
LOG="$LOG_DIR/continuous.log"

log() { echo "[$(date -Iseconds)] $*" | tee -a "$LOG"; }

log "continuous supervisor start branch=$COMPILER_STUDIO_PR_BRANCH idle=${IDLE_SEC}s batch=$BATCH_MAX"

while true; do
  if [[ -f "$DISABLE" ]]; then
    log "DISABLE_AUTOSTART — supervisor exit"
    exit 0
  fi

  if ! python3 "$LOOP" --status >>"$LOG" 2>&1; then
    log "idle — no open todos; sleeping ${IDLE_SEC}s (add plan todos or rm DISABLE_AUTOSTART)"
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
    log "retry in ${RETRY_SEC}s"
    sleep "$RETRY_SEC"
  else
    sleep 30
  fi
done
