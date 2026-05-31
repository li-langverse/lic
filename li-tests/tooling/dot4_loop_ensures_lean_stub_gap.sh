#!/usr/bin/env bash
# P-linalg / G-vc (#472): fixed-bound dot loop witness closes AutoVC with `Prop := True`,
# not `Li.Discharge.dot4_int_spec` / `dot4_loop_eval` (contrast mat2_at2_float_spec wiring).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
LOOP_SAMPLE="$ROOT/li-tests/contracts_verify/linalg_dot4_int_loop_open.li"
MAT2_SAMPLE="$ROOT/li-tests/contracts_verify/linalg_mat2_at2_float_closed.li"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'dot4_int_loop_eval_spec' "$DISCHARGE"; then
  echo "FAIL: expected dot4_int_loop_eval_spec in Discharge.lean" >&2
  exit 1
fi

if ! grep -q 'witness_dot4_int_loop' "$ROOT/compiler/verify/vc_witness.cpp"; then
  echo "FAIL: expected witness_dot4_int_loop in vc_witness.cpp" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build "$LOOP_SAMPLE" -o /dev/null 2>/dev/null
if ! grep -q 'fixed-bound dot loop witness' "$AUTOVC"; then
  echo "FAIL: expected loop witness marker in AutoVC" >&2
  exit 1
fi
if grep -q 'dot4_int_spec\|dot4_loop_eval' "$AUTOVC"; then
  echo "FAIL: loop specimen should not yet link Discharge dot4_int_spec/dot4_loop_eval" >&2
  exit 1
fi
if ! grep -q 'vc_dot4_int_loop_ensures_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: vc_dot4_int_loop_ensures_0 should stub True (G-vc gap)" >&2
  exit 1
fi
if ! grep -q 'vc_dot4_int_loop_ensures_0_proved.*:= trivial' "$AUTOVC"; then
  echo "FAIL: loop ensures should discharge via trivial, not dot4_int_loop_eval_spec" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build "$MAT2_SAMPLE" -o /dev/null 2>/dev/null
if ! grep -q 'Li.Discharge.mat2_at2_float_spec' "$AUTOVC"; then
  echo "FAIL: mat2 control should emit real Discharge spec (contrast)" >&2
  exit 1
fi

if grep -q 'dot4_int_spec' "$VC_EMIT" 2>/dev/null; then
  echo "FAIL: vc_emit_lean should not yet wire dot4_int_spec (gap open)" >&2
  exit 1
fi

chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null
# Re-check loop sample: zero open goals despite True stub (honesty gap, not open-goal failure).
rm -f "$AUTOVC"
"$LIC" build "$LOOP_SAMPLE" -o /dev/null 2>/dev/null
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

echo "PASS dot4_loop_ensures_lean_stub_gap: loop witness → True ensures; Discharge spec unused in AutoVC"
