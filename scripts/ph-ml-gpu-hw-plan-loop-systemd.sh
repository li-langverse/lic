#!/usr/bin/env bash
# PH-ML GPU hardware CUDA sprint — isolated worktree + duration supervisor.
export GOAL_PLAN_ID="ph-ml-gpu-hw"
export GOAL_PLAN_RUN_SCRIPT="scripts/ph-ml-gpu-hw-until-duration.sh"
export GOAL_PLAN_DATA_DIR="$(cd "$(dirname "$0")/.." && pwd)/data/ph-ml-gpu-hw-plan-loop"
export GOAL_PLAN_WORKTREE="${PH_ML_GPU_HW_WORKTREE:-/tmp/lic-ph-ml-gpu}"
export GOAL_PLAN_BRANCH="${PH_ML_GPU_HW_PR_BRANCH:-feat/ph-ml-gpu-swarm}"
export GOAL_PLAN_IDLE_SEC="${PH_ML_GPU_HW_IDLE_SEC:-7200}"
export GOAL_PLAN_FAIL_SEC="${PH_ML_GPU_HW_FAIL_SEC:-120}"
export PH_ML_GPU_HW_DURATION_MIN="${PH_ML_GPU_HW_DURATION_MIN:-120}"
export LI_CONTROL_PLANE_STORE="${LI_CONTROL_PLANE_STORE:-disk}"
exec "$(cd "$(dirname "$0")" && pwd)/lib/goal-plan-systemd-wrapper.sh"
