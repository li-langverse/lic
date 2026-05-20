#!/usr/bin/env bash
# Create draft PR for World Studio branch (requires gh auth).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

li_banner "World Studio PR"

"$ROOT/scripts/merge-world-studio-preflight.sh"

BRANCH="$(git -C "$ROOT" branch --show-current)"
if [[ "$BRANCH" != "feat/world-studio-impl-1" ]]; then
  echo "Expected branch feat/world-studio-impl-1 (current: $BRANCH)" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Install GitHub CLI (gh) or open PR manually — see docs/game-dev/MERGE-PR-world-studio.md" >&2
  exit 1
fi

gh pr create \
  --base main \
  --head feat/world-studio-impl-1 \
  --title "feat: World Studio / Li Engine (130 gates, play_mode)" \
  --body-file "$ROOT/docs/game-dev/PR-world-studio-impl-summary.md" \
  --draft

li_gate_ok "draft PR created (or already exists)"
