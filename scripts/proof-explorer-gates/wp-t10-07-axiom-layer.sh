#!/usr/bin/env bash
# WP-T10-07: axiom layer â€” phase10 ax gates (M-AX def+implies posture).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

for gate in \
  wp-ax-01-math-peano-contracts \
  wp-ax-02-math-reals-field \
  wp-ax-03-basic-corpus-axioms \
  wp-ax-04-erdos-open-enrich \
  wp-ax-05-catalog-axiom-fields \
  wp-ax-07-compiler-rfc-present \
  wp-ax-08-stub-audit-catalog; do
  bash "scripts/proof-explorer-gates/${gate}.sh"
done

test -f docs/reports/compiler-audit/BUG-C-13-li-axiom-declarations.md
test -f data/proof-explorer-loop/wp-ax-axiom-layer.signoff
echo "wp-t10-07-axiom-layer: OK"
