#!/usr/bin/env bash
# G-dec / G-meta: @vectorized for ArraySimdScope codegen vs Lean witness absence.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
if [[ ! -x "$LIC" ]]; then
  echo "vectorized_for_codegen_lean_drift: skip (no lic)" >&2
  exit 0
fi

fail() {
  echo "vectorized_for_codegen_lean_drift: $*" >&2
  exit 1
}

USER_MAIN_RE='/<li_user_main>:/,/^$/'

# No Lean witness for vectorized / SIMD array scope (contrast dot4 loop).
if grep -q 'witness_vectorized' "$ROOT/compiler/verify/vc_witness.cpp"; then
  fail "unexpected witness_vectorized in vc_witness.cpp"
fi
if grep -qE 'vectorized|simd.*eval|array_binop.*spec' "$ROOT/docs/semantics/Discharge.lean"; then
  fail "unexpected vectorized/simd lemma in Discharge.lean"
fi

VEC_PROBE="$ROOT/li-tests/codegen/vectorized_for_binop_codegen_probe.li"
SCALAR_PROBE="$ROOT/li-tests/codegen/no_vectorize_binop_codegen_probe.li"
"$LIC" check "$VEC_PROBE" >/dev/null
"$LIC" check "$SCALAR_PROBE" >/dev/null

WORK="$ROOT/build/li-test-vectorized-for-drift-$$"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK"

count_in_user_main() {
  local bin="$1"
  local pattern="$2"
  objdump -d "$bin" 2>/dev/null | awk "$USER_MAIN_RE" | grep -cE "$pattern" || true
}

"$LIC" build --release "$VEC_PROBE" -o "$WORK/vec" >/dev/null
"$LIC" build --release "$SCALAR_PROBE" -o "$WORK/scalar" >/dev/null

VEC_PACKED="$(count_in_user_main "$WORK/vec" 'vmulpd|vaddpd|vfmadd.*pd')"
SCALAR_PACKED="$(count_in_user_main "$WORK/scalar" 'vmulpd|vaddpd|vfmadd.*pd')"
VEC_SCALAR_MUL="$(count_in_user_main "$WORK/vec" 'vmulsd|vaddsd')"
SCALAR_MUL="$(count_in_user_main "$WORK/scalar" 'vmulsd|vaddsd')"
VEC_USER="$(objdump -d "$WORK/vec" 2>/dev/null | awk "$USER_MAIN_RE" | grep -cE '^\s+[0-9a-f]+:' || true)"

[[ "$VEC_PACKED" -ge 1 ]] || fail "expected vmulpd in vectorized-for probe (got $VEC_PACKED)"
[[ "$SCALAR_PACKED" -eq 0 ]] || fail "expected no vmulpd in @no_vectorize scalar probe (got $SCALAR_PACKED)"
[[ "$SCALAR_MUL" -ge 4 ]] || fail "expected vmulsd in @no_vectorize probe (got $SCALAR_MUL)"
[[ "$VEC_USER" -ge 30 ]] || fail "vectorized-for li_user_main too small ($VEC_USER insns) — DCE?"

OUT="$("$LIC" verify "$ROOT/li-tests/decorators/vectorized_dot_proc_ok.li" 2>&1)"
echo "$OUT" | grep -q 'mir_vectorized_proc=1'

echo "vectorized_for_codegen_lean_drift: ok vec_vmulpd=$VEC_PACKED scalar_vmulpd=$SCALAR_PACKED scalar_vmulsd=$SCALAR_MUL vec_user_main=$VEC_USER"
