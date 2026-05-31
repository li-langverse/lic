#!/usr/bin/env bash
# Phase 2 — proof-library UI, editorial overlays, Tier-B Erdos polish.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
bash scripts/proof-explorer-gates/wp1-ingest.sh || fail=1
bash scripts/proof-explorer-gates/wp3-export-math.sh || fail=1

# WP6: editorial overlays file with at least 5 hand-curated rows
if [[ ! -f proof-db/erdos/overlays.json ]]; then
  echo "phase2: missing proof-db/erdos/overlays.json" >&2
  fail=1
else
  n="$(python3 -c "import json; print(len(json.load(open('proof-db/erdos/overlays.json')).get('overlays',[])))")"
  if [[ "$n" -lt 5 ]]; then
    echo "phase2: overlays.json has $n rows (want >=5)" >&2
    fail=1
  else
    echo "phase2: overlays.json OK ($n rows)"
  fi
fi

# Tier B: P0/P1 Erdos rows with content_tier=polished or curated context
polished="$(python3 -c "
import json
r=json.load(open('proof-db/erdos/register.json'))
rows=[p for p in r.get('problems',[]) if p.get('content_tier') in ('polished','curated') and (p.get('context') or p.get('sources'))]
print(len(rows))
")"
if [[ "$polished" -lt 20 ]]; then
  echo "phase2: only $polished Erdos rows with context/sources (want >=20 Tier-B)" >&2
  fail=1
else
  echo "phase2: Tier-B polish OK ($polished rows)"
fi

# WP5: sign-off file (agent creates when proof-library PR is open)
if [[ ! -f data/proof-explorer-loop/wp5-proof-library.signoff ]]; then
  echo "phase2: wp5 sign-off missing (create data/proof-explorer-loop/wp5-proof-library.signoff with PR URL)" >&2
  fail=1
else
  echo "phase2: wp5 sign-off present"
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase2-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase2-completion-gate: OK"
exit 0