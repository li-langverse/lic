#!/usr/bin/env bash
# WP-DS-05 — ≥3 core corpus lic verify discharges logged.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

log="data/proof-explorer-loop/discharge-log.jsonl"
if [[ ! -f "$log" ]]; then
  echo "wp-discharge-core: missing $log" >&2
  exit 1
fi

python3 - <<'PY'
import json
from pathlib import Path

log = Path("data/proof-explorer-loop/discharge-log.jsonl")
rows = []
for line in log.read_text(encoding="utf-8").splitlines():
    line = line.strip()
    if not line:
        continue
    rows.append(json.loads(line))

verified = [
    r for r in rows
    if r.get("proof_status_after") == "proved"
    or r.get("evidence")
    or r.get("verified_at")
]
core_prefixes = ("li-tests/contracts_verify/", "li-tests/math_linalg/", "proof-db/math/specimens/M-LM-")
core = [r for r in verified if any(str(r.get("li_specimen", "")).startswith(p) for p in core_prefixes)]

if len(core) < 3:
    raise SystemExit(f"wp-discharge-core: only {len(core)} core discharges (want >=3)")
print(f"wp-discharge-core: OK ({len(core)} core discharges logged)")
PY
