#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
[[ "${PROOF_DB_SKIP:-0}" == "1" ]] && exit 0
BASELINE="${LI_PROOF_DB_BASELINE:-$ROOT/proof-db/baseline.json}"
export BASELINE
python3 - <<'PY'
import json, os, sys
from pathlib import Path
p = Path(os.environ["BASELINE"])
data = json.loads(p.read_text())
assert data.get("version") == 1
recs = data["records"]
proved = sum(1 for r in recs if r.get("status") == "proved")
assert data.get("proved_count") == proved
print(f"check-proof-db: ok ({proved} proved / {len(recs)} rows)")
PY
