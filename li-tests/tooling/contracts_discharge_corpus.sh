#!/usr/bin/env bash
# Phase 2f: corpus with closed vs open AutoVC goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
chmod +x "$ROOT/li-tests/tooling/discharge_trivial_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_const_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_http_forward_lean.sh" \
  "$ROOT/li-tests/tooling/sqrt_open_bound_contract_tier.sh" \
  "$ROOT/li-tests/tooling/sqrt_open_bound_verify_cli_order.sh"
"$ROOT/li-tests/tooling/discharge_trivial_lean.sh"
"$ROOT/li-tests/tooling/discharge_const_lean.sh"
"$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh"
"$ROOT/li-tests/tooling/discharge_http_forward_lean.sh"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
"$LIC" build "$ROOT/li-tests/contracts_verify/index_refinement.li" -o /dev/null
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"
rm -f "$ROOT/build/generated/AutoVC.lean"
"$LIC" build --allow-open-vc "$ROOT/li-tests/contracts_verify/sqrt_open_bound.li" -o /dev/null
if "$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"; then
  echo "contracts_discharge_corpus: unexpected — sqrt_open_bound abs VC should stay open"
  exit 1
fi
"$ROOT/li-tests/tooling/sqrt_open_bound_contract_tier.sh"
"$ROOT/li-tests/tooling/sqrt_open_bound_verify_cli_order.sh"
echo "contracts_discharge_corpus: ok"
