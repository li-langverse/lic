#!/usr/bin/env bash
# P-par / G-par — par_iteration_independent_tile lemma compiles and links disjoint_tile policy.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="$("$ROOT/scripts/resolve-lic.sh")"
SRC="$ROOT/packages/li-parallel/src/parallel/proof.li"
OUT="$ROOT/build/li_par_iteration_independent_tile_smoke"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

"$LIC" build "$SRC" -o "$OUT" --allow-open-vc >/dev/null 2>&1
test -x "$OUT"

DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
grep -q 'iteration_independent_tile_spec' "$DISCHARGE"
grep -q 'iteration_independent_tile_witness' "$DISCHARGE"

echo "li_par_iteration_independent_tile_smoke: ok"
