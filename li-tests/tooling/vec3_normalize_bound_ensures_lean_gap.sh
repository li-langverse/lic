#!/usr/bin/env bash
# G-vc / P-float: vec3_normalize weak bound ensures — FieldAccess comparisons opaque in Lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
LIB_MATH="$ROOT/packages/li-math/src/lib.li"
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
if grep -qiE 'vec3_normalize|normalize_spec' "$DISCHARGE"; then
  echo "FAIL: Discharge.lean should not yet define vec3_normalize spec (P-float open)" >&2
  exit 1
fi
grep -q 'ensures result.x >= -1.0' "$LIB_MATH" || {
  echo "FAIL: production vec3_normalize bound ensures missing in li-math"; exit 1; }

build_autovc() {
  local sample="$1"
  rm -f "$AUTOVC"
  "$LIC" build --no-lean-verify "$sample" -o /dev/null 2>/dev/null
}

"$LIC" check "$ROOT/li-tests/contracts_verify/vec3_normalize_bound_ensures.li"
"$LIC" check "$ROOT/li-tests/contracts_verify/vec3_normalize_wrong_bounds.li"

build_autovc "$ROOT/li-tests/contracts_verify/vec3_normalize_bound_ensures.li"
grep -q 'namespace vec3_normalize' "$AUTOVC" || { echo "FAIL: missing vec3_normalize namespace"; exit 1; }
for i in 0 1 2 3 4 5; do
  grep -q "vc_vec3_normalize_ensures_${i}" "$AUTOVC" || {
    echo "FAIL: missing vec3_normalize ensures_${i}"; exit 1; }
done
grep -q 'VC ensures (opaque)' "$AUTOVC" || {
  echo "FAIL: vec3_normalize bound ensures should be opaque"; exit 1; }
if awk '/^namespace vec3_normalize$/,/^end vec3_normalize$/ {print}' "$AUTOVC" |
  grep -q 'Phase 2f: return expression matches ensures'; then
  echo "FAIL: vec3_normalize must not use static return witness on bound ensures"; exit 1; fi
grep -q 'vc_vec3_normalize_ensures_0.*Prop := True' "$AUTOVC" || {
  echo "FAIL: opaque bound ensures should stub True"; exit 1; }
grep -q 'vc_vec3_normalize_ensures_0_proved.*:= trivial' "$AUTOVC" || {
  echo "FAIL: vec3_normalize should discharge via trivial"; exit 1; }
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

build_autovc "$ROOT/li-tests/contracts_verify/vec3_normalize_wrong_bounds.li"
grep -q 'vc_vec3_normalize_bad_ensures_0' "$AUTOVC" || {
  echo "FAIL: missing vec3_normalize_bad proc"; exit 1; }
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

echo "PASS vec3_normalize_bound_ensures_lean_gap: FieldAccess bounds opaque; wrong bounds still certifies"
