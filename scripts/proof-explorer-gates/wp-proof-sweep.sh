#!/usr/bin/env bash
# WP-SWEEP — one human/agent pass per catalog id in proof-sweep-log.jsonl.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

LOG="data/proof-explorer-loop/proof-sweep-log.jsonl"
MIN_CATALOG="${PROOF_SWEEP_MIN_CATALOG:-1290}"

if [[ ! -f "$LOG" ]]; then
  echo "wp-proof-sweep: missing $LOG (run scripts/formalization/proof-catalog-sweep.py --full)" >&2
  exit 1
fi

python3 - <<PY
import json
import sys
from pathlib import Path

log = Path("data/proof-explorer-loop/proof-sweep-log.jsonl")
min_catalog = int("${MIN_CATALOG}")

by_id: dict[str, dict] = {}
for line in log.read_text(encoding="utf-8").splitlines():
    line = line.strip()
    if not line:
        continue
    row = json.loads(line)
    if row.get("source") != "catalog":
        continue
    eid = str(row.get("id", "")).strip()
    if eid:
        by_id[eid] = row

if len(by_id) < min_catalog:
    raise SystemExit(
        f"wp-proof-sweep: only {len(by_id)} catalog ids in log (want >={min_catalog})"
    )

status_counts: dict[str, int] = {}
for row in by_id.values():
    st = str(row.get("sweep_status", "unknown"))
    status_counts[st] = status_counts.get(st, 0) + 1

print(
    f"wp-proof-sweep: OK ({len(by_id)} catalog ids; "
    + ", ".join(f"{k}={v}" for k, v in sorted(status_counts.items()))
    + ")"
)
PY
