#!/usr/bin/env bash
# G-test-verify / G-math / PH-2i: prelude scale|axpy|norm codegen exists but manifest marks verify_ok
# while AutoVC is trivial main-only (contrast broadcast_len1 compile_ok; linalg_axpy4_int_closed).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
LOWER="$ROOT/compiler/mir/lower.cpp"
EMIT="$ROOT/compiler/codegen/emit.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
WITNESS="$ROOT/compiler/verify/vc_witness.cpp"
MANIFEST="$ROOT/li-tests/manifest.toml"
SCALE="$ROOT/li-tests/math_linalg/scale_float4.li"
AXPY="$ROOT/li-tests/math_linalg/axpy_float4.li"
NORM="$ROOT/li-tests/math_linalg/norm_float4.li"
CLOSED="$ROOT/li-tests/contracts_verify/linalg_axpy4_int_closed.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'MirOp::ArrayScaleF64' "$LOWER"; then
  echo "FAIL: expected ArrayScaleF64 in lower.cpp" >&2
  exit 1
fi
if ! grep -q 'MirOp::ArrayAxpyF64' "$LOWER"; then
  echo "FAIL: expected ArrayAxpyF64 in lower.cpp" >&2
  exit 1
fi
if ! grep -q 'e.ident == "norm"' "$LOWER"; then
  echo "FAIL: expected norm prelude lowering in lower.cpp" >&2
  exit 1
fi
if ! grep -q 'case MirOp::ArrayScaleF64:' "$EMIT"; then
  echo "FAIL: expected ArrayScaleF64 codegen in emit.cpp" >&2
  exit 1
fi
if grep -qi 'scale_spec\|axpy_spec\|norm_spec\|ArrayScale\|ArrayAxpy' "$DISCHARGE" 2>/dev/null; then
  echo "FAIL: Discharge.lean should not yet define prelude scale/axpy/norm specs" >&2
  exit 1
fi
if grep -qi 'witness.*scale\|witness.*axpy\|witness.*norm' "$WITNESS" 2>/dev/null; then
  echo "FAIL: vc_witness.cpp should not yet wire prelude scale/axpy/norm" >&2
  exit 1
fi

for probe in scale_float4 axpy_float4 norm_float4; do
  if ! grep -A2 "$probe" "$MANIFEST" | grep -q 'verify_ok'; then
    echo "FAIL: $probe should still be verify_ok (G-test-verify overclaim under test)" >&2
    exit 1
  fi
done

"$LIC" check "$SCALE"
"$LIC" check "$AXPY"
"$LIC" check "$NORM"

for probe in "$SCALE" "$AXPY" "$NORM"; do
  rm -f "$AUTOVC"
  "$LIC" build --no-lean-verify "$probe" -o /dev/null 2>/dev/null
  if grep -qi 'scale\|axpy\|norm\|ArrayScale\|ArrayAxpy\|Discharge\.' "$AUTOVC"; then
    echo "FAIL: AutoVC for $probe should not reference prelude linalg Discharge specs" >&2
    exit 1
  fi
  if ! grep -q 'vc_main_ensures_0.*Prop := True' "$AUTOVC"; then
    echo "FAIL: $probe AutoVC should stub main ensures True only" >&2
    exit 1
  fi
done

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$CLOSED" -o /dev/null 2>/dev/null
if ! grep -q 'axpy4_int' "$AUTOVC"; then
  echo "FAIL: closed axpy4 control should emit real axpy4_int VCs (contrast)" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
"$LIC" build --no-lean-verify "$SCALE" -o "$TMP/probe" 2>/dev/null
objdump -d "$TMP/probe" >"$TMP/asm.txt"
USER_ASM="$(sed -n '/<li_user_main>:/,/^$/p' "$TMP/asm.txt")"
if ! grep -q 'mulsd' <<<"$USER_ASM"; then
  echo "FAIL: scale_float4 should emit mulsd scalar×array in li_user_main" >&2
  exit 1
fi

echo "PASS prelude_linalg_manifest_tier_gap: codegen OK; trivial AutoVC; manifest verify_ok overclaim"
