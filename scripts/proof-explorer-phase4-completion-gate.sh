#!/usr/bin/env bash
# Phase 4 — Li coverage invariant (every row: li_specimen or explicit open gap).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
for gate in wp-li-coverage; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase4: missing $script" >&2
    fail=1
  fi
done

if [[ ! -f data/proof-explorer-loop/wp-li-coverage.signoff ]]; then
  echo "phase4: wp-li-coverage signoff missing" >&2
  fail=1
fi

# Tranche T3: literature-proved Erdős rows must have specimen stubs (ramp).
t3_pct="$(python3 -c "
import json
from pathlib import Path
report = Path('data/proof-explorer-loop/li-coverage-report.json')
s = json.loads(report.read_text(encoding='utf-8'))['summary']
print(int(s['T3_pct']))
")"
if [[ "$t3_pct" -lt 100 ]]; then
  echo "phase4: T3 (literature-proved Erdős) at ${t3_pct}% — continue formalization tranche (need 100%)" >&2
  fail=1
else
  echo "phase4: T3 coverage OK (${t3_pct}%)"
fi

# Full corpus: every catalog row covered.
overall="$(python3 -c "import json; from pathlib import Path; s=json.loads(Path('data/proof-explorer-loop/li-coverage-report.json').read_text())['summary']; print(int(s['pct_overall']))")"
if [[ "$overall" -lt 100 ]]; then
  echo "phase4: overall Li coverage ${overall}% (need 100%)" >&2
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase4-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase4-completion-gate: OK"
exit 0
