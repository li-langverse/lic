#!/usr/bin/env bash
# Sync shared agent-kit from sibling roadmap repo into this checkout.
set -euo pipefail
LI_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROADMAP="${LI_ROADMAP_ROOT:-$LI_ROOT/../roadmap}"
INSTALL="$ROADMAP/scripts/install-agent-kit.sh"

if [[ ! -x "$INSTALL" ]]; then
  echo "error: roadmap not found at $ROADMAP (clone li-langverse/roadmap sibling)" >&2
  exit 1
fi

exec "$INSTALL" "$LI_ROOT" "$@"
