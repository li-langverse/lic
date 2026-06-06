#!/usr/bin/env bash
# G-bnd / G-vc: refinement-typed array index — codegen omits li_bounds_fail; callee AutoVC strips bounds;
# call-site refine VCs auto-prove via folded Lean + Li.Discharge.refinement_nonneg_lit_proved / by decide.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
LLVM_DIS="${LLVM_DIS:-llvm-dis}"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
EMIT_CPP="$ROOT/compiler/codegen/emit.cpp"
GOOD="$ROOT/li-tests/cve_patterns/good_bounded_index.li"
REFINE="$ROOT/li-tests/contracts_verify/index_refinement.li"
CALL_PROBE="$ROOT/li-tests/contracts_verify/index_bounds_call_refine_probe.li"
DYN_FAIL="$ROOT/li-tests/cve_patterns/cwe787_dyn_index.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if grep -qE 'CreateCall.*li_bounds_fail|call.*li_bounds_fail' "$EMIT_CPP" 2>/dev/null; then
  echo "FAIL: emit.cpp should not call li_bounds_fail (G-bnd codegen gap)" >&2
  exit 1
fi

if ! grep -q 'getOrInsertFunction("li_bounds_fail"' "$EMIT_CPP"; then
  echo "FAIL: expected li_bounds_fail declare in emit.cpp" >&2
  exit 1
fi

"$LIC" check "$GOOD"
"$LIC" check "$REFINE"
"$LIC" check "$CALL_PROBE"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

"$LIC" build --no-lean-verify "$GOOD" -o "$TMP/good_bounded" 2>/dev/null
if objdump -d "$TMP/good_bounded" | sed -n '/<get_cell>:/,/^$/p' | grep -q 'call.*bounds_fail'; then
  echo "FAIL: get_cell should not call li_bounds_fail (unchecked index load)" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$REFINE" -o /dev/null 2>/dev/null
if ! grep -q 'namespace get' "$AUTOVC"; then
  echo "FAIL: expected get namespace in AutoVC for index_refinement" >&2
  exit 1
fi
if grep -q 'Index10\|0 ≤\|0 <=' "$AUTOVC"; then
  echo "FAIL: callee AutoVC should strip refinement bounds (True stub expected)" >&2
  exit 1
fi
if ! grep -q 'vc_get_requires_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: vc_get_requires_0 should be True stub" >&2
  exit 1
fi
if ! grep -q '(i : Int)' "$AUTOVC"; then
  echo "FAIL: refinement param should lower to Int in Lean (vc_emit_lean.cpp:147-150)" >&2
  exit 1
fi

if ! grep -q 'refinement_nonneg' "$VC_EMIT"; then
  echo "FAIL: vc_emit_lean should wire refinement_nonneg discharge" >&2
  exit 1
fi

rm -f "$AUTOVC"
if ! "$LIC" build --allow-open-vc --no-lean-verify "$CALL_PROBE" -o /dev/null 2>/dev/null; then
  echo "FAIL: call refine probe should build with auto-proved call-site refine VC" >&2
  exit 1
fi
if ! grep -q 'vc_main_call0_get_cell_refine_0.*Prop :=' "$AUTOVC"; then
  echo "FAIL: expected call-site refinement VC" >&2
  exit 1
fi
if ! grep -q 'vc_main_call0_get_cell_refine_0_proved' "$AUTOVC"; then
  echo "FAIL: call-site refine VC should auto-prove (_proved theorem)" >&2
  exit 1
fi
if grep -q 'vc_main_call0_get_cell_refine_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: call-site refine VC should encode real bounds predicate (not True stub)" >&2
  exit 1
fi

if "$LIC" check "$DYN_FAIL" >/dev/null 2>&1; then
  echo "FAIL: cwe787_dyn_index should be rejected at typecheck" >&2
  exit 1
fi

echo "PASS bounds_guard_codegen_gap: no runtime bounds guard; callee True VC; call-site refine auto-proved"
