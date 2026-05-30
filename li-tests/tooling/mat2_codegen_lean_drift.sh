#!/usr/bin/env bash
# G-lean / G-math / G-meta: mat2_at2_float closed VCs discharge Li.Discharge.mat2_at2_eval,
# not MIR ArrayMatMul2DF64 (emit.cpp). Certificate passes without codegen refinement proof.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/linalg_mat2_at2_float_closed.li"
GOLDEN="$ROOT/li-tests/math_linalg/mat2_at2_golden_2x2.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
OUT="$(mktemp -t mat2_codegen_drift.XXXXXX)"

rm -f "$AUTOVC"
if ! "$LIC" build "$SAMPLE" -o "$OUT" >/dev/null 2>&1; then
  echo "mat2_codegen_lean_drift: linalg_mat2_at2_float_closed build must pass (closed eval witness)"
  exit 1
fi
test -f "$AUTOVC"

if ! grep -q 'Li\.Discharge\.mat2_at2_eval' "$AUTOVC"; then
  echo "mat2_codegen_lean_drift: AutoVC must reference mat2_at2_eval in ensures"
  exit 1
fi
if ! grep -q 'Li\.Discharge\.mat2_at2_float_spec_proved' "$AUTOVC"; then
  echo "mat2_codegen_lean_drift: AutoVC must discharge via mat2_at2_float_spec_proved"
  exit 1
fi
if grep -qE 'mir_return_linked|ArrayMatMul' "$AUTOVC"; then
  echo "mat2_codegen_lean_drift: unexpected MIR/codegen link in AutoVC (gap may be closed)"
  exit 1
fi

if ! "$LIC" check "$GOLDEN" >/dev/null 2>&1; then
  echo "mat2_codegen_lean_drift: golden 2x2 runtime witness must pass lic check"
  exit 1
fi
if ! "$LIC" build "$GOLDEN" -o "$OUT" --no-lean-verify >/dev/null 2>&1; then
  echo "mat2_codegen_lean_drift: golden 2x2 must build"
  exit 1
fi
if ! "$OUT" >/dev/null 2>&1; then
  echo "mat2_codegen_lean_drift: golden runtime must exit 0 (codegen matches eval on fixture)"
  exit 1
fi

if ! "$ROOT/li-tests/tooling/mat2_fma_lean_drift.sh" >/dev/null 2>&1; then
  echo "mat2_codegen_lean_drift: FMA-vs-Lean drift witness must pass (see mat2_fma_lean_drift.sh)"
  exit 1
fi

rm -f "$OUT"
echo "mat2_codegen_lean_drift: ok (documented eval-vs-MIR certificate gap; runtime golden passes)"
