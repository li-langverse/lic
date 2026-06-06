#!/usr/bin/env bash
# G-hw / G-meta / PH-7e: Horner FMA MIR ops honor --numerically-stable (mirror matmul emit.cpp FMA gate).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
PROBE="$ROOT/li-tests/math_linalg/horner_fma_codegen_probe.li"
EMIT="$ROOT/compiler/codegen/emit.cpp"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'emit_fma_f64' "$EMIT"; then
  echo "FAIL: expected emit_fma_f64 helper gating Horner FMA on fp_numerically_stable" >&2
  exit 1
fi
if ! grep -A30 'void emit_matmul2d_ijk_loops' "$EMIT" | grep -q 'fp_numerically_stable'; then
  echo "FAIL: matmul FMA gate should reference fp_numerically_stable" >&2
  exit 1
fi
if grep -A8 'case MirOp::HornerStepPow4' "$EMIT" | grep -q 'Intrinsic::fmuladd'; then
  echo "FAIL: HornerStepPow4 should use emit_fma_f64 (not bare fmuladd intrinsic)" >&2
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
if [[ "${STABLE_FMA:-0}" -ge 1 ]]; then
  echo "FAIL: --numerically-stable horner should not emit vfmadd (mulsd path)" >&2
  exit 1
fi

echo "PASS horner_fma_numerically_stable_gap: FMA on fast path; --numerically-stable uses mulsd"
