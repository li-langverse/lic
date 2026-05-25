#!/usr/bin/env bash
# Phase 2f: corpus with closed vs open AutoVC goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
chmod +x "$ROOT/li-tests/tooling/discharge_trivial_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_const_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_caller_requires_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_caller_requires_local_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_sqrt_open_lean.sh"
"$ROOT/li-tests/tooling/discharge_trivial_lean.sh"
"$ROOT/li-tests/tooling/discharge_const_lean.sh"
"$ROOT/li-tests/tooling/discharge_caller_requires_lean.sh"
"$ROOT/li-tests/tooling/discharge_caller_requires_local_lean.sh"
"$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh"
"$ROOT/li-tests/tooling/discharge_sqrt_open_lean.sh"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
"$LIC" build "$ROOT/li-tests/contracts_verify/index_refinement.li" -o /dev/null
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"
"$ROOT/li-tests/tooling/discharge_sqrt_open_lean.sh"
echo "contracts_discharge_corpus: ok"
