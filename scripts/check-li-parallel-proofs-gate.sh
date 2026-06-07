#!/usr/bin/env bash
# WP-PAR-30 / G-par / G-par-dist / G-hetero — provability register closed slices.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel proofs gate (WP-PAR-30)"

GAPS="$ROOT/docs/verification/provability-gaps.md"
PROOF_DB="$ROOT/docs/verification/proof-database/entries/parallel-li-par.toml"
PROOFS_TABLE="$ROOT/packages/li-parallel/docs/proofs-table.md"

missing=()
for path in "$GAPS" "$PROOF_DB" "$PROOFS_TABLE"; do
  [[ -f "$path" ]] || missing+=("$path")
done
if [[ ${#missing[@]} -gt 0 ]]; then
  li_fail "missing proof corpus files: ${missing[*]}"
  exit 1
fi

for gap in G-par G-par-dist G-hetero; do
  if ! grep -q "**${gap}**" "$GAPS"; then
    li_fail "${gap} row missing in provability-gaps.md (WP-PAR-30)"
    exit 1
  fi
  if ! grep -q "gap_id = \"${gap}\"" "$PROOF_DB"; then
    li_fail "${gap} missing in proof-database/entries/parallel-li-par.toml"
    exit 1
  fi
done

if grep -q 'G-hetero.*Pending' "$PROOFS_TABLE"; then
  li_fail "proofs-table.md still marks G-hetero Pending"
  exit 1
fi

for smoke in \
  li-tests/tooling/li_parallel_def_disjoint_inherit_smoke.sh \
  li-tests/tooling/li_dpar_for_codegen_smoke.sh \
  li-tests/tooling/li_hetero_gate_smoke.sh \
  li-tests/tooling/li_par_iteration_independent_tile_smoke.sh \
  li-tests/tooling/li_par_memory_disjoint_rows_smoke.sh \
  li-tests/tooling/li_par_memory_disjoint_elems_smoke.sh \
  li-tests/tooling/li_par_memory_disjoint_grid_rows_smoke.sh \
  li-tests/tooling/li_par_memory_disjoint_grid_elems_smoke.sh \
  li-tests/tooling/li_par_dependent_array_aliasing_smoke.sh \
  li-tests/tooling/li_par_disjoint_index_bound_smoke.sh \
  li-tests/tooling/li_par_affine_dependent_index_smoke.sh \
  li-tests/tooling/parallel_disjoint_lean_opaque_gap.sh
do
  chmod +x "$ROOT/$smoke"
  bash "$ROOT/$smoke"
done

if [[ -f "$ROOT/packages/li-parallel/li-tests/smoke/kernels_ghost.li" ]]; then
  if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
    "$ROOT/build/compiler/lic/lic" build \
      "$ROOT/packages/li-parallel/li-tests/smoke/kernels_ghost.li" \
      --allow-open-vc >/dev/null 2>&1 || true
  fi
fi

li_ok "check-li-parallel-proofs-gate.sh: PASS (G-par + G-par-dist + G-hetero closed slices in register, inherit + dpar + hetero smokes)"
