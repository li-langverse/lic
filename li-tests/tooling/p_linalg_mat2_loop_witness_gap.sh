#!/usr/bin/env bash
# G-vc / P-linalg: mat2 IKJ loop specimen has no dot4-style witness; AutoVC stays open until lemmas land.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/linalg_mat2_int_loop_no_witness.li"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
rm -f "$AUTOVC"
if "$LIC" build "$SAMPLE" -o /dev/null 2>/dev/null; then
  echo "p_linalg_mat2_loop_witness_gap: expected lic build to fail without --allow-open-vc"
  exit 1
fi
rm -f "$AUTOVC"
"$LIC" build --allow-open-vc "$SAMPLE" -o /dev/null
test -f "$AUTOVC"
if grep -q 'Li\.Discharge\.mat2' "$AUTOVC"; then
  echo "p_linalg_mat2_loop_witness_gap: unexpected mat2_at2 discharge on loop specimen"
  exit 1
fi
if "$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"; then
  echo "p_linalg_mat2_loop_witness_gap: expected open Prop goals for loop matmul"
  exit 1
fi
echo "p_linalg_mat2_loop_witness_gap: ok"
