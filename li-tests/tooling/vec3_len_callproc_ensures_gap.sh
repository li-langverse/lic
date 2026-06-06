#!/usr/bin/env bash
# G-vc / P-linalg / P-float: vec3_len CallProc ensures chain discharges via Li.Discharge vec3_len_* specs.
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

if ! grep -q 'vec3_len_spec\|vec3_len_sq_spec' "$DISCHARGE"; then
  echo "FAIL: Discharge.lean should define vec3_len chain specs" >&2
  exit 1
fi
if ! grep -q 'witness_vec3_len' "$ROOT/compiler/verify/vc_witness.cpp"; then
  echo "FAIL: expected witness_vec3_len* in vc_witness.cpp" >&2
  exit 1
fi
if ! grep -q 'vec3_len_spec' "$VC_EMIT"; then
  echo "FAIL: vc_emit_lean should wire vec3_len_spec discharge" >&2
  exit 1
fi

"$LIC" check "$CHAIN"
"$LIC" check "$LEN_SQ"

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$CHAIN" -o /dev/null 2>/dev/null
if grep -q 'VC ensures (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "FAIL: vec3_len chain ensures should not be opaque" >&2
  exit 1
fi
if grep -q 'vc_vec3_len_ensures_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: vc_vec3_len_ensures_0 should not stub True" >&2
  exit 1
fi
if ! grep -q 'Li.Discharge.vec3_len_spec' "$AUTOVC"; then
  echo "FAIL: vec3_len should emit Li.Discharge.vec3_len_spec" >&2
  exit 1
fi
if ! grep -q 'vc_vec3_len_ensures_0_proved.*vec3_len_spec_proved' "$AUTOVC"; then
  echo "FAIL: vec3_len ensures should discharge via vec3_len_spec_proved" >&2
  exit 1
fi
if ! grep -q 'Li.Discharge.vec3_len_sq_spec' "$AUTOVC"; then
  echo "FAIL: vec3_len_sq should emit Li.Discharge.vec3_len_sq_spec" >&2
  exit 1
fi

chmod +x "$OPEN_GOALS"
"$OPEN_GOALS" "$AUTOVC" >/dev/null

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
  echo "FAIL: manifest tiers vec3_ops as verify_ok" >&2
  exit 1
fi

echo "PASS vec3_len_callproc_ensures_gap: vec3_len chain → Li.Discharge; sqrt_open_bound stays open"
