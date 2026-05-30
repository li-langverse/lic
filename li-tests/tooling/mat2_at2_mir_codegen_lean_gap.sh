#!/usr/bin/env bash
# G-lean / G-meta / G-math: 2×2 `@` Lean certificate uses mat2_at2_eval; MIR uses ArrayMatMul2DF64.
# No lemma links codegen to Li.Discharge.mat2_at2_eval (provability-gaps.md G-lean still-open row).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
CLOSED="$ROOT/li-tests/contracts_verify/linalg_mat2_at2_float_closed.li"
PROBE="$ROOT/li-tests/math_linalg/mat2_at2_codegen_probe.li"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
VC_WITNESS="$ROOT/compiler/verify/vc_witness.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
TRUSTED="$ROOT/docs/semantics/trusted.lean"
MANIFEST="$ROOT/li-tests/manifest.toml"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'witness_mat2_int_at2_spec' "$VC_WITNESS"; then
  echo "FAIL: expected witness_mat2_int_at2_spec in vc_witness.cpp" >&2
  exit 1
fi
if ! grep -q 'mat2_at2_float_spec_proved' "$VC_EMIT"; then
  echo "FAIL: expected mat2_at2_float_spec_proved discharge in vc_emit_lean.cpp" >&2
  exit 1
fi
if grep -qE 'ArrayMatMul|mat2_at2_eval.*MIR|mir_matmul' "$DISCHARGE" "$TRUSTED" 2>/dev/null; then
  echo "FAIL: unexpected MIR/matmul bridge in Discharge/trusted" >&2
  exit 1
fi
if ! test -f "$ROOT/docs/semantics/MIR.lean"; then
  : # planned — no preservation lemmas yet
fi

"$LIC" check "$CLOSED"
"$LIC" check "$PROBE"

rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$CLOSED" -o /dev/null 2>/dev/null
if ! grep -q 'Li.Discharge.mat2_at2_eval' "$AUTOVC"; then
  echo "FAIL: AutoVC should use mat2_at2_eval in ensures" >&2
  exit 1
fi
if grep -q 'vc_mat2_at2_ensures_0.*result' "$AUTOVC"; then
  echo "FAIL: mat2 ensures VC should not quantify over result (eval substitution)" >&2
  exit 1
fi
if ! grep -q 'mat2_at2_float_spec_proved' "$AUTOVC"; then
  echo "FAIL: expected discharge theorem reference in AutoVC" >&2
  exit 1
fi

if ! grep -A2 'linalg_mat2_at2_float_closed' "$MANIFEST" | grep -q 'verify_ok'; then
  echo "FAIL: manifest should tier closed mat2 as verify_ok (not prove_lean_ok)" >&2
  exit 1
fi
if grep -q 'prove_lean_ok' "$ROOT/li-tests/run_all.sh"; then
  echo "FAIL: run_all.sh should not implement prove_lean_ok yet (G-test-verify)" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
"$LIC" build --no-lean-verify "$PROBE" -o "$TMP/probe" 2>/dev/null
ASM="$(sed -n '/<li_user_main>:/,/^$/p' <(objdump -d "$TMP/probe" 2>/dev/null))"
if ! grep -q mulsd <<<"$ASM"; then
  echo "FAIL: li_user_main should emit mulsd for 2×2 @ (ArrayMatMul2DF64 unrolled path)" >&2
  exit 1
fi
if grep -q vfmadd <<<"$ASM"; then
  echo "NOTE: main @ path may use FMA when numerically-stable off (G-hw associativity deferred)"
fi

echo "PASS mat2_at2_mir_codegen_lean_gap: eval-based Lean VC; MIR @ codegen; no MIR↔eval lemma"
