#!/usr/bin/env bash
# WP-PAR-79 / WP-PAR-86 — chip ownership: li-gpu / li-tpu / li-asic only; no drivers in li-ml or li-parallel.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "chip package boundaries (WP-PAR-79, WP-PAR-86)"

violations=0
report() {
  li_fail "$1"
  violations=$((violations + 1))
}

if [[ -d "$ROOT/packages/lig" ]]; then
  report "packages/lig still exists — rename to packages/li-gpu (import ligpu) per WP-PAR-79"
fi
if [[ ! -d "$ROOT/packages/li-gpu" ]]; then
  report "packages/li-gpu missing — WP-PAR-79 rename incomplete"
fi
for pkg in li-tpu li-asic; do
  if [[ ! -d "$ROOT/packages/$pkg" ]]; then
    report "packages/$pkg missing — WP-PAR-83/84"
  fi
done

if grep -R --include='*.li' -E '\bimport\s+lig\b' "$ROOT/packages" 2>/dev/null | grep -v '/li-gpu/'; then
  report "import lig found outside li-gpu — use import ligpu"
fi

if [[ -d "$ROOT/packages/li-ml" ]]; then
  if grep -R --include='*.li' -E 'litpu_|liasic_|\bcuda[A-Z_]|#include <cuda|\bhip[A-Z_]|#include <hip|\bopencl|\bvulkan' \
    "$ROOT/packages/li-ml" 2>/dev/null | grep -v 'lig_backend_'; then
    report "li-ml contains TPU/ASIC/GPU driver symbols — move to li-tpu / li-asic / li-gpu"
  fi
fi

if grep -R --include='*.li' -E 'extern proc.*(litpu_|liasic_)|#include <(cuda|hip)|\bcudaMemcpy|\bhipLaunch|\bopencl|\bvulkan' \
  "$ROOT/packages/li-parallel" 2>/dev/null; then
  report "li-parallel calls vendor SDKs directly — orchestrate via chip packages only"
fi

if [[ "$violations" -gt 0 ]]; then
  li_fail "check-chip-package-boundaries.sh: $violations violation(s)"
  exit 1
fi

li_ok "check-chip-package-boundaries.sh: PASS"
