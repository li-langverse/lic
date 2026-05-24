#!/usr/bin/env bash
export GOAL_PLAN_ID="sim-algo"
export GOAL_PLAN_RUN_SCRIPT="scripts/sim-plan-run-until-done.sh"
export GOAL_PLAN_DATA_DIR="$(cd "$(dirname "$0")/.." && pwd)/data/sim-plan-loop"
export GOAL_PLAN_BRANCH="${SIM_PLAN_PR_BRANCH:-cursor/sim-algo-plan-loop}"
export GOAL_PLAN_WORKTREE="${SIM_PLAN_WORKTREE:-$(cd "$(dirname "$0")/.." && pwd)/../lic-worktrees/sim-algo}"
export GOAL_PLAN_IDLE_SEC="${SIM_PLAN_IDLE_SEC:-600}"
exec "$(cd "$(dirname "$0")" && pwd)/lib/goal-plan-systemd-wrapper.sh"
