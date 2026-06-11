#!/usr/bin/env bash
# Phase 2f: corpus with closed vs open AutoVC goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
rm -f "$ROOT/build/generated/AutoVC.lean"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
chmod +x "$ROOT/li-tests/tooling/discharge_trivial_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_const_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_caller_requires_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_caller_requires_local_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_refinement_lean.sh" \
  "$ROOT/scripts/check-mir-decorator-lowering.sh" \
  "$ROOT/li-tests/tooling/check_release_bounds_ir.sh"
"$ROOT/li-tests/tooling/discharge_trivial_lean.sh"
"$ROOT/li-tests/tooling/discharge_const_lean.sh"
"$ROOT/li-tests/tooling/discharge_caller_requires_lean.sh"
"$ROOT/li-tests/tooling/discharge_caller_requires_local_lean.sh"
"$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh"
"$ROOT/li-tests/tooling/discharge_refinement_lean.sh"
"$ROOT/scripts/check-mir-decorator-lowering.sh"
"$ROOT/li-tests/tooling/check_release_bounds_ir.sh"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
"$LIC" build "$ROOT/li-tests/contracts_verify/index_refinement.li" -o /dev/null
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"
rm -f "$ROOT/build/generated/AutoVC.lean"
"$LIC" build "$ROOT/li-tests/contracts_verify/sqrt_open_bound.li" -o /dev/null
if ! "$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"; then
  echo "contracts_discharge_corpus: FAIL — sqrt_open_bound should discharge (zero open Prop goals)" >&2
  exit 1
fi
echo "contracts_discharge_corpus: ok"
