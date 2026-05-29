#!/usr/bin/env bash
# G-dec / P-dec: @vectorized on for lowers ArraySimdScope → f64x4 codegen but AutoVC has no SIMD correctness VC.
# Passes while the gap is open; update when P-dec elaboration proofs or vectorization VCs land.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/decorators/vectorized_for_scope_ok.li"
CTRL="$ROOT/li-tests/decorators/vectorized_for_scope_scalar_ctrl.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
BIN_SIMD="$(mktemp -t li_vec_for_simd.XXXXXX)"
BIN_SCALAR="$(mktemp -t li_vec_for_scalar.XXXXXX)"
trap 'rm -f "$BIN_SIMD" "$BIN_SCALAR"' EXIT

rm -f "$AUTOVC"
"$LIC" build "$SAMPLE" -o "$BIN_SIMD"
test -f "$AUTOVC"
"$LIC" build "$CTRL" -o "$BIN_SCALAR"

# Codegen: scoped @vectorized on for must emit packed double SIMD (mulpd), not scalar mulsd only.
DISASM_SIMD="$(objdump -d "$BIN_SIMD" --disassemble=li_user_main 2>/dev/null || true)"
if ! echo "$DISASM_SIMD" | grep -qE 'mulpd|vmulpd'; then
  echo "vectorized_for_scope_codegen_lean_gap: expected mulpd/vmulpd in @vectorized for body"
  exit 1
fi
DISASM_SCALAR="$(objdump -d "$BIN_SCALAR" --disassemble=li_user_main 2>/dev/null || true)"
if echo "$DISASM_SCALAR" | grep -qE 'mulpd|vmulpd'; then
  echo "vectorized_for_scope_codegen_lean_gap: scalar control must not use mulpd — gap closed; update script"
  exit 1
fi
if ! echo "$DISASM_SCALAR" | grep -qE 'mulsd|vmulsd'; then
  echo "vectorized_for_scope_codegen_lean_gap: scalar control missing mulsd in element-wise body"
  exit 1
fi

# Lean: no vectorization / ArraySimdScope correctness obligations in AutoVC (P-dec open).
if grep -qiE 'vector|simd|ArraySimd|G-dec|lanes' "$AUTOVC"; then
  echo "vectorized_for_scope_codegen_lean_gap: unexpected vectorization VC in AutoVC — update script if P-dec lands"
  exit 1
fi
if ! grep -qE 'def vc_main_ensures_0.*Prop := True' "$AUTOVC"; then
  echo "vectorized_for_scope_codegen_lean_gap: expected trivial ensures stub while P-dec open"
  exit 1
fi
if ! grep -q 'theorem vc_main_ensures_0_proved' "$AUTOVC"; then
  echo "vectorized_for_scope_codegen_lean_gap: expected trivial ensures discharge"
  exit 1
fi

if ! "$LIC" check "$SAMPLE" >/dev/null 2>&1; then
  echo "vectorized_for_scope_codegen_lean_gap: specimen must pass lic check (typecheck fence)"
  exit 1
fi

echo "vectorized_for_scope_codegen_lean_gap: ok (documented G-dec codegen↔Lean vectorized-for drift)"
