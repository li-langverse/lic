#!/usr/bin/env bash
# Smoke: killer gate script + sub-gates exist (runtime smokes run sequentially in GHA lipar-killer-gate).
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

echo "li_parallel_killer_gate_smoke: ok (sub-gates present; full stack enforced by GHA lipar-killer-gate)"
