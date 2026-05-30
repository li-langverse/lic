#!/usr/bin/env bash
# Phase 2f: corpus with closed vs open AutoVC goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
chmod +x "$ROOT/li-tests/tooling/discharge_trivial_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_const_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh" \
  "$ROOT/li-tests/tooling/discharge_http_forward_lean.sh" \
  "$ROOT/li-tests/tooling/bounds_guard_codegen_gap.sh" \
  "$ROOT/li-tests/tooling/dot4_loop_ensures_lean_stub_gap.sh" \
  "$ROOT/li-tests/tooling/parallel_disjoint_lean_opaque_gap.sh" \
  "$ROOT/li-tests/tooling/broadcast_len1_codegen_lean_gap.sh" \
  "$ROOT/li-tests/tooling/prelude_linalg_manifest_tier_gap.sh" \
  "$ROOT/li-tests/tooling/horner_fma_numerically_stable_gap.sh" \
  "$ROOT/li-tests/tooling/sum_dot_product_equiv_gap.sh" \
  "$ROOT/li-tests/tooling/matmul_loop_codegen_witness_gap.sh" \
  "$ROOT/li-tests/tooling/mat2_at2_mir_codegen_lean_gap.sh" \
  "$ROOT/li-tests/tooling/method_call_requires_lean_gap.sh" \
  "$ROOT/li-tests/tooling/vec3_dot_opaque_ensures_gap.sh"
"$ROOT/li-tests/tooling/discharge_trivial_lean.sh"
"$ROOT/li-tests/tooling/discharge_const_lean.sh"
"$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh"
"$ROOT/li-tests/tooling/discharge_http_forward_lean.sh"
"$ROOT/li-tests/tooling/bounds_guard_codegen_gap.sh"
"$ROOT/li-tests/tooling/dot4_loop_ensures_lean_stub_gap.sh"
"$ROOT/li-tests/tooling/parallel_disjoint_lean_opaque_gap.sh"
"$ROOT/li-tests/tooling/broadcast_len1_codegen_lean_gap.sh"
"$ROOT/li-tests/tooling/prelude_linalg_manifest_tier_gap.sh"
"$ROOT/li-tests/tooling/horner_fma_numerically_stable_gap.sh"
"$ROOT/li-tests/tooling/sum_dot_product_equiv_gap.sh"
"$ROOT/li-tests/tooling/matmul_loop_codegen_witness_gap.sh"
"$ROOT/li-tests/tooling/method_call_requires_lean_gap.sh"
"$ROOT/li-tests/tooling/vec3_dot_opaque_ensures_gap.sh"
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
echo "contracts_discharge_corpus: ok"
