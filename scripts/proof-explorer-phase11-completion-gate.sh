#!/usr/bin/env bash
# Phase 11 — proof-library site polish (rebuild, lean scan, snippets, Pages).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
bash scripts/proof-explorer-gates/wp0-schema.sh || fail=1

for gate in \
  wp-pl-01-rebuild-json \
  wp-pl-02-lean-scan \
  wp-pl-03-snippet-strip \
  wp-pl-04-stdlib-drilldown \
  wp-pl-05-erdos-formal \
  wp-pl-06-pages-deploy; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase11: missing $script" >&2
    fail=1
  fi
done

test -f docs/superpowers/plans/proof-explorer-phase11-proof-library-polish.md || fail=1
test -f data/goal-directed-sprints/proof-explorer-phase11-proof-library-polish.md || fail=1

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase11-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase11-completion-gate: OK"
exit 0
