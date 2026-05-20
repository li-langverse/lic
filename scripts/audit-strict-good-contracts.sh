#!/usr/bin/env bash
# Representative programs that must pass `lic build … --strict-contracts`
# (non-vacuous `ensures`). Run after changing vacuous-ensures heuristics.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIC="${LIC:-"$("$ROOT/scripts/resolve-lic.sh")"}"
NULL_OUT="/dev/null"
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) NULL_OUT="NUL" ;; esac

good=(
  "$ROOT/li-tests/typecheck/provable_add_ok.li"
  "$ROOT/li-tests/typecheck/fib.li"
  "$ROOT/li-tests/contracts_verify/discharge_const.li"
  "$ROOT/li-tests/contracts_verify/sqrt_contract.li"
  "$ROOT/li-tests/contracts_verify/index_refinement.li"
)

for f in "${good[@]}"; do
  echo "audit-strict-good-contracts: $f"
  "$LIC" build "$f" -o "$NULL_OUT" --strict-contracts
done
echo "audit-strict-good-contracts: ok"
