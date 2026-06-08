#!/usr/bin/env bash
# P-LM-BC-MEC-006: scalar kinetic energy specimen → zero open Prop goals + Discharge.lean rfl.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/proof-db/physics/basic-corpus/p_lm_bc_mec_006.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
rm -f "$AUTOVC"
"$LIC" build "$SAMPLE" -o /dev/null
test -f "$AUTOVC"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
grep -q 'kinetic_energy' "$AUTOVC" || {
  echo "discharge_physics_kinetic_energy_lean: missing kinetic_energy in AutoVC"
  exit 1
}
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
if command -v lake >/dev/null 2>&1; then
  (cd "$ROOT/docs/semantics" && lake build)
  echo "discharge_physics_kinetic_energy_lean: lake ok"
else
  echo "discharge_physics_kinetic_energy_lean: skipped lake (not installed)"
fi
echo "discharge_physics_kinetic_energy_lean: ok"
