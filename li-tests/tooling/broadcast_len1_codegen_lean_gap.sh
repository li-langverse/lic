#!/usr/bin/env bash
# G-math / PH-2i: length-1 broadcast — MIR/codegen + closed Lean spec (BUG-C-03 closed slice).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
LOWER="$ROOT/compiler/mir/lower.cpp"
EMIT="$ROOT/compiler/codegen/emit.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
WITNESS="$ROOT/compiler/verify/vc_witness.cpp"
MANIFEST="$ROOT/li-tests/manifest.toml"
CLOSED="$ROOT/li-tests/contracts_verify/linalg_broadcast_len1_add_float4_closed.li"
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
if ! grep -q 'broadcast_len1_add_float4_spec' "$DISCHARGE"; then
  echo "FAIL: Discharge.lean should define broadcast_len1_add_float4_spec" >&2
  exit 1
fi
if ! grep -q 'witness_broadcast_len1_add_spec' "$WITNESS"; then
  echo "FAIL: vc_witness.cpp should wire broadcast_len1 witness" >&2
  exit 1
fi
if ! grep -A2 'linalg_broadcast_len1_add_float4_closed' "$MANIFEST" | grep -q 'prove_lean_ok'; then
  echo "FAIL: closed broadcast specimen should be prove_lean_ok" >&2
  exit 1
fi
if ! grep -A2 'broadcast_len1_add_float4.li' "$MANIFEST" | grep -q 'compile_ok'; then
  echo "FAIL: math_linalg smoke should remain compile_ok (no contracts)" >&2
  exit 1
fi

"$LIC" check "$FLOAT_PROBE"
"$LIC" check "$INT_PROBE"
"$LIC" check "$CLOSED"

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$CLOSED" -o /dev/null 2>/dev/null
if ! grep -q 'broadcast_len1_add_float4_spec' "$AUTOVC"; then
  echo "FAIL: AutoVC should reference broadcast_len1_add_float4_spec for closed specimen" >&2
  exit 1
fi
if ! grep -q 'broadcast_len1_add_float4_spec_proved' "$AUTOVC"; then
  echo "FAIL: AutoVC should discharge broadcast_len1 via _proved theorem" >&2
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
USER_ASM="$(sed -n '/<li_user_main>:/,/^$/p' "$TMP/asm.txt")"
if ! grep -q 'addsd' <<<"$USER_ASM"; then
  echo "FAIL: broadcast add should emit addsd in li_user_main (use non-release build)" >&2
  exit 1
fi
if ! grep -q 'movaps.*xmm0' <<<"$USER_ASM"; then
  echo "FAIL: broadcast rhs should reuse loaded scalar (movaps xmm0 pattern)" >&2
  exit 1
fi

echo "PASS broadcast_len1_codegen_lean_gap: MIR/codegen + Lean broadcast_len1 closed slice"
