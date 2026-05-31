#!/usr/bin/env bash
# G-vc / P-linalg / G-oop: float vec3_dot FieldAccess ensures opaque in AutoVC; Vec3 → Int erasure;
# local-alias pattern witnesses structurally but no Li.Discharge vec3 spec (contrast linalg_dot4_float_closed).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
FIELD="$ROOT/li-tests/contracts_verify/linalg_vec3_dot_float_opaque.li"
LOCALS="$ROOT/li-tests/contracts_verify/linalg_vec3_dot_float_locals_witness.li"
DOT4="$ROOT/li-tests/contracts_verify/linalg_dot4_float_closed.li"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
MANIFEST="$ROOT/li-tests/manifest.toml"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if grep -q 'case Expr::Kind::FieldAccess' "$VC_EMIT"; then
  echo "FAIL: expr_to_lean should not yet translate FieldAccess (gap open)" >&2
  exit 1
fi
if grep -qiE 'vec3_dot|vec3_spec' "$DISCHARGE"; then
  echo "FAIL: Discharge.lean should not yet define vec3_dot spec (P-linalg open)" >&2
  exit 1
fi

"$LIC" check "$FIELD"
"$LIC" check "$LOCALS"

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$FIELD" -o /dev/null 2>/dev/null
if ! grep -q 'VC ensures (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "FAIL: field-access vec3_dot ensures should be opaque in AutoVC" >&2
  exit 1
fi
if ! grep -q 'vc_vec3_dot_ensures_0 (a : Int) (b : Int) (result : Float) : Prop := True' "$AUTOVC"; then
  echo "FAIL: Vec3 params should erasure to Int; ensures stub True" >&2
  exit 1
fi
if ! grep -q 'vc_vec3_dot_ensures_0_proved.*:= trivial' "$AUTOVC"; then
  echo "FAIL: opaque field ensures should discharge via trivial" >&2
  exit 1
fi
if grep -Eq 'a\.x|Li\.Vec3|FieldAccess' "$AUTOVC" 2>/dev/null; then
  echo "FAIL: Lean AutoVC should not mention object field semantics yet" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$LOCALS" -o /dev/null 2>/dev/null
if ! grep -q 'return expression matches ensures (static witness)' "$AUTOVC"; then
  echo "FAIL: local-alias vec3_dot should static-witness ensures" >&2
  exit 1
fi
if ! grep -q 'vc_vec3_dot_ensures_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: local-alias ensures still stubs True (no real Lean predicate)" >&2
  exit 1
fi
if grep -q 'result == ax \* bx' "$AUTOVC" 2>/dev/null; then
  echo "FAIL: local-alias ensures should not emit real Lean (identifiers untyped to fields)" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$DOT4" -o /dev/null 2>/dev/null
if ! grep -q 'prelude dot() return witness' "$AUTOVC"; then
  echo "FAIL: dot4 float control should witness prelude dot (contrast)" >&2
  exit 1
fi

if ! grep -A2 'math_linalg/vec3_ops.li' "$MANIFEST" | grep -q 'verify_ok'; then
  echo "FAIL: manifest tiers vec3_ops as verify_ok despite opaque ensures (G-test-verify)" >&2
  exit 1
fi

chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$FIELD" -o /dev/null 2>/dev/null
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

echo "PASS vec3_dot_opaque_ensures_gap: FieldAccess opaque + Vec3 erasure; locals witness only shape"
