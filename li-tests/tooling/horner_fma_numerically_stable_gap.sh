#!/usr/bin/env bash
# G-hw / G-meta / PH-7e: Horner FMA MIR ops ignore --numerically-stable (contrast matmul emit.cpp:232-247).
# HornerFmaUnroll / HornerStepPow4 / FmaFloatF64 always emit llvm.fmuladd (emit.cpp:764-800).
# No horner/fma semantics in Discharge.lean or vc_witness.cpp.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
PROBE="$ROOT/li-tests/math_linalg/horner_fma_codegen_probe.li"
WITNESS_CPP="$ROOT/compiler/verify/vc_witness.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
EMIT="$ROOT/compiler/codegen/emit.cpp"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if grep -q 'horner\|FmaFloat\|fma' "$WITNESS_CPP" 2>/dev/null; then
  echo "FAIL: expected no horner/fma witness in vc_witness.cpp yet" >&2
  exit 1
fi
if grep -qi 'horner\|fma\|fmuladd' "$DISCHARGE" 2>/dev/null; then
  echo "FAIL: expected no horner/fma semantics in Discharge.lean yet" >&2
  exit 1
fi

# Matmul respects fp_numerically_stable; horner MIR emit does not (gap under test).
if ! grep -A20 'void emit_matmul2d_ijk_loops' "$EMIT" | grep -q 'fp_numerically_stable'; then
  echo "FAIL: matmul FMA gate should reference fp_numerically_stable" >&2
  exit 1
fi
if grep -A8 'case MirOp::HornerStepPow4' "$EMIT" | grep -q 'fp_numerically_stable'; then
  echo "FAIL: HornerStepPow4 should not yet gate on fp_numerically_stable (gap closed?)" >&2
  exit 1
fi

"$LIC" check "$PROBE"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

build_bin() {
  local stable_flag=("$@")
  "$LIC" build "$PROBE" -o "$TMP/horner_probe" --release "${stable_flag[@]}" 2>/dev/null
}

build_bin
FAST_FMA="$(objdump -d "$TMP/horner_probe" 2>/dev/null | grep -c vfmadd || true)"
build_bin --numerically-stable
STABLE_FMA="$(objdump -d "$TMP/horner_probe" 2>/dev/null | grep -c vfmadd || true)"

if [[ "${FAST_FMA:-0}" -lt 1 ]]; then
  echo "FAIL: release horner should emit vfmadd (HornerStepPow4/FmaFloatF64)" >&2
  exit 1
fi
if [[ "${STABLE_FMA:-0}" -lt 1 ]]; then
  echo "FAIL: --numerically-stable horner still emits vfmadd (G-hw gap open; retest when fixed)" >&2
  exit 1
fi

echo "PASS horner_fma_numerically_stable_gap: FMA on both paths; --numerically-stable ignored (matmul parity gap)"
