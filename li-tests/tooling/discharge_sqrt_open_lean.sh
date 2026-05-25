#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
S="$ROOT/li-tests/contracts_verify/sqrt_open_bound.li"
A="$ROOT/build/generated/AutoVC.lean"
rm -f "$A"
"$LIC" build "$S" -o /dev/null
"$ROOT/scripts/check-autovc-open-goals.sh" "$A"
grep -q Li.Discharge.sqrt_open_bound_spec "$A"
grep -q sqrt_open_bound_spec_proved "$A"
if command -v lake >/dev/null 2>&1; then (cd "$ROOT/docs/semantics" && lake build); fi
echo discharge_sqrt_open_lean: ok
