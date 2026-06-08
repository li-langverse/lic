#!/usr/bin/env bash
# G-par — blocked affine dependent subscript index-bound + aliasing ((i/block)*stride + i%block slice).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="$("$ROOT/scripts/resolve-lic.sh")"
SRC="$ROOT/packages/li-parallel/src/parallel/proof.li"
OUT="$ROOT/build/li_par_blocked_affine_dependent_index_smoke"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

"$LIC" build "$SRC" -o "$OUT" --allow-open-vc >/dev/null 2>&1
test -x "$OUT"

grep -q 'blocked_affine_index' "$DISCHARGE"
grep -q 'index_bound_blocked_affine_spec' "$DISCHARGE"
grep -q 'blocked_affine_index_injective' "$DISCHARGE"
grep -q 'dependent_blocked_affine_array_aliasing' "$DISCHARGE"
grep -q 'def par_disjoint_blocked_affine_index_bound' "$SRC"
grep -q 'def par_dependent_blocked_affine_array_aliasing' "$SRC"

echo "li_par_blocked_affine_dependent_index_smoke: ok"
