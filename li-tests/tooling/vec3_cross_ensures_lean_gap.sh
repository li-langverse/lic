#!/usr/bin/env bash
# G-vc / P-linalg / G-oop: Vec3 CallProc+FieldAccess ensures (vec3_cross) must not fake cross math in Lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"

if grep -q 'case Expr::Kind::FieldAccess' "$VC_EMIT"; then
  echo "FAIL: expr_to_lean should not yet translate FieldAccess (gap open)" >&2
  exit 1
fi
if grep -qiE 'vec3_cross|vec3_cross_spec' "$DISCHARGE"; then
  echo "FAIL: Discharge.lean should not yet define vec3_cross spec (P-linalg open)" >&2
  exit 1
fi

build_autovc() {
  local sample="$1"
  rm -f "$AUTOVC"
  "$LIC" build --no-lean-verify "$sample" -o /dev/null 2>/dev/null
}

"$LIC" check "$ROOT/li-tests/contracts_verify/vec3_cross_call_ensures.li"
"$LIC" check "$ROOT/li-tests/contracts_verify/vec3_cross_wrong_return.li"
"$LIC" check "$ROOT/li-tests/contracts_verify/vec3_add_field_ensures.li"

build_autovc "$ROOT/li-tests/contracts_verify/vec3_cross_call_ensures.li"
grep -q 'namespace vec3_cross' "$AUTOVC" || { echo "FAIL: missing vec3_cross namespace"; exit 1; }
grep -q 'vc_vec3_cross_ensures_0' "$AUTOVC" && grep -q 'VC ensures (opaque)' "$AUTOVC" || {
  echo "FAIL: vec3_cross ensures should be opaque"; exit 1; }
if awk '/^namespace vec3_cross$/,/^end vec3_cross$/ {print}' "$AUTOVC" |
  grep -q 'Phase 2f: return expression matches ensures'; then
  echo "FAIL: vec3_cross must not use static return witness"; exit 1; fi
grep -q 'vc_vec3_cross_ensures_0.*Prop := True' "$AUTOVC" || {
  echo "FAIL: opaque vec3_cross ensures should stub True"; exit 1; }
grep -q 'vc_vec3_cross_ensures_0_proved.*:= trivial' "$AUTOVC" || {
  echo "FAIL: vec3_cross should discharge via trivial"; exit 1; }
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

build_autovc "$ROOT/li-tests/contracts_verify/vec3_cross_wrong_return.li"
grep -q 'vc_vec3_cross_bad_ensures_0' "$AUTOVC" || {
  echo "FAIL: missing vec3_cross_bad proc"; exit 1; }
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

build_autovc "$ROOT/li-tests/contracts_verify/vec3_add_field_ensures.li"
grep -q 'namespace vec3_add' "$AUTOVC" || { echo "FAIL: missing vec3_add namespace"; exit 1; }
grep -q 'vc_vec3_add_ensures_0' "$AUTOVC" || {
  echo "FAIL: missing vec3_add ensures_0"; exit 1; }
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

echo "PASS vec3_cross_ensures_lean_gap: CallProc+FieldAccess opaque; wrong return still certifies"
