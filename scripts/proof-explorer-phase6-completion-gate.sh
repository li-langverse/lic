#!/usr/bin/env bash
# Phase 6 — Erdős P0 + M-CONJ partial formalization.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
for gate in wp-erdos-p0-discharge wp-mconj-formalization wp-export-li-specimen; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase6: missing $script" >&2
    fail=1
  fi
done

# E-52 claim ledger must exist
if [[ ! -f proof-db/research-claims/E-52/claims.jsonl ]]; then
  echo "phase6: E-52 claim ledger missing" >&2
  fail=1
else
  e52="$(wc -l < proof-db/research-claims/E-52/claims.jsonl | tr -d ' ')"
  if [[ "$e52" -lt 5 ]]; then
    echo "phase6: E-52 only $e52 claims (want >=5)" >&2
    fail=1
  else
    echo "phase6: E-52 ledger OK ($e52 claims)"
  fi
fi

if [[ ! -f data/proof-explorer-loop/wp-erdos-formalization.signoff ]]; then
  echo "phase6: wp-erdos-formalization signoff missing" >&2
  fail=1
fi

# Phase 5 must still pass (no regression)
if [[ -f scripts/proof-explorer-phase5-completion-gate.sh ]]; then
  bash scripts/proof-explorer-phase5-completion-gate.sh || fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase6-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase6-completion-gate: OK"
exit 0
