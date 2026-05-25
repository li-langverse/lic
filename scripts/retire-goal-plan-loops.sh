#!/usr/bin/env bash
# Retire lic goal-plan systemd loops in favor of li-cursor-agents async swarm goals.
# Default: dry-run. --apply: touch DISABLE_AUTOSTART + disable units (does not systemctl stop).
#
#   ./scripts/retire-goal-plan-loops.sh
#   ./scripts/retire-goal-plan-loops.sh --apply
#   ./scripts/backup-swarm-state.sh   # recommended before --apply
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APPLY=0
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=1
elif [[ -n "${1:-}" ]]; then
  echo "usage: $0 [--apply]" >&2
  exit 2
fi

# plan_id|systemd_unit|data_dir (relative to ROOT unless absolute)
plan_row() {
  case "$1" in
    sim-algo)
      echo "li-sim-algo-plan-loop|../lic-worktrees/sim-algo/data/sim-plan-loop"
      ;;
    httpd)
      echo "li-httpd-plan-loop|data/httpd-plan-loop"
      ;;
    compiler-studio)
      echo "li-compiler-studio-plan-loop|../lic-worktrees/compiler-studio/data/compiler-studio-plan-loop"
      ;;
    studio-ui-ux)
      echo "li-studio-ui-ux-plan-loop|../lic-studio-ui/data/studio-ui-ux-plan-loop"
      ;;
    sim-md-research)
      echo "li-sim-md-research-plan-loop|../lic-worktrees/sim-md-research/data/sim-md-research-loop"
      ;;
    sim-chem-research)
      echo "li-sim-chem-research-plan-loop|../lic-worktrees/sim-chem-research/data/sim-chem-research-loop"
      ;;
    security-research)
      echo "li-security-research-plan-loop|../lic-worktrees/security-research/data/security-research-loop"
      ;;
    swarm-observer)
      echo "li-swarm-observer-plan-loop|data/swarm-observer-plan-loop"
      ;;
    *)
      return 1
      ;;
  esac
}

resolve_data_dir() {
  local rel="$1"
  if [[ "$rel" == /* ]]; then
    echo "$rel"
    return
  fi
  local base dir
  base="$(dirname "$rel")"
  dir="$(basename "$rel")"
  if [[ "$base" == "." ]]; then
    echo "$ROOT/$dir"
  else
    echo "$(cd "$ROOT" && cd "$base" 2>/dev/null && pwd)/$dir"
  fi
}

PLAN_IDS=(sim-algo httpd compiler-studio studio-ui-ux sim-md-research sim-chem-research security-research swarm-observer)

echo "retire-goal-plan-loops: mode=$([[ $APPLY -eq 1 ]] && echo apply || echo dry-run)"
echo "  lic root: $ROOT"
echo "  swarm doc: li-cursor-agents/docs/ecosystem/swarm-architecture.md"
echo ""

for id in "${PLAN_IDS[@]}"; do
  line="$(plan_row "$id")"
  unit="${line%%|*}"
  data_rel="${line#*|}"
  data_dir="$(resolve_data_dir "$data_rel")"
  disable_file="${data_dir}/DISABLE_AUTOSTART"
  unit_file="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/${unit}.service"

  active="unknown"
  if command -v systemctl >/dev/null 2>&1; then
    if systemctl --user is-active "${unit}.service" >/dev/null 2>&1; then
      active="$(systemctl --user is-active "${unit}.service" 2>/dev/null || echo unknown)"
    else
      active="inactive"
    fi
  fi

  echo "[$id] unit=${unit}.service active=${active}"
  echo "  data_dir: ${data_dir}"
  if [[ -f "$disable_file" ]]; then
    echo "  DISABLE_AUTOSTART: already present"
  elif [[ $APPLY -eq 1 ]]; then
    mkdir -p "$data_dir"
    touch "$disable_file"
    echo "  DISABLE_AUTOSTART: created"
  else
    echo "  would: mkdir -p ${data_dir} && touch ${disable_file}"
  fi

  if [[ -f "$unit_file" ]]; then
    if [[ $APPLY -eq 1 ]]; then
      systemctl --user disable "${unit}.service" 2>/dev/null || true
      echo "  systemctl --user disable ${unit}.service"
    else
      echo "  would: systemctl --user disable ${unit}.service"
    fi
  else
    echo "  unit file: not installed (${unit_file})"
  fi
  echo ""
done

if [[ $APPLY -eq 0 ]]; then
  echo "Dry-run complete. Re-run with --apply after backup-swarm-state.sh."
  echo "Note: --apply does not systemctl stop; loops exit gracefully on DISABLE_AUTOSTART."
else
  echo "Apply complete. Plan loops will not autostart; running instances exit on next wrapper check."
fi
