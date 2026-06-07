#!/usr/bin/env bash
# Smoke: killer gate script + sub-gates exist; runtime smokes pass (not full killer gate — that is ship-only).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GATE="$ROOT/scripts/check-li-parallel-killer-gate.sh"
[[ -f "$GATE" ]] || { echo "li_parallel_killer_gate_smoke: missing $GATE" >&2; exit 1; }
chmod +x "$GATE"

if [[ "${LIPAR_KILLER_SKIP_FULL:-}" == "1" ]]; then
  echo "li_parallel_killer_gate_smoke: LIPAR_KILLER_SKIP_FULL is disabled" >&2
  exit 1
fi

for sub in \
  check-li-parallel-docs-gate.sh \
  check-li-parallel-compile-smoke-gate.sh \
  audit-li-parallel-catalog-coverage.sh \
  check-li-parallel-distributed-gate.sh \
  check-li-parallel-fl-gate.sh \
  check-li-parallel-comm-gate.sh \
  check-li-parallel-hetero-gate.sh \
  check-li-parallel-xfer-gate.sh \
  check-li-parallel-proofs-gate.sh \
  check-chip-package-boundaries.sh
do
  [[ -f "$ROOT/scripts/$sub" ]] || { echo "li_parallel_killer_gate_smoke: missing scripts/$sub" >&2; exit 1; }
done

export LIC_ROOT="$ROOT"
export SKIP_BUILD=1
for smoke in \
  li-tests/tooling/li_par_pool_smoke.sh \
  li-tests/tooling/li_par_reduce_sum_smoke.sh \
  li-tests/tooling/li_dpar_for_smoke.sh
do
  chmod +x "$ROOT/$smoke"
  bash "$ROOT/$smoke"
done

echo "li_parallel_killer_gate_smoke: ok (sub-gates present; full stack enforced by GHA lipar-killer-gate)"
