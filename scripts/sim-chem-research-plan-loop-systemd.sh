#!/usr/bin/env bash
export GOAL_PLAN_ID="sim-chem-research"
export GOAL_PLAN_RUN_SCRIPT="scripts/sim-algo-research-run-until-done.sh"
export GOAL_PLAN_DATA_DIR="$(cd "$(dirname "$0")/.." && pwd)/../lic-worktrees/sim-chem-research/data/sim-chem-research-loop"
export GOAL_PLAN_BRANCH="${SIM_RESEARCH_PR_BRANCH:-cursor/sim-chem-research-loop}"
export GOAL_PLAN_WORKTREE="${SIM_RESEARCH_WORKTREE:-$(cd "$(dirname "$0")/.." && pwd)/../lic-worktrees/sim-chem-research}"
export GOAL_PLAN_IDLE_SEC="${SIM_RESEARCH_IDLE_SEC:-600}"
export SIM_RESEARCH_VERTICAL=chem
exec "$(cd "$(dirname "$0")" && pwd)/lib/goal-plan-systemd-wrapper.sh"
