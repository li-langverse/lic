#!/usr/bin/env bash
# Weekend / overnight: compiler+Studio plan loop until next Monday 08:00 (COMPILER_STUDIO_WEEKEND_MODE=1).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT/data/compiler-studio-plan-loop"
mkdir -p "$LOG_DIR"
LOCK="$LOG_DIR/.systemd.lock"
exec 8>"$LOCK"
if ! flock -n 8; then
  echo "compiler-studio-plan-overnight: another instance running (flock $LOCK) — exit" >&2
  exit 0
fi
STAMP="$(date -u +%Y%m%d-%H%M%S)"
LOG="$LOG_DIR/overnight-${STAMP}.log"

ENV_FILE="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"
if [[ -f "$ENV_FILE" ]]; then
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
export COMPILER_STUDIO_GATES_SKIP_LIC_BUILD="${COMPILER_STUDIO_GATES_SKIP_LIC_BUILD:-0}"
export COMPILER_STUDIO_REFRESH_PAGES="${COMPILER_STUDIO_REFRESH_PAGES:-0}"
export LI_COMPILER_STUDIO_PLAN_AGENT="${LI_COMPILER_STUDIO_PLAN_AGENT:-code_implementer}"
export LI_COMPILER_STUDIO_PLAN_AGENT_TIMEOUT_SEC="${LI_COMPILER_STUDIO_PLAN_AGENT_TIMEOUT_SEC:-2700}"
export LI_CONTROL_PLANE_STORE="${LI_CONTROL_PLANE_STORE:-disk}"
export COMPILER_STUDIO_WEEKEND_MODE="${COMPILER_STUDIO_WEEKEND_MODE:-1}"
export HTTPD_PLAN_WAIT_FOR_LOOP="${HTTPD_PLAN_WAIT_FOR_LOOP:-1}"

HTTPD_PLAN_TZ="${HTTPD_PLAN_TZ:-Europe/Berlin}"
export TZ="$HTTPD_PLAN_TZ"

echo "==> compiler-studio-plan-overnight $(date -Iseconds) TZ=$TZ"
echo "    weekend_mode=$COMPILER_STUDIO_WEEKEND_MODE → next Monday ${HTTPD_PLAN_UNTIL_LOCAL:-08:00}"
echo "    branch=$COMPILER_STUDIO_PR_BRANCH log=$LOG"

chmod +x "$ROOT/scripts/compiler-studio-plan-until-deadline.sh"

if [[ "${HTTPD_PLAN_NO_UNTIL_DEADLINE:-0}" == "1" ]]; then
  MAX="${HTTPD_PLAN_OVERNIGHT_MAX:-999}"
  exec python3 "$ROOT/scripts/compiler-studio-plan-loop.py" --max "$MAX" 2>&1 | tee -a "$LOG"
fi

exec "$ROOT/scripts/compiler-studio-plan-until-deadline.sh" 2>&1 | tee -a "$LOG"
