#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/sqrt_open_bound.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"
rm -f "$AUTOVC"
"$LIC" build --allow-open-vc "$SAMPLE" -o /dev/null
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
if "$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"; then
  echo "discharge_sqrt_open_lean: FAIL — expected open Prop goals for sqrt_open_bound control" >&2
  exit 1
fi
grep -q 'Float.abs' "$AUTOVC"
if grep -q 'vc_sqrt_open_ensures_0_proved' "$AUTOVC"; then
  echo "discharge_sqrt_open_lean: FAIL — sqrt_open_bound should stay open (no _proved)" >&2
  exit 1
fi
if command -v lake >/dev/null 2>&1; then (cd "$ROOT/docs/semantics" && lake build); fi
echo discharge_sqrt_open_lean: ok
