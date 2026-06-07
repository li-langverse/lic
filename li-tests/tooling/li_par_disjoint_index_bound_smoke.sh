#!/usr/bin/env bash
# G-par — index-bound refinement of disjoint_elem_spec / disjoint_row_spec (7d-c slice).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="$("$ROOT/scripts/resolve-lic.sh")"
SRC="$ROOT/packages/li-parallel/src/parallel/proof.li"
OUT="$ROOT/build/li_par_disjoint_index_bound_smoke"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
EXPLICIT="$ROOT/li-tests/race_shared_memory/good_disjoint_parallel.li"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

"$LIC" build "$SRC" -o "$OUT" --allow-open-vc >/dev/null 2>&1
test -x "$OUT"

grep -q 'index_bound_elem_spec' "$DISCHARGE"
grep -q 'index_bound_row_spec' "$DISCHARGE"
grep -q 'disjoint_elem_of_nat' "$DISCHARGE"
grep -q 'disjoint_row_of_nat' "$DISCHARGE"
grep -q 'def par_disjoint_elem_index_bound' "$SRC"
grep -q 'def par_disjoint_row_index_bound' "$SRC"

build_autovc() {
  local src="$1"
  local tmp name autovc
  tmp="$(mktemp -d)"
  name="$(basename "$src")"
  cp "$src" "$tmp/$name"
  (
    cd "$tmp"
    unset LI_REPO_ROOT
    "$LIC" build "$name" -o /dev/null --no-lean-verify
  )
  echo "$tmp/build/generated/AutoVC.lean"
}

AUTOVC="$(build_autovc "$EXPLICIT")"
grep -q 'Li.Discharge.index_bound_row_spec' "$AUTOVC"
grep -q 'vc_good_parallel_par0_requires_0_proved.*disjoint_row_policy_witness' "$AUTOVC"
grep -q 'h_range' "$AUTOVC"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

echo "li_par_disjoint_index_bound_smoke: ok"
