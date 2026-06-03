#!/usr/bin/env bash
# Phase 10 — axiom layer (formulations, catalog, library UI, compiler RFC).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
bash scripts/proof-explorer-gates/wp0-schema.sh || fail=1

for gate in \
  wp-ax-01-math-peano-contracts \
  wp-ax-02-math-reals-field \
  wp-ax-03-basic-corpus-axioms \
  wp-ax-04-erdos-open-enrich \
  wp-ax-05-catalog-axiom-fields \
  wp-ax-07-compiler-rfc-present \
  wp-ax-08-stub-audit-catalog \
  wp-ax-09-rebuild-library-json \
  wp-ax-10-loop-state; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase10: missing $script" >&2
    fail=1
  fi
done

# WP-AX-06: proof-library UI (optional sign-off until PR lands)
if [[ -f scripts/proof-explorer-gates/wp-ax-06-proof-library-axiom-ui.sh ]]; then
  bash scripts/proof-explorer-gates/wp-ax-06-proof-library-axiom-ui.sh || fail=1
fi

test -f docs/superpowers/plans/proof-explorer-phase10-axiom-layer.md || fail=1
test -f data/goal-directed-sprints/proof-explorer-phase10-axiom-layer.md || fail=1
test -f docs/reports/compiler-audit/BUG-C-13-li-axiom-declarations.md || fail=1
test -f data/proof-explorer-loop/wp-ax-axiom-layer.signoff || fail=1

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase10-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase10-completion-gate: OK"
exit 0
