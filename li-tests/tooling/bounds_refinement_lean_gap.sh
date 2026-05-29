#!/usr/bin/env bash
# G-bnd / P-refine: refinement-typed indices typecheck but AutoVC + codegen omit bounds proof.
# Passes while the gap is open; fails when real Lean bounds land (update this script + manifest).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/index_refinement.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
BIN="$(mktemp -t li_bounds_refine.XXXXXX)"
trap 'rm -f "$BIN"' EXIT

rm -f "$AUTOVC"
"$LIC" build "$SAMPLE" -o "$BIN"
test -f "$AUTOVC"

# Lean gate must not encode Index10 bounds on param i (still plain Int + True).
if ! grep -q 'def vc_get_requires_0 (a : LiArray Int 10) (i : Int) : Prop := True' "$AUTOVC"; then
  echo "bounds_refinement_lean_gap: expected stub vc_get_requires_0 — gap may be closed; update script"
  exit 1
fi
if grep -qE '0 <= i|i < 10' "$AUTOVC"; then
  echo "bounds_refinement_lean_gap: unexpected refinement bounds in AutoVC — update script for closed gap"
  exit 1
fi

# Codegen: get must not call li_bounds_fail (only linked from li_rt, unused).
if objdump -d "$BIN" --disassemble=get 2>/dev/null | grep -q 'call.*li_bounds_fail'; then
  echo "bounds_refinement_lean_gap: get calls li_bounds_fail — update script if runtime guard is intentional"
  exit 1
fi

echo "bounds_refinement_lean_gap: ok (documented G-bnd / P-refine stub)"
