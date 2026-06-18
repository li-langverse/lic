#!/usr/bin/env bash
# Issue #34 — parallel lowering map doc corpus gate (sub-phases A–E).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

li_phase "parallel lowering map gate (#34)"

required=(
  docs/superpowers/plans/2026-06-07-std-execution-openmp-mlir-lowering-map.md
  docs/language/parallel-lowering-map.md
  docs/superpowers/specs/2026-06-08-mlir-omp-offload-adr.md
)

missing=()
for f in "${required[@]}"; do
  [[ -f "$ROOT/$f" ]] || missing+=("$f")
done
if ((${#missing[@]} > 0)); then
  li_fail "parallel lowering map corpus incomplete: ${missing[*]}"
fi

# Handbook map must reference OpenMPIRBuilder and MLIR omp (binding upstream anchor).
grep -q 'OpenMPIRBuilder' "$ROOT/docs/language/parallel-lowering-map.md" \
  || li_fail "parallel-lowering-map.md missing OpenMPIRBuilder section"
grep -q 'omp\.parallel' "$ROOT/docs/language/parallel-lowering-map.md" \
  || li_fail "parallel-lowering-map.md missing MLIR omp mapping"
grep -q 'parallel_disjoint_proven' "$ROOT/docs/language/parallel-lowering-map.md" \
  || li_fail "parallel-lowering-map.md missing G-par witness section"

# Phase 07 cross-link
grep -q '2026-06-07-std-execution-openmp-mlir-lowering-map' \
  "$ROOT/docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md" \
  || li_fail "phase-07-native-hpc.md missing lowering map cross-link"

li_ok "check-parallel-lowering-map-gate.sh: PASS (#34 doc corpus)"
