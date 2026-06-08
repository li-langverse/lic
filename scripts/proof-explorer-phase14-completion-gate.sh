#!/usr/bin/env bash
# Phase 14 — prove all remaining open catalog entries.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
bash scripts/proof-explorer-gates/wp0-schema.sh || fail=1

for gate in \
  wp-pr-01-open-inventory \
  wp-pr-02-discharge-tranche \
  wp-pr-03-catalog-honesty \
  wp-pr-04-proof-library-sync \
  wp-pr-05-non-erdos-closed \
  wp-pr-06-all-open-closed \
  wp-pr-07-phase14-signoff; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase14: missing $script" >&2
    fail=1
  fi
done

test -f docs/superpowers/plans/proof-explorer-phase14-open-catalog-prove.md || fail=1
test -f data/goal-directed-sprints/proof-explorer-phase14-open-catalog-prove.md || fail=1
test -f data/proof-explorer-loop/phase14-baseline.json || fail=1

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase14-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase14-completion-gate: OK"
exit 0
