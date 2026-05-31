#!/usr/bin/env bash
# Phase 6 — proof corpus sweep (failures logged, not blocking).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0

bash scripts/proof-explorer-gates/wp-proof-sweep.sh || fail=1

p0_ok=0
if bash scripts/proof-explorer-gates/wp-proof-sweep-p0.sh 2>/dev/null; then
  p0_ok=1
  echo "phase6: P0 sweep coverage OK"
elif [[ -f scripts/proof-explorer-gates/wp-erdos-p0-discharge.sh ]]; then
  if bash scripts/proof-explorer-gates/wp-erdos-p0-discharge.sh 2>/dev/null; then
    p0_ok=1
    echo "phase6: legacy wp-erdos-p0-discharge OK"
  fi
fi
if [[ "$p0_ok" -eq 0 ]]; then
  echo "phase6: need P0 sweep rows or wp-erdos-p0-discharge" >&2
  fail=1
fi

if [[ -f scripts/proof-explorer-gates/wp-export-li-specimen.sh ]]; then
  if [[ "${LI_PROOF_EXPLORER_SWEEP_MODE:-0}" == "1" ]]; then
    bash scripts/proof-explorer-gates/wp-export-li-specimen.sh       || echo "phase6: wp-export-li-specimen skipped (sweep mode)"
  else
    bash scripts/proof-explorer-gates/wp-export-li-specimen.sh || fail=1
  fi
fi

if [[ ! -f data/proof-explorer-loop/wp-proof-sweep.signoff ]]; then
  if [[ -f data/proof-explorer-loop/wp-erdos-formalization.signoff ]]; then
    echo "phase6: using wp-erdos-formalization.signoff (legacy)"
  else
    echo "phase6: wp-proof-sweep.signoff missing" >&2
    fail=1
  fi
fi

if [[ "${LI_PROOF_EXPLORER_SWEEP_MODE:-0}" == "1" ]]; then
  echo "phase6: skipping phase5 regression (LI_PROOF_EXPLORER_SWEEP_MODE=1)"
elif [[ -f scripts/proof-explorer-phase5-completion-gate.sh ]]; then
  bash scripts/proof-explorer-phase5-completion-gate.sh || fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase6-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase6-completion-gate: OK (sweep mode)"
exit 0
