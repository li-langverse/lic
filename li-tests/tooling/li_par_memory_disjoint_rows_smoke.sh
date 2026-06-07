#!/usr/bin/env bash
# G-par — par_memory_disjoint_rows lemma + memory_disjoint_rows_spec in Discharge.lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="$("$ROOT/scripts/resolve-lic.sh")"
SRC="$ROOT/packages/li-parallel/src/parallel/proof.li"
OUT="$ROOT/build/li_par_memory_disjoint_rows_smoke"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

"$LIC" build "$SRC" -o "$OUT" --allow-open-vc >/dev/null 2>&1
test -x "$OUT"

DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
grep -q 'memory_disjoint_rows_spec' "$DISCHARGE"
grep -q 'memory_disjoint_rows_witness' "$DISCHARGE"
grep -q 'iteration_independent_implies_memory_disjoint_rows' "$DISCHARGE"

echo "li_par_memory_disjoint_rows_smoke: ok"
