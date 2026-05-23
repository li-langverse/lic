#!/usr/bin/env bash
# systemd ExecStart: run httpd continuous supervisor.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE_DIR="$ROOT/data/httpd-plan-loop"
DISABLE="$STATE_DIR/DISABLE_AUTOSTART"
ENV_SNIPPET="$STATE_DIR/env.sh"
ENV_FILE="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"

mkdir -p "$STATE_DIR"
log() { echo "[httpd-systemd] $*" | tee -a "$STATE_DIR/systemd-wrap.log"; }

if [[ -f "$DISABLE" ]]; then
  log "DISABLE_AUTOSTART — exit 0"
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

export HTTPD_PLAN_WAIT_FOR_LOOP="${HTTPD_PLAN_WAIT_FOR_LOOP:-1}"
if [[ "$HTTPD_PLAN_WAIT_FOR_LOOP" == "1" ]]; then
  while pgrep -f 'httpd-plan-loop.py' >/dev/null 2>&1; do
    sleep 15
  done
fi

log "starting httpd continuous supervisor"
cd "$ROOT"
exec ./scripts/httpd-plan-continuous.sh
