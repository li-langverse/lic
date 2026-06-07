#!/usr/bin/env bash
# Phase 13 â€” ten-of-ten closure across site, explorer, gaps, axiom, ErdÅ‘s, CI.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
bash scripts/proof-explorer-gates/wp0-schema.sh || fail=1

for gate in \
  wp-t10-01-site-sync \
  wp-t10-02-stale-prs-closed \
  wp-t10-03-proof-library-main \
  wp-t10-04-compiler-gaps \
  wp-t10-05-stub-audit-catalog \
  wp-t10-06-discrepancy-triage \
  wp-t10-07-axiom-layer \
  wp-t10-08-erdos-honesty \
  wp-t10-09-main-ci \
  wp-t10-10-phase13-signoff; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase13: missing $script" >&2
    fail=1
  fi
done

test -f docs/superpowers/plans/proof-explorer-phase13-ten-of-ten.md || fail=1
test -f data/goal-directed-sprints/proof-explorer-phase13-ten-of-ten.md || fail=1
test -f data/proof-explorer-loop/wp-t10-ten-of-ten.signoff || fail=1

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase13-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase13-completion-gate: OK"
exit 0
