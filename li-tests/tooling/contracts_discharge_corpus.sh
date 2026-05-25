#!/usr/bin/env bash
# Phase 2f: corpus with closed vs open AutoVC goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
chmod +x "$ROOT/li-tests/tooling/discharge_trivial_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_const_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_caller_requires_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_caller_requires_local_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_method_call_requires_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_method_ensures_return_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_http_forward_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_witnessed_ensures_lean.sh" \
  "$ROOT/li-tests/tooling/check_mir_parallel_decorator.sh" \
  "$ROOT/li-tests/tooling/discharge_refinement_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_identity_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_import_requires_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_sqrt_open_lean.sh" \
  "$ROOT/li-tests/tooling/check_release_bounds_ir.sh"
"$ROOT/li-tests/tooling/discharge_trivial_lean.sh"
"$ROOT/li-tests/tooling/discharge_const_lean.sh"
"$ROOT/li-tests/tooling/discharge_caller_requires_lean.sh"
"$ROOT/li-tests/tooling/discharge_caller_requires_local_lean.sh"
"$ROOT/li-tests/tooling/discharge_method_call_requires_lean.sh"
"$ROOT/li-tests/tooling/discharge_method_ensures_return_lean.sh"
"$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh"
"$ROOT/li-tests/tooling/discharge_http_forward_lean.sh"
"$ROOT/li-tests/tooling/discharge_witnessed_ensures_lean.sh"
"$ROOT/li-tests/tooling/check_mir_parallel_decorator.sh"
"$ROOT/li-tests/tooling/discharge_refinement_lean.sh"
"$ROOT/li-tests/tooling/discharge_identity_lean.sh"
"$ROOT/li-tests/tooling/discharge_import_requires_lean.sh"
"$ROOT/li-tests/tooling/discharge_sqrt_open_lean.sh"
"$ROOT/li-tests/tooling/check_release_bounds_ir.sh"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
"$LIC" build "$ROOT/li-tests/contracts_verify/index_refinement.li" -o /dev/null
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"
echo "contracts_discharge_corpus: ok"
