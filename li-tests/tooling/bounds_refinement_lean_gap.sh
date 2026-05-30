#!/usr/bin/env bash
# G-bnd / P-refine: refinement index bounds not in Lean VCs; codegen has no runtime guard.
# Guarded call-site refinement (if n >= 0 branch) also collapses to Prop := True in AutoVC.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export LI_KEEP_LL=1
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
INDEX="$ROOT/li-tests/contracts_verify/index_refinement.li"
GUARD="$ROOT/li-tests/contracts_verify/refinement_guard_ok.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
LL="$ROOT/build/last_emit.ll"

"$LIC" build "$INDEX" -o /dev/null
[[ -f "$AUTOVC" ]]
if ! grep -q 'vc_get_requires_0 (a : LiArray Int 10) (i : Int)' "$AUTOVC"; then
  echo "bounds_refinement_lean_gap: expected Index10 param as plain Int in AutoVC"
  exit 1
fi
if grep -qE '0 <= i|i < 10' "$AUTOVC"; then
  echo "bounds_refinement_lean_gap: unexpected bounds predicate in AutoVC (gap closed?)"
  exit 1
fi

[[ -f "$LL" ]]
if grep -q 'call void @li_bounds_fail' "$LL"; then
  echo "bounds_refinement_lean_gap: unexpected runtime bounds call in IR"
  exit 1
fi
if ! grep -q 'getelementptr inbounds' "$LL"; then
  echo "bounds_refinement_lean_gap: expected inbounds GEP in IR"
  exit 1
fi

"$LIC" build "$GUARD" -o /dev/null
if ! grep -q 'vc_caller_guarded_call0_callee_refine_0 (n : Int) : Prop := True' "$AUTOVC"; then
  echo "bounds_refinement_lean_gap: guarded refine VC should stub True while gap open"
  exit 1
fi

echo "bounds_refinement_lean_gap: ok (documented G-bnd/P-refine Lean+codegen hole)"
