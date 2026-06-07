#!/usr/bin/env bash
# Phase 8 — foundational basic corpus (physics, stats, discrete, graph, physical chemistry).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
bash scripts/proof-explorer-gates/wp0-schema.sh || fail=1

MIN_TOTAL="${MIN_BASIC_CORPUS_TOTAL:-200}"
count="$(python3 -c "
import re
from pathlib import Path
note = 'phase8-basic-corpus'
n = 0
for path in Path('docs/verification/proof-database/entries').glob('*.toml'):
    text = path.read_text(encoding='utf-8')
    if note not in text:
        continue
    for block in re.split(r'\[\[entry\]\]', text)[1:]:
        if note in block and 'li_specimen' in block:
            n += 1
print(n)
")"
if [[ "$count" -lt "$MIN_TOTAL" ]]; then
  echo "phase8: only $count basic-corpus entries (want >= $MIN_TOTAL)" >&2
  fail=1
else
  echo "phase8: basic corpus OK ($count entries)"
fi

test -f docs/superpowers/plans/proof-explorer-phase8-basic-corpus.md || fail=1
test -f data/goal-directed-sprints/proof-explorer-phase8-basic-corpus.md || fail=1
test -f scripts/formalization/bootstrap-basic-corpus.py || fail=1
test -d docs/verification/basic-corpus || fail=1

# Per-field gates (default 40 each; override MIN_* for tranche runs)
MIN_PHYSICS="${MIN_PHYSICS:-40}" bash scripts/proof-explorer-gates/wp-basic-corpus-physics.sh || fail=1
MIN_STATS="${MIN_STATS:-40}" bash scripts/proof-explorer-gates/wp-basic-corpus-stats.sh || fail=1
MIN_DISCRETE="${MIN_DISCRETE:-40}" bash scripts/proof-explorer-gates/wp-basic-corpus-discrete.sh || fail=1
MIN_GRAPH="${MIN_GRAPH:-40}" bash scripts/proof-explorer-gates/wp-basic-corpus-graph.sh || fail=1
MIN_CHEM="${MIN_CHEM:-40}" bash scripts/proof-explorer-gates/wp-basic-corpus-chem.sh || fail=1

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase8-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase8-completion-gate: OK"
exit 0
