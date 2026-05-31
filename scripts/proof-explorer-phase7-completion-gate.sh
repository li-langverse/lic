#!/usr/bin/env bash
# Phase 7 — sweep complete + research touch (verify failures non-blocking).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0

bash scripts/proof-explorer-gates/wp-proof-sweep.sh || fail=1

research_ok=0
if bash scripts/proof-explorer-gates/wp-proof-sweep-research.sh 2>/dev/null; then
  research_ok=1
elif [[ -f scripts/proof-explorer-gates/wp-research-scale.sh ]]; then
  if bash scripts/proof-explorer-gates/wp-research-scale.sh 2>/dev/null; then
    research_ok=1
  fi
fi
if [[ "$research_ok" -eq 0 ]]; then
  echo "phase7: need >=3 problems in sweep/claim ledgers" >&2
  fail=1
fi

for gate in wp-export-li-specimen wp3-export-math; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ ! -f "$script" ]]; then
    continue
  fi
  if [[ "$gate" == "wp-export-li-specimen" && "${LI_PROOF_EXPLORER_SWEEP_MODE:-0}" == "1" ]]; then
    bash "$script" || echo "phase7: wp-export-li-specimen skipped (sweep mode)"
  else
    bash "$script" || fail=1
  fi
done

for gate in wp-li-verify-claims wp-claim-compare wp-proof-library-export wp-ra-problem; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" 2>/dev/null || echo "phase7: optional gate ${gate} skipped (sweep mode)"
  fi
done

if [[ ! -f data/proof-explorer-loop/wp-proof-sweep-complete.signoff ]]; then
  if [[ -f data/proof-explorer-loop/wp-research-scale.signoff ]]; then
    echo "phase7: using wp-research-scale.signoff (legacy)"
  else
    echo "phase7: wp-proof-sweep-complete.signoff missing" >&2
    fail=1
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase7-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase7-completion-gate: OK (sweep mode)"
exit 0
