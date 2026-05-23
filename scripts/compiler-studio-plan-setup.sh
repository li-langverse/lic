#!/usr/bin/env bash
# Setup compiler+Studio plan loop env + optional systemd autostart on reboot.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LANGVERSE="$(cd "$ROOT/.." && pwd)"
CURSOR_ENV="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"
ENV_ONLY=0

for arg in "$@"; do
  [[ "$arg" == "--env-only" ]] && ENV_ONLY=1
done

echo "==> compiler-studio-plan-setup"
mkdir -p "$ROOT/data/compiler-studio-plan-loop"

if [[ -f "$CURSOR_ENV" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$CURSOR_ENV"
  set +a
fi

AGENTS="${LI_CURSOR_AGENTS_ROOT:-$LANGVERSE/li-cursor-agents}"
BENCH="${BENCHMARKS_ROOT:-$LANGVERSE/benchmarks}"
ENV_SNIPPET="$ROOT/data/compiler-studio-plan-loop/env.sh"

cat >"$ENV_SNIPPET" <<EOF
# Source: source data/compiler-studio-plan-loop/env.sh
export PATH="\${HOME}/.local/node/bin:\${HOME}/.local/bin:\${PATH}"
export LLVM_DIR="\${LLVM_DIR:-/usr/lib/llvm-22/lib/cmake/llvm}"
export CC="\${CC:-clang-22}"
export CXX="\${CXX:-clang++-22}"
export LI_CURSOR_AGENTS_ROOT="$AGENTS"
export BENCHMARKS_ROOT="$BENCH"
export LIC_ROOT="$ROOT"
export COMPILER_STUDIO_PR_BRANCH="\${COMPILER_STUDIO_PR_BRANCH:-cursor/compiler-studio-plan-loop}"
export PLAN_LOOP_IDLE_SEC="\${PLAN_LOOP_IDLE_SEC:-1800}"
export PLAN_LOOP_BATCH_MAX="\${PLAN_LOOP_BATCH_MAX:-30}"
export PLAN_LOOP_RETRY_SEC="\${PLAN_LOOP_RETRY_SEC:-120}"
export COMPILER_STUDIO_GATES_SKIP_LIC_BUILD="\${COMPILER_STUDIO_GATES_SKIP_LIC_BUILD:-0}"
export COMPILER_STUDIO_REFRESH_PAGES="\${COMPILER_STUDIO_REFRESH_PAGES:-0}"
export LI_COMPILER_STUDIO_PLAN_AGENT="\${LI_COMPILER_STUDIO_PLAN_AGENT:-code_implementer}"
export LI_COMPILER_STUDIO_PLAN_AGENT_TIMEOUT_SEC="\${LI_COMPILER_STUDIO_PLAN_AGENT_TIMEOUT_SEC:-2700}"
export LI_CONTROL_PLANE_STORE="\${LI_CONTROL_PLANE_STORE:-disk}"
export HTTPD_PLAN_TZ="\${HTTPD_PLAN_TZ:-Europe/Berlin}"
export GH_TOKEN="\${GH_TOKEN:-}"
export CURSOR_API_KEY="\${CURSOR_API_KEY:-}"
if [[ -f "$CURSOR_ENV" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$CURSOR_ENV"
  set +a
fi
EOF
chmod 644 "$ENV_SNIPPET"
echo "  wrote $ENV_SNIPPET"

[[ "$ENV_ONLY" == "1" ]] && exit 0

git -C "$ROOT" fetch origin 2>/dev/null || true
git -C "$ROOT" checkout cursor/compiler-studio-plan-loop 2>/dev/null || true

echo ""
echo "Autostart on reboot (recommended for weekend run):"
echo "  ./scripts/install-plan-loop-systemd.sh"
echo ""
echo "Manual continuous loop:"
echo "  source data/compiler-studio-plan-loop/env.sh"
echo "  ./scripts/compiler-studio-plan-continuous.sh"
