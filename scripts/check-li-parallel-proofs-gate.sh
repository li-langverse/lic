#!/usr/bin/env bash
# WP-PAR-30 / G-par / G-par-dist / G-hetero — provability register closed slices.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel proofs gate"

if [[ -f "$ROOT/packages/li-parallel/li-tests/smoke/kernels_ghost.li" ]]; then
  if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
    "$ROOT/build/compiler/lic/lic" build \
      "$ROOT/packages/li-parallel/li-tests/smoke/kernels_ghost.li" \
      --allow-open-vc >/dev/null 2>&1 || true
  fi
fi

li_fail "G-par-dist and G-hetero closed slices pending in provability register (WP-PAR-30, DOC-PAR proofs table)"
exit 1
