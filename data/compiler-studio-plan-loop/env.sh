# Source: source data/compiler-studio-plan-loop/env.sh
export PATH="${HOME}/.local/node/bin:${HOME}/.local/bin:${PATH}"
export LLVM_DIR="${LLVM_DIR:-/usr/lib/llvm-22/lib/cmake/llvm}"
export CC="${CC:-clang-22}"
export CXX="${CXX:-clang++-22}"
export LI_CURSOR_AGENTS_ROOT="/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents"
export BENCHMARKS_ROOT="/home/s4il0r/Documents/Cursor/li-langverse/benchmarks"
export LIC_ROOT="/home/s4il0r/Documents/Cursor/li-langverse/lic"
export COMPILER_STUDIO_PR_BRANCH="${COMPILER_STUDIO_PR_BRANCH:-cursor/compiler-studio-plan-loop}"
export COMPILER_STUDIO_WEEKEND_MODE="${COMPILER_STUDIO_WEEKEND_MODE:-1}"
export COMPILER_STUDIO_GATES_SKIP_LIC_BUILD="${COMPILER_STUDIO_GATES_SKIP_LIC_BUILD:-0}"
export COMPILER_STUDIO_REFRESH_PAGES="${COMPILER_STUDIO_REFRESH_PAGES:-0}"
export LI_COMPILER_STUDIO_PLAN_AGENT="${LI_COMPILER_STUDIO_PLAN_AGENT:-code_implementer}"
export LI_COMPILER_STUDIO_PLAN_AGENT_TIMEOUT_SEC="${LI_COMPILER_STUDIO_PLAN_AGENT_TIMEOUT_SEC:-2700}"
export LI_CONTROL_PLANE_STORE="${LI_CONTROL_PLANE_STORE:-disk}"
export HTTPD_PLAN_TZ="${HTTPD_PLAN_TZ:-Europe/Berlin}"
export GH_TOKEN="${GH_TOKEN:-}"
export CURSOR_API_KEY="${CURSOR_API_KEY:-}"
if [[ -f "/home/s4il0r/Documents/Cursor/.env" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "/home/s4il0r/Documents/Cursor/.env"
  set +a
fi
