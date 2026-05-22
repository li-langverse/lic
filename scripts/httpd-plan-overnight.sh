#!/usr/bin/env bash
# Overnight goal-directed httpd plan loop.
# Default: first batch (HTTPD_PLAN_OVERNIGHT_MAX), then more batches until 08:00 local.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT/data/httpd-plan-loop"
mkdir -p "$LOG_DIR"
STAMP="$(date -u +%Y%m%d-%H%M%S)"
LOG="$LOG_DIR/overnight-${STAMP}.log"

ENV_FILE="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"
if [[ -f "$ENV_FILE" ]]; then
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
export HTTPD_GATES_SKIP_LIC_BUILD="${HTTPD_GATES_SKIP_LIC_BUILD:-1}"
export HTTPD_RUN_BEARER_TEST="${HTTPD_RUN_BEARER_TEST:-0}"
export HTTPD_REFRESH_PAGES="${HTTPD_REFRESH_PAGES:-1}"
export HTTPD_PAGES_SKIP_BENCH="${HTTPD_PAGES_SKIP_BENCH:-1}"
export LI_HTTPD_PLAN_AGENT="${LI_HTTPD_PLAN_AGENT:-code_implementer}"
export LI_HTTPD_PLAN_AGENT_TIMEOUT_SEC="${LI_HTTPD_PLAN_AGENT_TIMEOUT_SEC:-2700}"
export LI_CONTROL_PLANE_STORE="${LI_CONTROL_PLANE_STORE:-disk}"

HTTPD_PLAN_TZ="${HTTPD_PLAN_TZ:-Europe/Berlin}"
export TZ="$HTTPD_PLAN_TZ"
MAX="${HTTPD_PLAN_OVERNIGHT_MAX:-30}"
# Set HTTPD_PLAN_NO_UNTIL_DEADLINE=1 to run only the first --max batch.
RUN_UNTIL="${HTTPD_PLAN_NO_UNTIL_DEADLINE:-0}"

{
  echo "==> httpd-plan-overnight start $(date -Iseconds)"
  echo "    branch=$HTTPD_PLAN_PR_BRANCH max=$MAX log=$LOG"
  echo "    TZ=${TZ} until_local=${HTTPD_PLAN_UNTIL_LOCAL:-08:00} (unless NO_UNTIL_DEADLINE=1)"
  echo "    agents=$LI_CURSOR_AGENTS_ROOT benchmarks=$BENCHMARKS_ROOT"
  cd "$ROOT"
  git branch --show-current || true
  python3 "$ROOT/scripts/httpd-plan-loop.py" --max "$MAX"
} 2>&1 | tee -a "$LOG"

echo "==> first batch done $(date -u -Iseconds) — log: $LOG"

if [[ "$RUN_UNTIL" == "1" ]]; then
  echo "==> HTTPD_PLAN_NO_UNTIL_DEADLINE=1 — skipping until-deadline extension"
  exit 0
fi

export HTTPD_PLAN_WAIT_FOR_LOOP=0
exec "$ROOT/scripts/httpd-plan-until-deadline.sh" 2>&1 | tee -a "$LOG"
