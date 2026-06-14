#!/usr/bin/env bash
# Phase 7 — research audit at scale + proof-library export integration.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
for gate in wp-research-scale wp-li-verify-claims wp-claim-compare wp-export-li-specimen wp-proof-library-export wp3-export-math wp-ra-problem; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase7: missing $script" >&2
    fail=1
  fi
done

if [[ ! -f data/proof-explorer-loop/wp-research-scale.signoff ]]; then
  echo "phase7: wp-research-scale signoff missing" >&2
  fail=1
fi

# Total claim volume across problems
total="$(python3 -c "
from pathlib import Path
root = Path('proof-db/research-claims')
total = 0
for p in root.iterdir() if root.is_dir() else []:
    f = p / 'claims.jsonl'
    if f.is_file():
        total += sum(1 for line in f.read_text().splitlines() if line.strip())
print(total)
")"
if [[ "$total" -lt 30 ]]; then
  echo "phase7: only $total total claims (want >=30)" >&2
  fail=1
else
  echo "phase7: claim volume OK ($total total)"
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase7-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase7-completion-gate: OK"
exit 0
