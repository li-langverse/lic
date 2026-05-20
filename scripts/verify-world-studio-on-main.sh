#!/usr/bin/env bash
# After merging World Studio to main: run full preflight (optional CI hook).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

BRANCH="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo unknown)"
if [[ "$BRANCH" != "main" ]]; then
  echo "Branch is '$BRANCH' (expected main). Run ./scripts/merge-world-studio-preflight.sh on any branch." >&2
  exit 1
fi

li_banner "World Studio verify on main"
"$ROOT/scripts/merge-world-studio-preflight.sh"
li_gate_ok "main branch World Studio OK"
