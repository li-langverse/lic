#!/usr/bin/env bash
# WP-AX-04: Erdős open P0/P1 — context or li_specimen enrichment (bootstrap: ≥5 rows).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
MIN="${MIN_ERDOS_ENRICHED:-5}"

python3 - "$MIN" <<'PY'
import re
import sys
from pathlib import Path

root = Path(".")
min_n = int(sys.argv[1])
path = root / "docs/verification/proof-database/entries/erdos-register.toml"
if not path.is_file():
    print("wp-ax-04: erdos-register.toml missing", file=sys.stderr)
    sys.exit(1)
text = path.read_text(encoding="utf-8")
enriched = 0
for block in re.split(r"\[\[entry\]\]", text)[1:]:
    if 'erdos_status = "open"' not in block and "erdos_status = 'open'" not in block:
        continue
    if "priority_tier = \"P0\"" not in block and "priority_tier = \"P1\"" not in block:
        continue
    has_ctx = "context =" in block or "li_specimen =" in block
    if has_ctx and "stub only" not in block.lower():
        enriched += 1
if enriched < min_n:
    print(f"wp-ax-04: only {enriched} enriched P0/P1 open rows (want >= {min_n})", file=sys.stderr)
    sys.exit(1)
print(f"wp-ax-04-erdos-open-enrich: OK ({enriched} rows)")
PY
