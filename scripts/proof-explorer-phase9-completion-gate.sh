#!/usr/bin/env bash
# Phase 9 — compiler gap closure (audit, regression, discrepancies, catalog honesty).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
bash scripts/proof-explorer-gates/wp0-schema.sh || fail=1

for gate in \
  wp-compiler-gap-audit-index \
  wp-compiler-gap-regression \
  wp-discrepancy-reconcile \
  wp-catalog-honesty; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase9: missing $script" >&2
    fail=1
  fi
done

test -f docs/superpowers/plans/proof-explorer-phase9-compiler-gaps.md || fail=1
test -f data/goal-directed-sprints/proof-explorer-phase9-compiler-gaps.md || fail=1
test -f docs/reports/compiler-audit/README.md || fail=1

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase9-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase9-completion-gate: OK"
exit 0
