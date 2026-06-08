#!/usr/bin/env bash
# G-par — lookup-table dependent subscript index-bound + aliasing (gather / permutation slice).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="$("$ROOT/scripts/resolve-lic.sh")"
SRC="$ROOT/packages/li-parallel/src/parallel/proof.li"
OUT="$ROOT/build/li_par_lookup_dependent_index_smoke"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

"$LIC" build "$SRC" -o "$OUT" --allow-open-vc >/dev/null 2>&1
test -x "$OUT"

grep -q 'lookup_index' "$DISCHARGE"
grep -q 'index_bound_lookup_spec' "$DISCHARGE"
grep -q 'lookup_injective_on_tiles_spec' "$DISCHARGE"
grep -q 'lookup_index_injective' "$DISCHARGE"
grep -q 'dependent_lookup_array_aliasing' "$DISCHARGE"
grep -q 'def par_disjoint_lookup_index_bound' "$SRC"
grep -q 'def par_lookup_injective_on_tiles' "$SRC"
grep -q 'def par_dependent_lookup_array_aliasing' "$SRC"

echo "li_par_lookup_dependent_index_smoke: ok"
