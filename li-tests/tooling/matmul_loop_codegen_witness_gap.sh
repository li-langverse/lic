#!/usr/bin/env bash
# P-linalg / G-lean: tier-1 IKJ matmul loop path (ArrayMatMul2DF64) has no loop≡ensures witness.
# Contrast: witness_dot4_int_loop in vc_witness.cpp + dot4_int_loop_eval_spec in Discharge.lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
PROBE="$ROOT/li-tests/math_linalg/matmul_25x25_at_codegen.li"
WITNESS_CPP="$ROOT/compiler/verify/vc_witness.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if grep -q 'witness_matmul' "$WITNESS_CPP" 2>/dev/null; then
  echo "FAIL: expected no witness_matmul* in vc_witness.cpp (P-linalg loop gap)" >&2
  exit 1
fi
if grep -q 'matmul.*loop_eval\|matmul2d.*loop' "$DISCHARGE" 2>/dev/null; then
  echo "FAIL: expected no matmul loop_eval lemma in Discharge.lean yet" >&2
  exit 1
fi

"$LIC" check "$PROBE"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

build_ir() {
  local stable_flag=("$@")
  "$LIC" build "$PROBE" -o "$TMP/matmul_probe" --release "${stable_flag[@]}" 2>/dev/null
  llvm-dis "$TMP/matmul_probe" -o - 2>/dev/null || true
}

IR_FAST="$(build_ir)"
IR_STABLE="$(build_ir --numerically-stable)"

if ! grep -q 'mm_i' <<<"$IR_FAST"; then
  echo "FAIL: loop-path matmul IR should contain mm_i alloca (emit_matmul2d_ijk_loops)" >&2
  exit 1
fi
if ! grep -q 'fmuladd' <<<"$IR_FAST"; then
  echo "FAIL: release matmul loop path should use llvm.fmuladd when not numerically-stable" >&2
  exit 1
fi
if grep -q 'fmuladd' <<<"$IR_STABLE"; then
  echo "FAIL: --numerically-stable matmul should not emit fmuladd (emit.cpp:232-247)" >&2
  exit 1
fi

echo "PASS matmul_loop_codegen_witness_gap: no P-linalg loop witness; loop+FMA gate OK"
