#!/usr/bin/env bash
# P-linalg / G-lean: tier-1 IKJ matmul loop path (ArrayMatMul2DF64) has no loop≡ensures witness.
# Contrast: witness_dot4_int_loop in vc_witness.cpp + dot4_int_loop_eval_spec in Discharge.lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
PROBE="$ROOT/li-tests/math_linalg/matmul_25x25_at_codegen.li"
WITNESS_CPP="$ROOT/compiler/verify/vc_witness.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
EMIT="$ROOT/compiler/codegen/emit.cpp"

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

if ! grep -q 'MirOp::ArrayMatMul2DF64' "$ROOT/compiler/mir/lower.cpp"; then
  echo "FAIL: expected ArrayMatMul2DF64 lowering" >&2
  exit 1
fi
if ! grep -A20 'void emit_matmul2d_ijk_loops' "$EMIT" | grep -q 'fp_numerically_stable'; then
  echo "FAIL: matmul loop FMA gate should reference fp_numerically_stable (emit.cpp:232-247)" >&2
  exit 1
fi

"$LIC" check "$PROBE"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

build_bin() {
  local stable_flag=("$@")
  "$LIC" build "$PROBE" -o "$TMP/matmul_probe" --release "${stable_flag[@]}" 2>/dev/null
}

build_bin
USER_ASM="$(sed -n '/<li_user_main>:/,/^$/p' <(objdump -d "$TMP/matmul_probe" 2>/dev/null))"
FAST_FMA="$(grep -c vfmadd <<<"$USER_ASM" || true)"
FAST_MUL="$(grep -c mulsd <<<"$USER_ASM" || true)"

build_bin --numerically-stable
USER_ASM_STABLE="$(sed -n '/<li_user_main>:/,/^$/p' <(objdump -d "$TMP/matmul_probe" 2>/dev/null))"
STABLE_FMA="$(grep -c vfmadd <<<"$USER_ASM_STABLE" || true)"
STABLE_MUL="$(grep -c mulsd <<<"$USER_ASM_STABLE" || true)"

if [[ "${FAST_FMA:-0}" -lt 1 ]] && [[ "${FAST_MUL:-0}" -lt 1 ]]; then
  echo "FAIL: release matmul should emit vfmadd or mulsd in li_user_main (loop path)" >&2
  exit 1
fi
if [[ "${FAST_FMA:-0}" -lt 1 ]]; then
  echo "FAIL: release matmul loop path should prefer vfmadd (llvm.fmuladd; emit.cpp:232-247)" >&2
  exit 1
fi
if [[ "${STABLE_FMA:-0}" -ge 1 ]]; then
  echo "FAIL: --numerically-stable matmul should not emit vfmadd (emit.cpp:232-247)" >&2
  exit 1
fi
if [[ "${STABLE_MUL:-0}" -lt 1 ]]; then
  echo "FAIL: --numerically-stable matmul should use mulsd path" >&2
  exit 1
fi

echo "PASS matmul_loop_codegen_witness_gap: no P-linalg loop witness; loop+FMA gate OK"
