#!/usr/bin/env bash
# G-vc / G-lean / P-float: sqrt_open_bound emits real Float.abs Prop; tier-0 build gate; env bypass removed.
# Passes while the gap is open; fails when ensures_0_proved lands (update script + manifest).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/sqrt_open_bound.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
CHECK_GOALS="$ROOT/scripts/check-autovc-open-goals.sh"

chmod +x "$CHECK_GOALS"

rm -f "$AUTOVC"
if LI_ALLOW_OPEN_VC=1 "$LIC" build "$SAMPLE" -o /dev/null 2>/dev/null; then
  echo "sqrt_open_bound_contract_tier: LI_ALLOW_OPEN_VC must not bypass build gate"
  exit 1
fi

if "$LIC" build "$SAMPLE" -o /dev/null 2>/dev/null; then
  echo "sqrt_open_bound_contract_tier: expected build fail without --allow-open-vc"
  exit 1
fi

"$LIC" build --allow-open-vc "$SAMPLE" -o /dev/null
test -f "$AUTOVC"

if ! grep -qE 'def vc_sqrt_open_ensures_0.*Float\.abs' "$AUTOVC"; then
  echo "sqrt_open_bound_contract_tier: expected Float.abs ensures Prop in AutoVC"
  exit 1
fi
if grep -qE 'def vc_sqrt_open_ensures_0.*: Prop := True' "$AUTOVC"; then
  echo "sqrt_open_bound_contract_tier: ensures must not lower to True stub"
  exit 1
fi
if grep -q 'theorem vc_sqrt_open_ensures_0_proved' "$AUTOVC"; then
  echo "sqrt_open_bound_contract_tier: gap closed — update script"
  exit 1
fi
if "$CHECK_GOALS" "$AUTOVC"; then
  echo "sqrt_open_bound_contract_tier: expected open AutoVC goal for ensures_0"
  exit 1
fi

echo "sqrt_open_bound_contract_tier: ok (documented G-vc/G-lean P-float open)"
