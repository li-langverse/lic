#!/usr/bin/env bash
# Phase 12 — catalog quality across whole proof database.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
bash scripts/proof-explorer-gates/wp0-schema.sh || fail=1

for gate in \
  wp-cq-01-divergence-reconcile \
  wp-cq-02-physics-placeholders \
  wp-cq-03-sorry-honesty \
  wp-cq-04-axiom-specimen-audit \
  wp-cq-05-lemma-enrichment \
  wp-cq-06-proof-library-rebuild \
  wp-cq-07-loop-state \
  wp-cq-08-phase12-signoff; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase12: missing $script" >&2
    fail=1
  fi
done

test -f docs/superpowers/plans/proof-explorer-phase12-catalog-quality.md || fail=1
test -f data/goal-directed-sprints/proof-explorer-phase12-catalog-quality.md || fail=1
test -f data/proof-explorer-loop/wp-cq-catalog-quality.signoff || fail=1

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase12-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase12-completion-gate: OK"
exit 0
