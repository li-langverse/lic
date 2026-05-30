#!/usr/bin/env bash
# G-vc / P-linalg / P-float: vec3_len CallProc ensures chain (li_rt_sqrt(vec3_len_sq(a)))
# opaque in AutoVC + trivial discharge; contrast sqrt_open_bound real Float.abs Prop (intentionally open).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
CHAIN="$ROOT/li-tests/contracts_verify/linalg_vec3_len_callproc_chain.li"
LEN_SQ="$ROOT/li-tests/contracts_verify/linalg_vec3_len_sq_callproc.li"
SQRT_OPEN="$ROOT/li-tests/contracts_verify/sqrt_open_bound.li"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
MANIFEST="$ROOT/li-tests/manifest.toml"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
OPEN_GOALS="$ROOT/scripts/check-autovc-open-goals.sh"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'case Expr::Kind::Call:' "$VC_EMIT"; then
  echo "FAIL: expected Call handling in expr_to_lean" >&2
  exit 1
fi
if grep -qE 'vec3_len|vec3_len_sq|vec3_dot_spec' "$DISCHARGE"; then
  echo "FAIL: Discharge.lean should not yet define vec3_len chain specs (P-linalg/P-float open)" >&2
  exit 1
fi

"$LIC" check "$CHAIN"
"$LIC" check "$LEN_SQ"

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$CHAIN" -o /dev/null 2>/dev/null
if ! grep -q 'VC ensures (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "FAIL: vec3_len / vec3_len_sq ensures should be opaque (CallProc in ensures)" >&2
  exit 1
fi
if ! grep -q 'vc_vec3_len_ensures_0 (a : Int) (result : Float) : Prop := True' "$AUTOVC"; then
  echo "FAIL: vec3_len ensures should stub True after opaque emit" >&2
  exit 1
fi
if ! grep -q 'vc_vec3_len_sq_ensures_0 (a : Int) (result : Float) : Prop := True' "$AUTOVC"; then
  echo "FAIL: vec3_len_sq ensures should stub True (user CallProc in ensures)" >&2
  exit 1
fi
if ! grep -q 'vc_vec3_len_ensures_0_proved.*:= trivial' "$AUTOVC"; then
  echo "FAIL: vec3_len ensures should vacuously discharge via trivial" >&2
  exit 1
fi
if grep -E 'def vc_vec3_(len|len_sq)_ensures_0.*Prop :=' "$AUTOVC" | grep -vq 'Prop := True$'; then
  echo "FAIL: vec3_len chain ensures should stub True only (no real Lean predicate)" >&2
  exit 1
fi
if grep -q 'Li\.Discharge\.\(vec3\|sqrt\)' "$AUTOVC" 2>/dev/null; then
  echo "FAIL: AutoVC should not wire Discharge theorems for vec3_len chain yet" >&2
  exit 1
fi
if ! grep -q 'vc_vec3_len_call0_li_rt_sqrt_requires_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: extern li_rt_sqrt call-site requires should witness trivial (ensures true on callee)" >&2
  exit 1
fi

chmod +x "$OPEN_GOALS"
if ! "$OPEN_GOALS" "$AUTOVC" >/dev/null 2>&1; then
  echo "FAIL: vec3_len chain should report zero open goals (vacuous True discharge)" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify --allow-open-vc "$SQRT_OPEN" -o /dev/null 2>/dev/null
if ! grep -q 'Float.abs' "$AUTOVC"; then
  echo "FAIL: sqrt_open_bound control should emit real Float.abs ensures Prop" >&2
  exit 1
fi
if grep -q 'vc_sqrt_open_ensures_0_proved' "$AUTOVC"; then
  echo "FAIL: sqrt_open_bound ensures should stay open (no _proved theorem)" >&2
  exit 1
fi
if "$OPEN_GOALS" "$AUTOVC" >/dev/null 2>&1; then
  echo "FAIL: sqrt_open_bound should have open VC goals (contrast control)" >&2
  exit 1
fi

if ! grep -A2 'math_linalg/vec3_ops.li' "$MANIFEST" | grep -q 'verify_ok'; then
  echo "FAIL: manifest tiers vec3_ops as verify_ok despite CallProc chain gap (G-test-verify)" >&2
  exit 1
fi

echo "PASS vec3_len_callproc_ensures_gap: opaque CallProc chain + trivial discharge; sqrt_open_bound stays open"
