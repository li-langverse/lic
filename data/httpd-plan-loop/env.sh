# Source before running httpd-plan-loop:  source data/httpd-plan-loop/env.sh
export PATH="${HOME}/.local/node/bin:${PATH}"
export LI_CURSOR_AGENTS_ROOT="/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents"
export BENCHMARKS_ROOT="/home/s4il0r/Documents/Cursor/li-langverse/benchmarks"
export LIC_ROOT="/home/s4il0r/Documents/Cursor/li-langverse/lic"
export HTTPD_PLAN_PR_BRANCH=cursor/httpd-plan-continue
export LI_REPO_WORKFLOW_BRANCH="${HTTPD_PLAN_PR_BRANCH}"
export LI_REPO_WORKFLOW_TRACK_REMOTE=1
export LI_REPO_WORKFLOW_OPEN_PR=1
export LI_HTTPD_PLAN_CLOSE_SERVER_MILESTONES=1
export HTTPD_GATES_SKIP_LIC_BUILD=${HTTPD_GATES_SKIP_LIC_BUILD:-1}
export HTTPD_RUN_BEARER_TEST=${HTTPD_RUN_BEARER_TEST:-0}
export HTTPD_REFRESH_PAGES=${HTTPD_REFRESH_PAGES:-1}
export HTTPD_PAGES_SKIP_BENCH=${HTTPD_PAGES_SKIP_BENCH:-1}
export LI_HTTPD_PLAN_AGENT=${LI_HTTPD_PLAN_AGENT:-code_implementer}
export LI_HTTPD_PLAN_AGENT_TIMEOUT_SEC=${LI_HTTPD_PLAN_AGENT_TIMEOUT_SEC:-2700}
export LI_CONTROL_PLANE_STORE=${LI_CONTROL_PLANE_STORE:-disk}
export HTTPD_PLAN_TZ=${HTTPD_PLAN_TZ:-Europe/Berlin}
export GH_TOKEN="${GH_TOKEN:-}"
export CURSOR_API_KEY="${CURSOR_API_KEY:-}"
if [[ -f "/home/s4il0r/Documents/Cursor/.env" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "/home/s4il0r/Documents/Cursor/.env"
  set +a
fi
