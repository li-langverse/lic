#!/usr/bin/env bash
# Run ph-ml-gpu-hw-plan-loop in batches until duration elapses (default 120 min).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT/data/ph-ml-gpu-hw-plan-loop"
mkdir -p "$LOG_DIR"
STAMP="$(date -u +%Y%m%d-%H%M%S)"
LOG="$LOG_DIR/until-duration-${STAMP}.log"
ln -sfn "$(basename "$LOG")" "$LOG_DIR/until-duration-latest.log"

ENV_FILE="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +a
fi

export PATH="${HOME}/.local/node/bin:${PATH:-/usr/bin:/bin}"
export LI_CURSOR_AGENTS_ROOT="${LI_CURSOR_AGENTS_ROOT:-$ROOT/../li-cursor-agents}"
export BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-$ROOT/../benchmarks}"
export LIC_ROOT="$ROOT"
export CUDA_HOME="${CUDA_HOME:-/usr/lib/cuda}"
export PATH="$CUDA_HOME/bin:$PATH"
export PH_ML_GPU_HW_PR_BRANCH="${PH_ML_GPU_HW_PR_BRANCH:-feat/ph-ml-gpu-swarm}"
export LI_PH_ML_GPU_HW_AGENT="${LI_PH_ML_GPU_HW_AGENT:-code_implementer}"
export LI_PH_ML_GPU_HW_AGENT_TIMEOUT_SEC="${LI_PH_ML_GPU_HW_AGENT_TIMEOUT_SEC:-2400}"
export LI_CONTROL_PLANE_STORE="${LI_CONTROL_PLANE_STORE:-disk}"

DURATION_MIN="${PH_ML_GPU_HW_DURATION_MIN:-120}"
BATCH_CAP="${PH_ML_GPU_HW_BATCH_CAP:-24}"
MIN_BATCH="${PH_ML_GPU_HW_MIN_BATCH:-1}"
MIN_PER_ITER="${PH_ML_GPU_HW_MIN_PER_ITER:-25}"
WAIT_FOR_LOOP="${PH_ML_GPU_HW_WAIT_FOR_LOOP:-1}"

START_TS="$(date +%s)"
DEADLINE_TS=$((START_TS + DURATION_MIN * 60))

log() { echo "$@" | tee -a "$LOG"; }

log "==> ph-ml-gpu-hw-until-duration $(date -Iseconds)"
log "    duration=${DURATION_MIN}m deadline=$(date -d "@${DEADLINE_TS}" -Iseconds)"
log "    branch=$PH_ML_GPU_HW_PR_BRANCH CUDA_HOME=$CUDA_HOME"
log "    log=$LOG"

if [[ "$WAIT_FOR_LOOP" == "1" ]]; then
  log "==> waiting for in-flight ph-ml-gpu-hw-plan-loop.py…"
  while pgrep -f 'ph-ml-gpu-hw-plan-loop.py' >/dev/null 2>&1; do
    sleep 20
  done
fi

cd "$ROOT"
git fetch origin "$PH_ML_GPU_HW_PR_BRANCH" 2>/dev/null || true
git pull --ff-only origin "$PH_ML_GPU_HW_PR_BRANCH" 2>/dev/null || true

BATCH_N=0
while true; do
  now="$(date +%s)"
  if [[ "$now" -ge "$DEADLINE_TS" ]]; then
    log "==> duration reached $(date -Iseconds) — stop"
    break
  fi
  remaining_sec=$((DEADLINE_TS - now))
  if [[ "$remaining_sec" -lt 300 ]]; then
    log "==> <5m left — stop"
    break
  fi
  remaining_min=$((remaining_sec / 60))
  batch=$((remaining_min / MIN_PER_ITER))
  [[ "$batch" -lt "$MIN_BATCH" ]] && batch="$MIN_BATCH"
  [[ "$batch" -gt "$BATCH_CAP" ]] && batch="$BATCH_CAP"
  BATCH_N=$((BATCH_N + 1))
  log ""
  log "==> batch ${BATCH_N} @ $(date -Iseconds) — --max ${batch} (~${remaining_min}m left)"
  set +e
  python3 "$ROOT/scripts/ph-ml-gpu-hw-plan-loop.py" --max "$batch" 2>&1 | tee -a "$LOG"
  rc=${PIPESTATUS[0]}
  set -e
  log "==> batch ${BATCH_N} exit ${rc}"
  if [[ "$rc" -ne 0 ]]; then
    sleep 90
  else
    sleep 20
  fi
done

log "==> until-duration done $(date -Iseconds)"
