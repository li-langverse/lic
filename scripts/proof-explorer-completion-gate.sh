#!/usr/bin/env bash
# Proof Explorer — full program completion gate (Phase 1 deliverables).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
for gate in wp-k8-deploy wp0-schema wp1-ingest wp2-m-conj wp3-export-math wp4-audit; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "proof-explorer: missing $script" >&2
    fail=1
  fi
done

if [[ ! -f data/proof-explorer-loop/state.json ]]; then
  echo "proof-explorer: missing state.json" >&2
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-completion-gate: OK"
exit 0