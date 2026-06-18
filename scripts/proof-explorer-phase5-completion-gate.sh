#!/usr/bin/env bash
# Phase 5 — discharge sprint: compiler fixes + core lemma discharges.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
for gate in wp-discharge-dot4 wp-baseline-sync wp-float-policy wp-discharge-core wp4-audit; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase5: missing $script" >&2
    fail=1
  fi
done

# Phase 4 coverage must not regress
if [[ -f scripts/proof-explorer-gates/wp-li-coverage.sh ]]; then
  bash scripts/proof-explorer-gates/wp-li-coverage.sh || fail=1
else
  echo "phase5: wp-li-coverage gate missing — cannot verify Phase 4 invariant" >&2
  fail=1
fi

if [[ ! -f data/proof-explorer-loop/wp-discharge.signoff ]]; then
  echo "phase5: wp-discharge signoff missing" >&2
  fail=1
fi

# Minimum discharge count (re-check)
log="data/proof-explorer-loop/discharge-log.jsonl"
if [[ ! -f "$log" ]]; then
  echo "phase5: discharge-log.jsonl missing" >&2
  fail=1
else
  n="$(python3 -c "
import json
from pathlib import Path
rows = [json.loads(l) for l in Path('$log').read_text().splitlines() if l.strip()]
print(len(rows))
")"
  if [[ "$n" -lt 3 ]]; then
    echo "phase5: only $n discharge log entries (want >=3)" >&2
    fail=1
  else
    echo "phase5: discharge log OK ($n entries)"
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase5-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase5-completion-gate: OK"
exit 0
