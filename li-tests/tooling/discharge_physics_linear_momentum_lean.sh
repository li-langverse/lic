#!/usr/bin/env bash
# P-LM-MOM-001: linear momentum specimen → zero open Prop goals + Discharge.lean rfl.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/proof-db/physics/lemmas/linear_momentum.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
rm -f "$AUTOVC"
"$LIC" build "$SAMPLE" -o /dev/null
test -f "$AUTOVC"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
grep -q 'linear_momentum' "$AUTOVC" || {
  echo "discharge_physics_linear_momentum_lean: missing linear_momentum in AutoVC"
  exit 1
}
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
if command -v lake >/dev/null 2>&1; then
  (cd "$ROOT/docs/semantics" && lake build)
  echo "discharge_physics_linear_momentum_lean: lake ok"
else
  echo "discharge_physics_linear_momentum_lean: skipped lake (not installed)"
fi
echo "discharge_physics_linear_momentum_lean: ok"
