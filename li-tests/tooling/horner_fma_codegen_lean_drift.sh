#!/usr/bin/env bash
# G-hw / G-meta / G-vc: tier-1 HornerStepPow4 + FmaFloatF64 codegen has no Lean loop≡ensures witness.
# Contrast: dot4 loop closed in vc_witness.cpp + Discharge.lean; matmul IKJ disables FMA under --numerically-stable.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
PROBE="$ROOT/li-tests/codegen/horner_5m_fma_codegen_probe.li"
MATMUL_PROBE="$ROOT/li-tests/math_linalg/matmul_25x25_at_codegen.li"
WITNESS_CPP="$ROOT/compiler/verify/vc_witness.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if grep -qE 'witness_horner|horner.*loop_eval' "$WITNESS_CPP" 2>/dev/null; then
  echo "FAIL: expected no witness_horner* in vc_witness.cpp (Horner loop gap)" >&2
  exit 1
fi
if grep -qE 'horner.*loop_eval|horner_fma.*spec' "$DISCHARGE" 2>/dev/null; then
  echo "FAIL: expected no horner loop_eval lemma in Discharge.lean yet" >&2
  exit 1
fi

"$LIC" check "$PROBE"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

build_bin() {
  local src="$1"
  local out="$TMP/$2"
  shift 2
  "$LIC" build "$src" -o "$out" --release "$@" >/dev/null 2>&1
  echo "$out"
}

count_fma() {
  objdump -d "$1" 2>/dev/null | awk '/<main>:/{f=1;next} /^[0-9a-f]+ <[^>]+>:/{if(f) exit} f' \
    | grep -cE 'vfmadd|fmuladd' || true
}

count_main_insns() {
  objdump -d "$1" 2>/dev/null | awk '/<main>:/{f=1;next} /^[0-9a-f]+ <[^>]+>:/{if(f) exit} f' | wc -l
}

if ! grep -q 'witness_dot4_int_loop' "$WITNESS_CPP" 2>/dev/null; then
  echo "FAIL: expected witness_dot4_int_loop contrast in vc_witness.cpp" >&2
  exit 1
fi

HORNER_FAST="$(build_bin "$PROBE" horner_fast)"
HORNER_STABLE="$(build_bin "$PROBE" horner_stable --numerically-stable)"
MATMUL_STABLE="$(build_bin "$MATMUL_PROBE" matmul_stable --numerically-stable)"

HORNER_FAST_FMA="$(count_fma "$HORNER_FAST")"
HORNER_STABLE_FMA="$(count_fma "$HORNER_STABLE")"
MATMUL_STABLE_FMA="$(count_fma "$MATMUL_STABLE")"
MAIN_INSNS="$(count_main_insns "$HORNER_FAST")"

if [[ "$MAIN_INSNS" -lt 50 ]]; then
  echo "FAIL: release horner main should retain FMA codegen (got ${MAIN_INSNS} insns; trip<5M may const-fold)" >&2
  exit 1
fi
if [[ "$HORNER_FAST_FMA" -lt 1 ]]; then
  echo "FAIL: default release horner should emit fmuladd (got ${HORNER_FAST_FMA})" >&2
  exit 1
fi
if [[ "$HORNER_STABLE_FMA" -lt 1 ]]; then
  echo "FAIL: --numerically-stable horner still uses HornerStepPow4 fmuladd (got ${HORNER_STABLE_FMA})" >&2
  exit 1
fi
if [[ "$MATMUL_STABLE_FMA" -ne 0 ]]; then
  echo "FAIL: --numerically-stable matmul IKJ should not use fmuladd (got ${MATMUL_STABLE_FMA})" >&2
  exit 1
fi

echo "PASS horner_fma_codegen_lean_drift: no Lean witness; horner fma=${HORNER_FAST_FMA}/${HORNER_STABLE_FMA}; matmul_stable fma=${MATMUL_STABLE_FMA}; main=${MAIN_INSNS}ins"
