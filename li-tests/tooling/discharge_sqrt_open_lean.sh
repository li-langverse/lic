#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/sqrt_open_bound.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
rm -f "$AUTOVC"
"$LIC" build "$SAMPLE" -o /dev/null
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
if ! "$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"; then
  echo "discharge_sqrt_open_lean: FAIL — expected zero open Prop goals for sqrt_open_bound" >&2
  exit 1
fi
if ! grep -q 'vc_sqrt_open_ensures_0_proved' "$AUTOVC"; then
  echo "discharge_sqrt_open_lean: FAIL — sqrt_open_bound should discharge via _proved theorem" >&2
  exit 1
fi
if ! grep -q 'Li.Discharge.sqrt_open_bound_spec' "$AUTOVC"; then
  echo "discharge_sqrt_open_lean: FAIL — expected Li.Discharge.sqrt_open_bound_spec" >&2
  exit 1
fi
if command -v lake >/dev/null 2>&1; then (cd "$ROOT/docs/semantics" && lake build); fi
echo discharge_sqrt_open_lean: ok
