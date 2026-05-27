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
  "$ROOT/scripts/check-mir-parallel-decorator.sh" \
  "$ROOT/scripts/check-mir-vectorized-decorator.sh" \
  "$ROOT/li-tests/tooling/check_release_bounds_ir.sh"
  "$ROOT/li-tests/tooling/discharge_http_forward_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_par_policy_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_par_parallel_lean.sh" \
  "$ROOT/scripts/check-mir-parallel-for-disjoint.sh"
"$ROOT/li-tests/tooling/discharge_trivial_lean.sh"
"$ROOT/li-tests/tooling/discharge_const_lean.sh"
"$ROOT/li-tests/tooling/discharge_caller_requires_lean.sh"
"$ROOT/li-tests/tooling/discharge_caller_requires_local_lean.sh"
"$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh"
"$ROOT/li-tests/tooling/discharge_refinement_lean.sh"
"$ROOT/li-tests/tooling/check_release_bounds_ir.sh"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
"$ROOT/li-tests/tooling/discharge_http_forward_lean.sh"
"$ROOT/li-tests/tooling/discharge_par_policy_lean.sh"
"$ROOT/li-tests/tooling/discharge_par_parallel_lean.sh"
"$ROOT/scripts/check-mir-parallel-for-disjoint.sh"
"$LIC" build "$ROOT/li-tests/contracts_verify/index_refinement.li" -o /dev/null
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"
rm -f "$ROOT/build/generated/AutoVC.lean"
# Open-goal probe: optional when static discharge lands (feat/bench-analytical-oracle).
"$LIC" build --allow-open-vc "$ROOT/li-tests/contracts_verify/sqrt_open_bound.li" -o /dev/null
if "$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"; then
  echo "contracts_discharge_corpus: note — sqrt_open_bound discharged (no open Prop probe)"
else
  echo "contracts_discharge_corpus: open VC probe ok"
fi
"$LIC" build "$ROOT/li-tests/contracts_verify/sqrt_open_bound.li" -o /dev/null
test -f "$ROOT/build/generated/AutoVC.lean"
grep -q 'Li\.Discharge\.sqrt_open_bound_spec' "$ROOT/build/generated/AutoVC.lean" || {
  echo "contracts_discharge_corpus: missing sqrt_open_bound Discharge witness"
  exit 1
}
"$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"
echo "contracts_discharge_corpus: ok"
