#!/usr/bin/env bash
# G-par — dependent array aliasing bridges (disjoint_* policy → memory_disjoint_* specs).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="$("$ROOT/scripts/resolve-lic.sh")"
SRC="$ROOT/packages/li-parallel/src/parallel/proof.li"
OUT="$ROOT/build/li_par_dependent_array_aliasing_smoke"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

"$LIC" build "$SRC" -o "$OUT" --allow-open-vc >/dev/null 2>&1
test -x "$OUT"

DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
grep -q 'dependent_flat_array_aliasing' "$DISCHARGE"
grep -q 'dependent_grid_row_aliasing' "$DISCHARGE"
grep -q 'dependent_grid_cell_aliasing' "$DISCHARGE"

echo "li_par_dependent_array_aliasing_smoke: ok"
