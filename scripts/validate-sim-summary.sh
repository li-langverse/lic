#!/usr/bin/env bash
# Validate li_sim_summary_v1 JSON under benchmarks/results/*/*.summary.json
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
shopt -s nullglob
fail=0
found=0
for f in "$ROOT"/benchmarks/results/*/*.summary.json; do
  found=1
  if ! python3 -c "
import json, sys
p = sys.argv[1]
d = json.load(open(p))
assert d.get('schema') == 'li_sim_summary_v1', p
assert 'ok' in d and 'metrics' in d, p
" "$f"; then
    echo "invalid summary: $f" >&2
    fail=1
  else
    echo "ok: $f"
  fi
done
if [[ "$found" -eq 0 ]]; then
  echo "validate-sim-summary: no *.summary.json (run: verify.py --write-summary)" >&2
  exit 0
fi
exit "$fail"
