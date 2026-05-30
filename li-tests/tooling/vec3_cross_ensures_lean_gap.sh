#!/usr/bin/env bash
# G-vc / P-linalg: Vec3 CallProc+FieldAccess ensures (vec3_cross) must not fake cross math in Lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"

build_autovc() {
  local sample="$1"
  local copy
  copy="$(mktemp "${TMPDIR:-/tmp}/lic-autovc.XXXXXX")"
  flock /tmp/lic-autovc.lock bash -c "
    export LI_REPO_ROOT=\"$ROOT\" LIC=\"$LIC\"
    rm -f \"$ROOT/build/generated/AutoVC.lean\"
    \"\$LIC\" build --no-lean-verify \"$sample\" -o /dev/null 2>/dev/null
    cp \"$ROOT/build/generated/AutoVC.lean\" \"$copy\"
  "
  printf '%s\n' "$copy"
}

AUTOVC="$(build_autovc "$ROOT/li-tests/contracts_verify/vec3_cross_call_ensures.li")"
grep -q 'namespace vec3_cross' "$AUTOVC" || { echo "vec3_cross_ensures_lean_gap: missing vec3_cross"; exit 1; }
grep -q 'vc_vec3_cross_ensures_0' "$AUTOVC" && grep -q 'VC ensures (opaque)' "$AUTOVC" || {
  echo "vec3_cross_ensures_lean_gap: vec3_cross ensures should be opaque"; exit 1; }
if awk '/^namespace vec3_cross$/,/^end vec3_cross$/ {print}' "$AUTOVC" |
  grep -q 'Phase 2f: return expression matches ensures'; then
  echo "vec3_cross_ensures_lean_gap: vec3_cross must not use static return witness"; exit 1; fi
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"

AUTOVC="$(build_autovc "$ROOT/li-tests/contracts_verify/vec3_cross_wrong_return.li")"
grep -q 'vc_vec3_cross_bad_ensures_0' "$AUTOVC" || {
  echo "vec3_cross_ensures_lean_gap: missing bad proc"; exit 1; }
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"

AUTOVC="$(build_autovc "$ROOT/li-tests/contracts_verify/vec3_add_field_ensures.li")"
grep -q 'namespace vec3_add' "$AUTOVC" || { echo "vec3_cross_ensures_lean_gap: missing vec3_add"; exit 1; }
# Per-field ensures: each component may witness to True without cross-field math.
grep -q 'vc_vec3_add_ensures_0' "$AUTOVC" || {
  echo "vec3_cross_ensures_lean_gap: missing vec3_add ensures_0"; exit 1; }
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"

echo "vec3_cross_ensures_lean_gap: ok"
