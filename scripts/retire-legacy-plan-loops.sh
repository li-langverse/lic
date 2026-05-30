#!/usr/bin/env bash
# Retire competing lic systemd plan loops; keep async swarm + swarm-observer + sim research worktrees.
# Wraps retire-goal-plan-loops.sh with a safe default plan list (WP-AGT-05).
#
#   ./scripts/retire-legacy-plan-loops.sh           # dry-run
#   ./scripts/retire-legacy-plan-loops.sh --apply
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APPLY=0
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=1
elif [[ -n "${1:-}" ]]; then
  echo "usage: $0 [--apply]" >&2
  exit 2
fi

# Retire product implement loops migrated to li-cursor-agents async swarm.
# Keep: swarm-observer, sim-md-research, sim-chem-research, security-research (research worktrees).
LEGACY_PLANS=(sim-algo httpd compiler-studio studio-ui-ux)

echo "retire-legacy-plan-loops: mode=$([[ $APPLY -eq 1 ]] && echo apply || echo dry-run)"
echo "  retiring: ${LEGACY_PLANS[*]}"
echo "  keeping: swarm-observer + sim/security research worktree loops"
echo ""

for id in "${LEGACY_PLANS[@]}"; do
  if [[ $APPLY -eq 1 ]]; then
    "$ROOT/scripts/retire-goal-plan-loops.sh" --apply --only "$id"
  else
    "$ROOT/scripts/retire-goal-plan-loops.sh" --only "$id"
  fi
done

if [[ $APPLY -eq 0 ]]; then
  echo "Dry-run complete. Re-run with --apply after backup-swarm-state.sh."
else
  echo "Legacy plan loops disabled. Async swarm + swarm-observer remain."
fi
