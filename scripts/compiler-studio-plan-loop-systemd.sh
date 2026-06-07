#!/usr/bin/env bash
export GOAL_PLAN_ID="compiler-studio"
export GOAL_PLAN_RUN_SCRIPT="scripts/compiler-studio-plan-until-deadline.sh"
export GOAL_PLAN_DATA_DIR="$(cd "$(dirname "$0")/.." && pwd)/../lic-worktrees/compiler-studio/data/compiler-studio-plan-loop"
export GOAL_PLAN_BRANCH="${COMPILER_STUDIO_PR_BRANCH:-cursor/compiler-studio-plan-loop}"
export GOAL_PLAN_WORKTREE="${COMPILER_STUDIO_WORKTREE:-$(cd "$(dirname "$0")/.." && pwd)/../lic-worktrees/compiler-studio}"
exec "$(cd "$(dirname "$0")" && pwd)/lib/goal-plan-systemd-wrapper.sh"
