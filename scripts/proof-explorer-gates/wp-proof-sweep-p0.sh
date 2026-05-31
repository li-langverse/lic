#!/usr/bin/env bash
# Optional phase6 slice — ≥1 sweep log row per catalog P0 Erdős id.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

LOG="data/proof-explorer-loop/proof-sweep-log.jsonl"
if [[ ! -f "$LOG" ]]; then
  echo "wp-proof-sweep-p0: missing $LOG" >&2
  exit 1
fi

python3 - <<'PY'
import json
import tomllib
from pathlib import Path

ROOT = Path(".")
LOG = ROOT / "data/proof-explorer-loop/proof-sweep-log.jsonl"
ENTRIES = ROOT / "docs/verification/proof-database/entries"

p0_ids: set[str] = set()
for path in sorted(ENTRIES.glob("*.toml")):
    if path.name == "schema.toml":
        continue
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    batch = data.get("entry") or []
    if isinstance(batch, dict):
        batch = [batch]
    for entry in batch:
        if not isinstance(entry, dict):
            continue
        eid = str(entry.get("id", ""))
        if eid.startswith("E-") and entry.get("priority_tier") == "P0":
            p0_ids.add(eid)

swept: set[str] = set()
for line in LOG.read_text(encoding="utf-8").splitlines():
    line = line.strip()
    if not line:
        continue
    row = json.loads(line)
    if row.get("source") != "catalog":
        continue
    eid = str(row.get("id", ""))
    if eid in p0_ids:
        swept.add(eid)

missing = sorted(p0_ids - swept)
if missing:
    raise SystemExit(
        f"wp-proof-sweep-p0: {len(missing)} P0 ids not in sweep log "
        f"(e.g. {missing[:5]})"
    )
print(f"wp-proof-sweep-p0: OK ({len(p0_ids)} P0 Erdős catalog ids swept)")
PY
