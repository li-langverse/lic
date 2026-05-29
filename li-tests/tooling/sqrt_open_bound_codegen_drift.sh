#!/usr/bin/env bash
# G-vc / P-float: open Float.abs ensures in AutoVC but codegen emits bare li_rt_sqrt (no runtime witness).
# Passes while the gap is open; update when ensures codegen or P-float discharge lands.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/sqrt_open_bound.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
BIN="$(mktemp -t li_sqrt_codegen.XXXXXX)"
trap 'rm -f "$BIN"' EXIT

rm -f "$AUTOVC"
"$LIC" build --allow-open-vc "$SAMPLE" -o "$BIN"
test -f "$AUTOVC"

if ! grep -qE 'def vc_sqrt_open_ensures_0.*Float\.abs' "$AUTOVC"; then
  echo "sqrt_open_bound_codegen_drift: expected Float.abs ensures Prop in AutoVC"
  exit 1
fi
if grep -q 'theorem vc_sqrt_open_ensures_0_proved' "$AUTOVC"; then
  echo "sqrt_open_bound_codegen_drift: gap closed — update script when ensures_0_proved lands"
  exit 1
fi

# Codegen: sqrt_open must call li_rt_sqrt and return without runtime ensures check.
DISASM="$(objdump -d "$BIN" --disassemble=sqrt_open 2>/dev/null || true)"
if ! echo "$DISASM" | grep -q 'call.*li_rt_sqrt'; then
  echo "sqrt_open_bound_codegen_drift: expected sqrt_open → li_rt_sqrt call in codegen"
  exit 1
fi
if echo "$DISASM" | grep -qE 'call.*(li_bounds_fail|li_panic|li_contract)'; then
  echo "sqrt_open_bound_codegen_drift: unexpected runtime contract hook in sqrt_open — update script"
  exit 1
fi

# Callee extern ensures true — no return-linkage VC beyond requires True.
if ! grep -q 'def vc_sqrt_open_call0_li_rt_sqrt_requires_0.*Prop := True' "$AUTOVC"; then
  echo "sqrt_open_bound_codegen_drift: expected trivial callee requires stub"
  exit 1
fi
if grep -q 'vc_sqrt_open_call0_li_rt_sqrt_ensures' "$AUTOVC"; then
  echo "sqrt_open_bound_codegen_drift: unexpected callee ensures VC — update script if linkage added"
  exit 1
fi

# lic check still passes without VC emission (check ≠ certificate).
if ! "$LIC" check "$SAMPLE" >/dev/null 2>&1; then
  echo "sqrt_open_bound_codegen_drift: sqrt_open_bound must pass lic check while gap open"
  exit 1
fi

echo "sqrt_open_bound_codegen_drift: ok (documented G-vc codegen↔Lean ensures drift)"
