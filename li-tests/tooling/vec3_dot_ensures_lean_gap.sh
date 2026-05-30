#!/usr/bin/env bash
# G-vc / P-linalg: vec3 ensures with FieldAccess or body-local idents stub to Prop := True.
# Wrong return still certifies when ensures uses untranslatable FieldAccess (soundness hole).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
FIELD="$ROOT/li-tests/math_linalg/vec3_ops.li"
LOCALS="$ROOT/li-tests/contracts_verify/vec3_dot_locals_ensures.li"
WRONG="$ROOT/li-tests/contracts_verify/vec3_dot_wrong_return.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

rm -f "$AUTOVC"
"$LIC" build "$FIELD" -o /dev/null
[[ -f "$AUTOVC" ]]
if ! grep -q 'VC ensures (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "vec3_dot_ensures_lean_gap: expected opaque ensures for FieldAccess vec3_ops"
  exit 1
fi
if ! grep -q 'def vc_vec3_dot_ensures_0 (a : Int) (b : Int) (result : Float) : Prop := True' "$AUTOVC"; then
  echo "vec3_dot_ensures_lean_gap: expected FieldAccess ensures stubbed True"
  exit 1
fi
if grep -qE 'a\.x|FieldAccess|LiObject' "$AUTOVC"; then
  echo "vec3_dot_ensures_lean_gap: unexpected field predicate in AutoVC (gap closed?)"
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build "$LOCALS" -o /dev/null
if ! grep -q 'Phase 2f: return expression matches ensures (static witness)' "$AUTOVC"; then
  echo "vec3_dot_ensures_lean_gap: expected static return witness for body-local ensures"
  exit 1
fi
if ! grep -q 'def vc_vec3_dot_ensures_0 (a : Int) (b : Int) (result : Float) : Prop := True' "$AUTOVC"; then
  echo "vec3_dot_ensures_lean_gap: expected body-local ensures stubbed True"
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build "$WRONG" -o /dev/null
if ! grep -q 'VC ensures (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "vec3_dot_ensures_lean_gap: expected opaque ensures on wrong-return specimen"
  exit 1
fi
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"

echo "vec3_dot_ensures_lean_gap: ok (documented G-vc/P-linalg vec3 ensures Lean hole)"
