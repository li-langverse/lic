#!/usr/bin/env bash
# systemd ExecStart wrapper for httpd plan loop (disable file, daily/ISO deadline, flock).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE_DIR="$ROOT/data/httpd-plan-loop"
DISABLE="$STATE_DIR/DISABLE_AUTOSTART"
LOCK="$STATE_DIR/.systemd.lock"
ENV_SNIPPET="$STATE_DIR/env.sh"
ENV_FILE="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"

mkdir -p "$STATE_DIR"

log() { echo "[httpd-systemd] $*" | tee -a "$STATE_DIR/systemd-wrap.log"; }

if [[ -f "$DISABLE" ]]; then
  log "DISABLE_AUTOSTART present — exit 0"
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

export TZ="${HTTPD_PLAN_TZ:-Europe/Berlin}"
DEADLINE_LOCAL="${HTTPD_PLAN_UNTIL_LOCAL:-08:00}"
if [[ -n "${HTTPD_PLAN_UNTIL_ISO:-}" ]]; then
  DEADLINE_TS="$(date -d "$HTTPD_PLAN_UNTIL_ISO" +%s)"
else
  now="$(date +%s)"
  today="$(date -d "today ${DEADLINE_LOCAL}" +%s)"
  if [[ "$today" -gt "$now" ]]; then
    DEADLINE_TS="$today"
  else
    DEADLINE_TS="$(date -d "tomorrow ${DEADLINE_LOCAL}" +%s)"
  fi
fi

now="$(date +%s)"
if [[ "$now" -ge "$DEADLINE_TS" ]]; then
  log "past deadline — exit 0"
  exit 0
fi

exec 9>"$LOCK"
if ! flock -n 9; then
  log "another instance holds flock — exit 0"
  exit 0
fi

log "starting httpd overnight (deadline $(date -d "@${DEADLINE_TS}" -Iseconds))"
export HTTPD_PLAN_WAIT_FOR_LOOP="${HTTPD_PLAN_WAIT_FOR_LOOP:-1}"
cd "$ROOT"
exec ./scripts/httpd-plan-overnight.sh
