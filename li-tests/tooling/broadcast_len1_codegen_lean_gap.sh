#!/usr/bin/env bash
# G-math / PH-2i: length-1 broadcast — MIR/codegen + Lean Discharge spec + VC witness (BUG-C-03 closed).
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
CLOSED_ADD="$ROOT/li-tests/contracts_verify/linalg_broadcast_len1_add_float4_closed.li"
FLOAT_PROBE="$ROOT/li-tests/math_linalg/broadcast_len1_add_float4.li"
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
if ! grep -q 'witness_broadcast_len1_discharge' "$WITNESS"; then
  echo "FAIL: expected witness_broadcast_len1_discharge in vc_witness.cpp" >&2
  exit 1
fi
if ! grep -q 'broadcast_len1_add_float4_spec_proved' "$VC_EMIT"; then
  echo "FAIL: expected broadcast_len1 discharge in vc_emit_lean.cpp" >&2
  exit 1
fi
if ! grep -A2 'linalg_broadcast_len1_add_float4_closed' "$MANIFEST" | grep -q 'verify_ok'; then
  echo "FAIL: closed broadcast specimen should be verify_ok in manifest" >&2
  exit 1
fi
if ! grep -A2 'broadcast_len1_add_float4' "$MANIFEST" | grep -q 'compile_ok'; then
  echo "FAIL: runtime broadcast_len1_add_float4 smoke should remain compile_ok" >&2
  exit 1
fi

"$LIC" check "$CLOSED_ADD"
"$LIC" check "$FLOAT_PROBE"

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$CLOSED_ADD" -o /dev/null 2>/dev/null
if ! grep -q 'Li.Discharge.broadcast_len1_add_float4_eval' "$AUTOVC"; then
  echo "FAIL: AutoVC should use broadcast_len1_add_float4_eval in ensures" >&2
  exit 1
fi
if grep -q 'vc_broadcast_len1_add_float4_ensures_0.*result' "$AUTOVC" 2>/dev/null; then
  echo "FAIL: broadcast ensures VC should not quantify over result (eval substitution)" >&2
  exit 1
fi
if ! grep -q 'broadcast_len1_add_float4_spec_proved' "$AUTOVC"; then
  echo "FAIL: expected discharge theorem reference in AutoVC" >&2
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

echo "PASS broadcast_len1_codegen_lean_gap: MIR/codegen + Lean broadcast_len1 spec + verify_ok closed slice"
