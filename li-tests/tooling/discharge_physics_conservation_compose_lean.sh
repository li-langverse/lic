#!/usr/bin/env bash
# P-LM-CONS-001: closed-system conservation composition → zero open Prop goals + Discharge.lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/proof-db/physics/lemmas/energy_drift_bound.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
rm -f "$AUTOVC"
"$LIC" build "$SAMPLE" -o /dev/null
test -f "$AUTOVC"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
grep -q 'closed_system_invariants_compose' "$AUTOVC" || {
  echo "discharge_physics_conservation_compose_lean: missing closed_system_invariants_compose in AutoVC"
  exit 1
}
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
if command -v lake >/dev/null 2>&1; then
  (cd "$ROOT/docs/semantics" && lake build)
  echo "discharge_physics_conservation_compose_lean: lake ok"
else
  echo "discharge_physics_conservation_compose_lean: skipped lake (not installed)"
fi
echo "discharge_physics_conservation_compose_lean: ok"
