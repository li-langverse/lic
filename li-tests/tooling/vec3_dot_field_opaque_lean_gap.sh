#!/usr/bin/env bash
# G-vc / P-linalg: Vec3 object-field ensures fail expr_to_lean; AutoVC stubs True with Int-typed params.
# Passes while the gap is open; update when field-access VC translation or Li.Vec3 Lean type lands.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/vec3_dot_float_field_opaque.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
BIN="$(mktemp -t li_vec3_dot.XXXXXX)"
trap 'rm -f "$BIN"' EXIT

rm -f "$AUTOVC"
"$LIC" build "$SAMPLE" -o "$BIN"
test -f "$AUTOVC"

if ! grep -q 'VC ensures (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "vec3_dot_field_opaque_lean_gap: expected opaque ensures marker — gap may be closed; update script"
  exit 1
fi
if ! grep -qE 'def vc_vec3_dot_ensures_0.*Prop := True' "$AUTOVC"; then
  echo "vec3_dot_field_opaque_lean_gap: expected True-stub ensures while field access untranslated"
  exit 1
fi
if grep -qE 'def vc_vec3_dot_ensures_0.*a\.x|Li\.Vec3' "$AUTOVC"; then
  echo "vec3_dot_field_opaque_lean_gap: unexpected real field formula in AutoVC — update script"
  exit 1
fi
# Vec3 params currently lower to Int in Lean formals (lean_type_name Named fallback).
if ! grep -qE 'def vc_vec3_dot_ensures_0 \(a : Int\) \(b : Int\)' "$AUTOVC"; then
  echo "vec3_dot_field_opaque_lean_gap: expected Int-typed Vec3 formals (documented type drift)"
  exit 1
fi

DISASM="$(objdump -d "$BIN" --disassemble=vec3_dot 2>/dev/null || true)"
if ! echo "$DISASM" | grep -qE 'mulsd|addsd'; then
  echo "vec3_dot_field_opaque_lean_gap: expected float mul/add in vec3_dot codegen"
  exit 1
fi
if echo "$DISASM" | grep -qE 'call.*(li_bounds_fail|li_panic|li_contract)'; then
  echo "vec3_dot_field_opaque_lean_gap: unexpected runtime contract hook — update script"
  exit 1
fi

if ! "$LIC" check "$SAMPLE" >/dev/null 2>&1; then
  echo "vec3_dot_field_opaque_lean_gap: specimen must pass lic check (typecheck fence)"
  exit 1
fi

echo "vec3_dot_field_opaque_lean_gap: ok (documented G-vc Vec3 field opaque + Lean type drift)"
