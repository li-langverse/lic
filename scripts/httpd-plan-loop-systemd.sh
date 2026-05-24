#!/usr/bin/env bash
export GOAL_PLAN_ID="httpd"
export GOAL_PLAN_RUN_SCRIPT="scripts/httpd-plan-until-deadline.sh"
export GOAL_PLAN_DATA_DIR="$(cd "$(dirname "$0")/.." && pwd)/data/httpd-plan-loop"
export GOAL_PLAN_BRANCH="${HTTPD_PLAN_PR_BRANCH:-cursor/httpd-plan-continue}"
export GOAL_PLAN_WORKTREE="${HTTPD_PLAN_WORKTREE:-$(cd "$(dirname "$0")/.." && pwd)/../lic-worktrees/httpd}"
exec "$(cd "$(dirname "$0")" && pwd)/lib/goal-plan-systemd-wrapper.sh"
