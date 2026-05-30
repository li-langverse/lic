#!/usr/bin/env bash
# httpd plan runs on lic main checkout (cursor/httpd-plan-continue) — no separate worktree.
export GOAL_PLAN_ID="httpd"
export GOAL_PLAN_RUN_SCRIPT="scripts/httpd-plan-until-deadline.sh"
export GOAL_PLAN_DATA_DIR="$(cd "$(dirname "$0")/.." && pwd)/data/httpd-plan-loop"
export GOAL_PLAN_IDLE_SEC="${HTTPD_PLAN_IDLE_SEC:-600}"
export GOAL_PLAN_FAIL_SEC="${HTTPD_PLAN_FAIL_SEC:-120}"
export LI_CONTROL_PLANE_STORE="${LI_CONTROL_PLANE_STORE:-disk}"
exec "$(cd "$(dirname "$0")" && pwd)/lib/goal-plan-systemd-wrapper.sh"
