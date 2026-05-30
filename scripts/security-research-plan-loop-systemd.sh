#!/usr/bin/env bash
export GOAL_PLAN_ID="security-research"
export GOAL_PLAN_RUN_SCRIPT="scripts/security-research-run-until-done.sh"
export GOAL_PLAN_DATA_DIR="$(cd "$(dirname "$0")/.." && pwd)/../lic-worktrees/security-research/data/security-research-loop"
export GOAL_PLAN_BRANCH="${SECURITY_RESEARCH_PR_BRANCH:-cursor/security-research-loop}"
export GOAL_PLAN_WORKTREE="${SECURITY_RESEARCH_WORKTREE:-$(cd "$(dirname "$0")/.." && pwd)/../lic-worktrees/security-research}"
export GOAL_PLAN_IDLE_SEC="${SECURITY_RESEARCH_IDLE_SEC:-600}"
exec "$(cd "$(dirname "$0")" && pwd)/lib/goal-plan-systemd-wrapper.sh"
