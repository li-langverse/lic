#!/usr/bin/env bash
# WP-CQ-02: physics placeholder rows use honest discrepancy status.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import re
import sys
from pathlib import Path

root = Path(".")
checks = {
    "P-AX-DIM-001": "discrepancy",
    "P-AX-DIM-002": "discrepancy",
    "P-LM-MOM-001": "discrepancy",
}
entries = root / "docs/verification/proof-database/entries"
fail = 0
for eid, want in checks.items():
    found = False
    for toml in entries.glob("*.toml"):
        for block in re.split(r"\[\[entry\]\]", toml.read_text(encoding="utf-8"))[1:]:
            if not re.search(rf'id\s*=\s*"{re.escape(eid)}"', block):
                continue
            found = True
            m = re.search(r'proof_status\s*=\s*"([^"]+)"', block)
            got = m.group(1) if m else "MISSING"
            if got != want:
                print(f"wp-cq-02: {eid} proof_status={got} want {want}", file=sys.stderr)
                fail = 1
    if not found:
        print(f"wp-cq-02: missing entry {eid}", file=sys.stderr)
        fail = 1
if fail:
    sys.exit(1)
print("wp-cq-02-physics-placeholders: OK")
PY
