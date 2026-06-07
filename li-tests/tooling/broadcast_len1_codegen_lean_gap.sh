#!/usr/bin/env bash
# G-math / PH-2i: length-1 broadcast lowers in MIR/codegen but has no Lean semantics or VC witness.
# Contrast: mat2_at2_float_spec / dot4_int_spec in Discharge.lean; manifest compile_ok only.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
LOWER="$ROOT/compiler/mir/lower.cpp"
EMIT="$ROOT/compiler/codegen/emit.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
WITNESS="$ROOT/compiler/verify/vc_witness.cpp"
MANIFEST="$ROOT/li-tests/manifest.toml"
FLOAT_PROBE="$ROOT/li-tests/math_linalg/broadcast_len1_add_float4.li"
INT_PROBE="$ROOT/li-tests/math_linalg/broadcast_len1_mul_int4.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'array_broadcast_rhs_len1 = (nb == 1 && na > 1)' "$LOWER"; then
  echo "FAIL: expected array_broadcast_rhs_len1 in lower.cpp" >&2
  exit 1
fi
if ! grep -q '!ins.array_broadcast_lhs_len1 && !ins.array_broadcast_rhs_len1' "$EMIT"; then
  echo "FAIL: expected SIMD disabled when broadcast len1 (emit.cpp)" >&2
  exit 1
fi
if grep -qi 'broadcast_len1\|broadcast_add\|array_broadcast' "$DISCHARGE" 2>/dev/null; then
  echo "FAIL: Discharge.lean should not yet define broadcast_len1 semantics" >&2
  exit 1
fi
if grep -qi 'witness.*broadcast\|broadcast_len1' "$WITNESS" 2>/dev/null; then
  echo "FAIL: vc_witness.cpp should not yet wire broadcast_len1 witness" >&2
  exit 1
fi
if ! grep -A2 'broadcast_len1_add_float4' "$MANIFEST" | grep -q 'compile_ok'; then
  echo "FAIL: broadcast_len1_add_float4 should be compile_ok not verify_ok" >&2
  exit 1
fi

"$LIC" check "$FLOAT_PROBE"
"$LIC" check "$INT_PROBE"

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$FLOAT_PROBE" -o /dev/null 2>/dev/null
if grep -qi 'broadcast_len1\|array_broadcast' "$AUTOVC"; then
  echo "FAIL: AutoVC should not reference broadcast semantics yet" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
"$LIC" build --no-lean-verify "$FLOAT_PROBE" -o "$TMP/probe" 2>/dev/null
objdump -d "$TMP/probe" >"$TMP/asm.txt"
if ! grep -q '<li_user_main>:' "$TMP/asm.txt"; then
  echo "FAIL: expected li_user_main in broadcast probe binary" >&2
  exit 1
fi
# Broadcast rhs: load b[0] once (movsd from d8), then reuse xmm0 via movaps for each addsd (emit.cpp:1137-1162).
USER_ASM="$(sed -n '/<li_user_main>:/,/^$/p' "$TMP/asm.txt")"
if ! grep -q 'addsd' <<<"$USER_ASM"; then
  echo "FAIL: broadcast add should emit addsd in li_user_main (use non-release build)" >&2
  exit 1
fi
if ! grep -q 'movaps.*xmm0' <<<"$USER_ASM"; then
  echo "FAIL: broadcast rhs should reuse loaded scalar (movaps xmm0 pattern)" >&2
  exit 1
fi

echo "PASS broadcast_len1_codegen_lean_gap: MIR/codegen OK; no Lean broadcast spec; compile_ok only"
