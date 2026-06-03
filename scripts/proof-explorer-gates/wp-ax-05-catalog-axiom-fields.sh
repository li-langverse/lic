#!/usr/bin/env bash
# WP-AX-05: math-axioms.toml — li_axiom_symbol + specimen_role on every M-AX-* row.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import re
import sys
from pathlib import Path

path = Path("docs/verification/proof-database/entries/math-axioms.toml")
text = path.read_text(encoding="utf-8")
blocks = re.split(r"\[\[entry\]\]", text)[1:]
fail = 0
for block in blocks:
    m = re.search(r'^id\s*=\s*"([^"]+)"', block, re.M)
    if not m or not m.group(1).startswith("M-AX-"):
        continue
    eid = m.group(1)
    for field in ("li_axiom_symbol", "specimen_role", "li_specimen", "lean_thm"):
        if f"{field} =" not in block:
            print(f"wp-ax-05: {eid} missing {field}", file=sys.stderr)
            fail = 1
    if 'specimen_role = "axiom_contract"' not in block:
        print(f"wp-ax-05: {eid} specimen_role not axiom_contract", file=sys.stderr)
        fail = 1
schema = Path("docs/verification/proof-database/schema.toml").read_text(encoding="utf-8")
if "li_axiom_symbol" not in schema or "specimen_role" not in schema:
    print("wp-ax-05: schema.toml missing optional axiom fields", file=sys.stderr)
    fail = 1
if fail:
    sys.exit(1)
print("wp-ax-05-catalog-axiom-fields: OK")
PY
