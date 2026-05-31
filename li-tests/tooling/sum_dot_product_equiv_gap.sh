#!/usr/bin/env bash
# G-math / G-vc / PH-2i: sum(a*b) and dot(a,b) lower to different MIR/codegen; no Lean equiv;
# dot_via_sum_product.li computes both but manifest verify_ok with trivial main AutoVC only.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
LOWER="$ROOT/compiler/mir/lower.cpp"
EMIT="$ROOT/compiler/codegen/emit.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
WITNESS="$ROOT/compiler/verify/vc_witness.cpp"
MANIFEST="$ROOT/li-tests/manifest.toml"
SUM_DOT="$ROOT/li-tests/math_linalg/reductions/dot_via_sum_product.li"
SUM4="$ROOT/li-tests/math_linalg/reductions/sum_float4.li"
DOT_CLOSED="$ROOT/li-tests/contracts_verify/linalg_dot4_int_closed.li"
DOT_FLOAT="$ROOT/li-tests/contracts_verify/linalg_dot4_float_closed.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'e.ident == "sum"' "$LOWER"; then
  echo "FAIL: expected sum prelude lowering in lower.cpp" >&2
  exit 1
fi
if ! grep -q 'MirOp::ArraySumF64' "$LOWER"; then
  echo "FAIL: expected ArraySumF64 in lower.cpp" >&2
  exit 1
fi
if ! grep -q 'lower_float_array_dot_f64' "$LOWER"; then
  echo "FAIL: expected dot lowering helper in lower.cpp" >&2
  exit 1
fi
if ! grep -q 'case MirOp::ArraySumF64:' "$EMIT"; then
  echo "FAIL: expected ArraySumF64 codegen in emit.cpp" >&2
  exit 1
fi
if ! grep -q 'case MirOp::ArrayDotF64:' "$EMIT"; then
  echo "FAIL: expected ArrayDotF64 codegen in emit.cpp" >&2
  exit 1
fi
if grep -q 'fp_numerically_stable' "$EMIT" && ! sed -n '/case MirOp::ArrayDotF64:/,/case MirOp::LoadIntToIdent:/p' "$EMIT" | grep -q 'fp_numerically_stable'; then
  : # ArrayDotF64 must not gate on numerically-stable (contrast ArraySumF64)
else
  if sed -n '/case MirOp::ArrayDotF64:/,/case MirOp::LoadIntToIdent:/p' "$EMIT" | grep -q 'fp_numerically_stable'; then
    echo "FAIL: ArrayDotF64 unexpectedly uses fp_numerically_stable" >&2
    exit 1
  fi
fi
if grep -qi 'sum_dot\|sum4_float_spec\|dot_sum_equiv\|sum_product' "$DISCHARGE" 2>/dev/null; then
  echo "FAIL: Discharge.lean should not yet define sum/dot equivalence specs" >&2
  exit 1
fi
if grep -qi 'witness.*sum.*dot\|sum_dot_equiv' "$WITNESS" 2>/dev/null; then
  echo "FAIL: vc_witness.cpp should not yet wire sum/dot equivalence" >&2
  exit 1
fi

if ! grep -A2 'dot_via_sum_product' "$MANIFEST" | grep -q 'verify_ok'; then
  echo "FAIL: dot_via_sum_product should still be verify_ok (G-test-verify overclaim under test)" >&2
  exit 1
fi

"$LIC" check "$SUM_DOT"
"$LIC" check "$SUM4"

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$SUM_DOT" -o /dev/null 2>/dev/null
if ! grep -q 'vc_main_ensures_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: dot_via_sum_product AutoVC should stub main ensures True only" >&2
  exit 1
fi
if grep -qi 'sum_dot\|dot4_float_spec\|Discharge\.' "$AUTOVC"; then
  echo "FAIL: dot_via_sum_product AutoVC should not reference sum/dot Discharge specs" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$DOT_CLOSED" -o /dev/null 2>/dev/null
if ! grep -q 'dot4_int' "$AUTOVC"; then
  echo "FAIL: closed int dot control should emit real dot4_int VCs (contrast float prelude)" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$DOT_FLOAT" -o /dev/null 2>/dev/null
if ! grep -q 'prelude dot() return witness' "$AUTOVC"; then
  echo "FAIL: float dot closed specimen should use prelude dot stub witness" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
"$LIC" build --no-lean-verify "$SUM_DOT" -o "$TMP/sum_dot" 2>/dev/null
"$LIC" build --no-lean-verify "$DOT_FLOAT" -o "$TMP/dot_only" 2>/dev/null
MAIN_ASM="$(sed -n '/<li_user_main>:/,/^$/p' <(objdump -d "$TMP/sum_dot"))"
if ! grep -q 'mulsd' <<<"$MAIN_ASM"; then
  echo "FAIL: dot_via_sum_product should emit elementwise mulsd before sum" >&2
  exit 1
fi
DOT_ASM="$(sed -n '/<dot4_float>:/,/^$/p' <(objdump -d "$TMP/dot_only"))"
if [[ -z "$DOT_ASM" ]]; then
  echo "FAIL: expected dot4_float symbol in dot closed binary" >&2
  exit 1
fi

"$LIC" build --no-lean-verify "$SUM4" -o "$TMP/sum_def" 2>/dev/null
"$LIC" build --no-lean-verify --numerically-stable "$SUM4" -o "$TMP/sum_stable" 2>/dev/null
DEF_ADDS="$(sed -n '/<li_user_main>:/,/^$/p' <(objdump -d "$TMP/sum_def") | grep -cE 'addsd|subsd' || true)"
STABLE_ADDS="$(sed -n '/<li_user_main>:/,/^$/p' <(objdump -d "$TMP/sum_stable") | grep -cE 'addsd|subsd' || true)"
if [[ "$STABLE_ADDS" -le "$DEF_ADDS" ]]; then
  echo "FAIL: --numerically-stable should expand ArraySumF64 Kahan adds (got def=$DEF_ADDS stable=$STABLE_ADDS)" >&2
  exit 1
fi
"$LIC" build --no-lean-verify --numerically-stable "$SUM_DOT" -o "$TMP/sum_dot_stable" 2>/dev/null
STABLE_MULS="$(sed -n '/<li_user_main>:/,/^$/p' <(objdump -d "$TMP/sum_dot_stable") | grep -c mulsd || true)"
DEF_MULS="$(sed -n '/<li_user_main>:/,/^$/p' <(objdump -d "$TMP/sum_dot") | grep -c mulsd || true)"
if [[ "$STABLE_MULS" -ne "$DEF_MULS" ]]; then
  echo "FAIL: stable flag should not change elementwise mul count (def=$DEF_MULS stable=$STABLE_MULS)" >&2
  exit 1
fi
DOT_STABLE_MULS="$(sed -n '/<li_user_main>:/,/^$/p' <(objdump -d "$TMP/sum_dot_stable") | grep -c mulsd || true)"
if [[ "$DOT_STABLE_MULS" -ne "$DEF_MULS" ]]; then
  echo "FAIL: dot path mul count unchanged under stable (expected same as default)" >&2
  exit 1
fi

echo "PASS sum_dot_product_equiv_gap: divergent MIR/codegen; no Lean equiv; trivial AutoVC; stable affects sum only"
