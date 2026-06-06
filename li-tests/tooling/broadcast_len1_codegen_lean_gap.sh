#!/usr/bin/env bash
# G-math / PH-2i: length-1 broadcast lowers in MIR/codegen with Lean semantics + VC witness.
# Contrast: mat2_at2_float_spec / dot4_int_spec in Discharge.lean; closed P-linalg specimen.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
LOWER="$ROOT/compiler/mir/lower.cpp"
EMIT="$ROOT/compiler/codegen/emit.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
WITNESS="$ROOT/compiler/verify/vc_witness.cpp"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
MANIFEST="$ROOT/li-tests/manifest.toml"
CLOSED_SAMPLE="$ROOT/li-tests/contracts_verify/linalg_broadcast_len1_add_float4_closed.li"
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
if ! grep -q 'broadcast_len1_add_float4_spec_proved' "$DISCHARGE"; then
  echo "FAIL: expected broadcast_len1_add_float4_spec_proved in Discharge.lean" >&2
  exit 1
fi
if ! grep -q 'witness_broadcast_len1_add_float4_spec' "$WITNESS"; then
  echo "FAIL: expected witness_broadcast_len1_add_float4_spec in vc_witness.cpp" >&2
  exit 1
fi
if ! grep -q 'broadcast_len1_add_float4_spec' "$VC_EMIT"; then
  echo "FAIL: vc_emit_lean should wire broadcast_len1_add_float4_spec discharge" >&2
  exit 1
fi
if ! grep -A2 'linalg_broadcast_len1_add_float4_closed' "$MANIFEST" | grep -q 'prove_lean_ok'; then
  echo "FAIL: linalg_broadcast_len1_add_float4_closed should be prove_lean_ok" >&2
  exit 1
fi

"$LIC" check "$FLOAT_PROBE"
"$LIC" check "$INT_PROBE"

rm -f "$AUTOVC"
"$LIC" build "$CLOSED_SAMPLE" -o /dev/null 2>/dev/null
if ! grep -q 'Li.Discharge.broadcast_len1_add_float4_spec' "$AUTOVC"; then
  echo "FAIL: closed specimen should emit Li.Discharge.broadcast_len1_add_float4_spec" >&2
  exit 1
fi
if ! grep -q 'Li.Discharge.broadcast_len1_add_float4_eval' "$AUTOVC"; then
  echo "FAIL: closed specimen should emit Li.Discharge.broadcast_len1_add_float4_eval" >&2
  exit 1
fi
if ! grep -q 'broadcast_len1_add_float4_spec_proved' "$AUTOVC"; then
  echo "FAIL: closed specimen should discharge via broadcast_len1_add_float4_spec_proved" >&2
  exit 1
fi
if grep -q 'vc_broadcast_len1_add_float4_ensures_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: broadcast ensures should not stub True" >&2
  exit 1
fi

chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$FLOAT_PROBE" -o /dev/null 2>/dev/null
if grep -qi 'broadcast_len1\|array_broadcast' "$AUTOVC"; then
  echo "FAIL: math_linalg smoke should not emit broadcast Lean props (main-only trivial VC)" >&2
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

echo "PASS broadcast_len1_codegen_lean_gap: MIR/codegen + Lean broadcast_len1_add_float4_spec closed"
