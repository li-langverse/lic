#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
n="$(python3 -c "import json; print(len(json.load(open('proof-db/erdos/register.json'))['problems']))")"
if [[ "$n" -lt 75 ]]; then
  echo "wp1-ingest: only $n problems (want >=75 curated, target 1200)" >&2
  exit 1
fi
echo "wp1-ingest: advisory OK ($n register rows; full ingest pending)"
