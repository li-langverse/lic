#!/usr/bin/env bash
# Shared systemd ExecStart wrapper for goal-directed plan loops.
# Required env (set by per-loop wrapper):
#   GOAL_PLAN_ID          — e.g. sim-algo
#   GOAL_PLAN_RUN_SCRIPT  — path under ROOT, e.g. scripts/sim-plan-run-until-done.sh
# Optional:
#   GOAL_PLAN_DATA_DIR    — default data/${GOAL_PLAN_ID}-plan-loop
#   GOAL_PLAN_LOCK        — default /tmp/li-${GOAL_PLAN_ID}-plan-loop.lock
#   GOAL_PLAN_IDLE_SEC    — after successful run (default 1800)
#   GOAL_PLAN_FAIL_SEC    — after failed run (default 300)
#   GOAL_PLAN_WORKTREE    — isolated git worktree (recommended when multiple loops)
#   GOAL_PLAN_BRANCH      — branch for worktree checkout
set -euo pipefail

: "${GOAL_PLAN_ID:?GOAL_PLAN_ID required}"
: "${GOAL_PLAN_RUN_SCRIPT:?GOAL_PLAN_RUN_SCRIPT required}"

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DATA_DIR="${GOAL_PLAN_DATA_DIR:-$ROOT/data/${GOAL_PLAN_ID}-plan-loop}"
DISABLE_FILE="${DATA_DIR}/DISABLE_AUTOSTART"
LOCK="${GOAL_PLAN_LOCK:-/tmp/li-${GOAL_PLAN_ID}-plan-loop.lock}"
IDLE_SEC="${GOAL_PLAN_IDLE_SEC:-1800}"
FAIL_SEC="${GOAL_PLAN_FAIL_SEC:-300}"
ENV_FILE="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"

if [[ -f "$DISABLE_FILE" ]]; then
  echo "goal-plan-systemd[$GOAL_PLAN_ID]: DISABLE_AUTOSTART — exit 0"
  exit 0
fi

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ENV_FILE"
  set +a
fi

export LI_LLVM_MAJOR="${LI_LLVM_MAJOR:-22}"
export PATH="${HOME}/.local/node/bin:${PATH:-/usr/bin:/bin}"
export LI_CURSOR_AGENTS_ROOT="${LI_CURSOR_AGENTS_ROOT:-$ROOT/../li-cursor-agents}"
export LIC_ROOT="$ROOT"
# LLVM/clang for sim + compiler gates (clang-22 etc. on PATH as CC)
if [[ -f "$ROOT/scripts/llvm-env.sh" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT/scripts/llvm-env.sh"
  li_detect_llvm_dir 2>/dev/null || true
  li_detect_compilers 2>/dev/null || true
fi
if [[ -f /etc/profile.d/li-dev.sh ]]; then
  # shellcheck disable=SC1091
  source /etc/profile.d/li-dev.sh
fi

exec 9>"$LOCK"
if ! flock -n 9; then
  echo "goal-plan-systemd[$GOAL_PLAN_ID]: another instance holds $LOCK — exit 0"
  exit 0
fi

run_cwd="$ROOT"
if [[ -n "${GOAL_PLAN_WORKTREE:-}" ]]; then
  run_cwd="$GOAL_PLAN_WORKTREE"
  branch="${GOAL_PLAN_BRANCH:-}"
  if git -C "$run_cwd" rev-parse --git-dir >/dev/null 2>&1; then
    echo "goal-plan-systemd[$GOAL_PLAN_ID]: using checkout $run_cwd"
  else
    mkdir -p "$(dirname "$run_cwd")"
    if [[ -e "$run_cwd" ]]; then
      echo "goal-plan-systemd[$GOAL_PLAN_ID]: $run_cwd exists but is not a git repo — exit 1" >&2
      exit 1
    fi
    echo "goal-plan-systemd[$GOAL_PLAN_ID]: creating worktree $run_cwd"
    if [[ -n "$branch" ]]; then
      git -C "$ROOT" fetch origin "$branch" 2>/dev/null || true
      git -C "$ROOT" worktree add -B "$branch" "$run_cwd" "origin/${branch}" 2>/dev/null \
        || git -C "$ROOT" worktree add "$run_cwd" "$branch"
    else
      git -C "$ROOT" worktree add "$run_cwd"
    fi
  fi
fi

mkdir -p "$DATA_DIR"
run_script="$run_cwd/${GOAL_PLAN_RUN_SCRIPT#"$ROOT"/}"
if [[ ! -x "$run_script" ]] && [[ -f "$ROOT/$GOAL_PLAN_RUN_SCRIPT" ]]; then
  run_script="$ROOT/$GOAL_PLAN_RUN_SCRIPT"
fi

while true; do
  if [[ -f "$DISABLE_FILE" ]]; then
    echo "goal-plan-systemd[$GOAL_PLAN_ID]: DISABLE_AUTOSTART — stopping"
    exit 0
  fi
  if (cd "$run_cwd" && bash "$run_script"); then
    echo "goal-plan-systemd[$GOAL_PLAN_ID]: run complete — idle ${IDLE_SEC}s"
    sleep "$IDLE_SEC"
  else
    echo "goal-plan-systemd[$GOAL_PLAN_ID]: run failed — retry in ${FAIL_SEC}s"
    sleep "$FAIL_SEC"
  fi
done
