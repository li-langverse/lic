#!/usr/bin/env bash
# P-linalg / G-vc (#472): fixed-bound dot loop witness wires Li.Discharge.dot4_int_spec /
# dot4_loop_eval + dot4_int_loop_eval_spec (mirror mat2_at2_float_spec).
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

if ! grep -q 'dot4_int_spec' "$VC_EMIT"; then
  echo "FAIL: vc_emit_lean should wire dot4_int_spec discharge" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build "$LOOP_SAMPLE" -o /dev/null 2>/dev/null
if ! grep -qE 'P-loop dot4.*dot4_int_loop_eval_spec' "$AUTOVC"; then
  echo "FAIL: expected loop discharge marker in AutoVC" >&2
  exit 1
fi
if ! grep -q 'Li.Discharge.dot4_int_spec' "$AUTOVC"; then
  echo "FAIL: loop specimen should emit Li.Discharge.dot4_int_spec" >&2
  exit 1
fi
if ! grep -q 'Li.Discharge.dot4_loop_eval' "$AUTOVC"; then
  echo "FAIL: loop specimen should emit Li.Discharge.dot4_loop_eval" >&2
  exit 1
fi
if grep -q 'vc_dot4_int_loop_ensures_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: vc_dot4_int_loop_ensures_0 should not stub True" >&2
  exit 1
fi
if ! grep -q 'vc_dot4_int_loop_ensures_0_proved.*dot4_int_loop_eval_spec' "$AUTOVC"; then
  echo "FAIL: loop ensures should discharge via dot4_int_loop_eval_spec" >&2
  exit 1
fi
if grep -q 'vc_dot4_int_loop_ensures_0_proved.*:= trivial' "$AUTOVC"; then
  echo "FAIL: loop ensures should not use trivial proof" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build "$MAT2_SAMPLE" -o /dev/null 2>/dev/null
if ! grep -q 'Li.Discharge.mat2_at2_float_spec' "$AUTOVC"; then
  echo "FAIL: mat2 control should emit real Discharge spec (contrast)" >&2
  exit 1
fi

chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null
rm -f "$AUTOVC"
"$LIC" build "$LOOP_SAMPLE" -o /dev/null 2>/dev/null
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

echo "PASS dot4_loop_ensures_lean_stub_gap: loop witness -> dot4_int_spec + dot4_int_loop_eval_spec"
