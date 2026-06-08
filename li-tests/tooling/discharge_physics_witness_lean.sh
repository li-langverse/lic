#!/usr/bin/env bash
# P-LM-BC-MEC-004/005/008/009/010: identity witness specimens → zero open Prop goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
for sample in \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_mec_004.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_mec_005.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_mec_008.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_mec_009.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_mec_010.li"; do
  AUTOVC="$ROOT/build/generated/AutoVC.lean"
  rm -f "$AUTOVC"
  "$LIC" build "$sample" -o /dev/null
  test -f "$AUTOVC"
  "$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
done
if command -v lake >/dev/null 2>&1; then
  (cd "$ROOT/docs/semantics" && lake build)
  echo "discharge_physics_witness_lean: lake ok"
else
  echo "discharge_physics_witness_lean: skipped lake (not installed)"
fi
echo "discharge_physics_witness_lean: ok"
