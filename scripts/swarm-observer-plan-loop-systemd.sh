#!/usr/bin/env bash
export GOAL_PLAN_ID="swarm-observer"
export GOAL_PLAN_RUN_SCRIPT="scripts/swarm-observer-plan-run-until-done.sh"
export GOAL_PLAN_DATA_DIR="$(cd "$(dirname "$0")/.." && pwd)/data/swarm-observer-plan-loop"
export GOAL_PLAN_BRANCH="${SWARM_OBSERVER_PR_BRANCH:-cursor/swarm-observer-plan-loop}"
export GOAL_PLAN_WORKTREE="${SWARM_OBSERVER_WORKTREE:-$(cd "$(dirname "$0")/.." && pwd)}"
export GOAL_PLAN_IDLE_SEC="${SWARM_OBSERVER_IDLE_SEC:-600}"
exec "$(cd "$(dirname "$0")" && pwd)/lib/goal-plan-systemd-wrapper.sh"
