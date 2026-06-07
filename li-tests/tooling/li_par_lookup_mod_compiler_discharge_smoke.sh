#!/usr/bin/env bash
# G-par — compiler AutoVC discharge for disjoint_lookup / disjoint_mod (7d-c slice).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="$("$ROOT/scripts/resolve-lic.sh")"
LOOKUP="$ROOT/li-tests/contracts_verify/parallel_disjoint_lookup_closed.li"
LOOKUP_PERM="$ROOT/li-tests/contracts_verify/parallel_disjoint_lookup_perm_closed.li"
MOD="$ROOT/li-tests/contracts_verify/parallel_disjoint_mod_closed.li"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

grep -q 'disjoint_lookup_spec' "$DISCHARGE"
grep -q 'disjoint_mod_spec' "$DISCHARGE"
grep -q 'disjoint_lookup_policy_witness' "$DISCHARGE"
grep -q 'disjoint_mod_policy_witness' "$DISCHARGE"
grep -q 'reverse_lookup_slot' "$DISCHARGE"
grep -q 'reverse_lookup_injective_on_tiles' "$DISCHARGE"
grep -q 'disjoint_lookup' "$VC_EMIT"
grep -q 'disjoint_mod' "$VC_EMIT"
grep -q 'par_disjoint_lookup_injective_formal' "$VC_EMIT"

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

AUTOVC="$(build_autovc "$LOOKUP")"
if ! grep -q 'Li.Discharge.disjoint_lookup_spec' "$AUTOVC"; then
  echo "FAIL: disjoint_lookup requires should emit Li.Discharge.disjoint_lookup_spec" >&2
  exit 1
fi
if ! grep -q 'disjoint_lookup_policy_witness' "$AUTOVC"; then
  echo "FAIL: disjoint_lookup requires should discharge via disjoint_lookup_policy_witness" >&2
  exit 1
fi
if ! grep -q 'index_bound_lookup_slot_spec' "$AUTOVC"; then
  echo "FAIL: disjoint_lookup requires should emit index_bound_lookup_slot_spec h_range" >&2
  exit 1
fi

AUTOVC="$(build_autovc "$LOOKUP_PERM")"
if ! grep -q 'Li.Discharge.disjoint_lookup_spec' "$AUTOVC"; then
  echo "FAIL: reverse perm disjoint_lookup requires should emit Li.Discharge.disjoint_lookup_spec" >&2
  exit 1
fi
if ! grep -q 'h_inj : Li.Discharge.lookup_injective_on_tiles_spec (Li.Discharge.reverse_lookup_slot 8) 8' "$AUTOVC"; then
  echo "FAIL: non-identity disjoint_lookup requires should emit reverse_lookup h_inj" >&2
  exit 1
fi

AUTOVC="$(build_autovc "$MOD")"
if ! grep -q 'Li.Discharge.disjoint_mod_spec' "$AUTOVC"; then
  echo "FAIL: disjoint_mod requires should emit Li.Discharge.disjoint_mod_spec" >&2
  exit 1
fi
if ! grep -q 'disjoint_mod_policy_witness' "$AUTOVC"; then
  echo "FAIL: disjoint_mod requires should discharge via disjoint_mod_policy_witness" >&2
  exit 1
fi
if ! grep -q 'index_bound_mod_slot_spec' "$AUTOVC"; then
  echo "FAIL: disjoint_mod requires should emit index_bound_mod_slot_spec h_range" >&2
  exit 1
fi

echo "li_par_lookup_mod_compiler_discharge_smoke: ok"
