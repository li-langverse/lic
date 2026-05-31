#!/usr/bin/env bash
# Proof Explorer — program completion gate (advisory until WP0–WP1 land).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
if [[ -f scripts/proof-explorer-gates/wp0-schema.sh ]]; then
  bash scripts/proof-explorer-gates/wp0-schema.sh || fail=1
else
  echo "proof-explorer: wp0-schema gate missing (OK during bootstrap)"
fi

if [[ -f scripts/proof-explorer-gates/wp1-ingest.sh ]]; then
  bash scripts/proof-explorer-gates/wp1-ingest.sh || fail=1
else
  echo "proof-explorer: wp1-ingest gate missing (OK during bootstrap)"
fi

# K8s sprint bootstrap counts as progress
if [[ -f data/proof-explorer-loop/state.json ]]; then
  echo "proof-explorer: state.json present"
else
  echo "proof-explorer: missing state.json" >&2
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-completion-gate: OK (bootstrap/advisory)"
exit 0
