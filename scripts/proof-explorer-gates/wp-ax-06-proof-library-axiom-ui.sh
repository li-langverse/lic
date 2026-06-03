#!/usr/bin/env bash
# WP-AX-06: proof-library shows AXIOM kind badge (sibling repo or sign-off).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
if [[ -n "$PL" && -f "$PL/web/components/proof-library-board.tsx" ]]; then
  if grep -q 'kind === "axiom"' "$PL/web/components/proof-library-board.tsx" \
    || grep -q 'AXIOM' "$PL/web/components/proof-library-board.tsx"; then
    echo "wp-ax-06-proof-library-axiom-ui: OK (proof-library board)"
    exit 0
  fi
fi

if [[ -f data/proof-explorer-loop/wp-ax-proof-library-ui.signoff ]]; then
  echo "wp-ax-06-proof-library-axiom-ui: OK (sign-off)"
  exit 0
fi

echo "wp-ax-06: proof-library AXIOM badge or wp-ax-proof-library-ui.signoff required" >&2
exit 1
