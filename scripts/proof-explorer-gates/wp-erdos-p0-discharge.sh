#!/usr/bin/env bash
# WP-EF-01/02/03 — ≥5 P0 Erdős with li_proved or honest partial discharge.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import json
from pathlib import Path

log = Path("data/proof-explorer-loop/discharge-log.jsonl")
rows = []
if log.is_file():
    for line in log.read_text(encoding="utf-8").splitlines():
        if line.strip():
            rows.append(json.loads(line))

register = json.loads(Path("proof-db/erdos/register.json").read_text(encoding="utf-8"))
p0_ids = {p["id"] for p in register.get("problems", []) if p.get("priority_tier") == "P0"}

# Count from discharge log
logged_p0 = {r["entry_id"] for r in rows if r.get("entry_id", "").startswith("E-") and r["entry_id"] in p0_ids}

# Also count catalog rows with proved + specimen evidence
proved_p0 = set()
for p in register.get("problems", []):
    pid = p.get("id", "")
    if pid not in p0_ids:
        continue
    if p.get("proof_status") == "proved" and (p.get("lean_thm") or p.get("li_specimen")):
        proved_p0.add(pid)
    partial = p.get("partial_proofs") or []
    if partial:
        proved_p0.add(pid)

combined = logged_p0 | proved_p0
if len(combined) < 5:
    raise SystemExit(f"wp-erdos-p0-discharge: only {len(combined)} P0 rows discharged/partial (want >=5)")
print(f"wp-erdos-p0-discharge: OK ({len(combined)} P0 Erdős with discharge or partial)")
PY
