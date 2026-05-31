#!/usr/bin/env bash
# Phase 3 — research audit program completion gate.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
for gate in wp-ra-problem wp-claim-ledger wp-multi-review wp-li-verify-claims wp-claim-compare; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase3: missing $script" >&2
    fail=1
  fi
done

if [[ ! -f data/proof-explorer-loop/wp-au-claim-audit.signoff ]]; then
  echo "phase3: wp-au signoff missing" >&2
  fail=1
fi

# Minimum claim volume
n="$(python3 -c "
import json
from pathlib import Path
root = Path('proof-db/research-claims')
total = 0
for p in root.iterdir() if root.is_dir() else []:
    f = p / 'claims.jsonl'
    if f.is_file():
        total += sum(1 for line in f.read_text().splitlines() if line.strip())
print(total)
")"
if [[ "$n" -lt 10 ]]; then
  echo "phase3: only $n claims (want >=10)" >&2
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase3-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase3-completion-gate: OK"
exit 0
