#!/usr/bin/env bash
# WP-CQ-05: non-Erdős lemma enrichment sample tranche (math/linalg/discrete).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import re
import sys
from pathlib import Path

root = Path(".")
want_specimen = [
    "D-LM-DOT4-INT-LOOP",
    "N-LM-DOT4-INT-LOOP",
    "M-LM-ADD-COMM",
    "M-LM-NAT-ADD-COMM",
]
entries = root / "docs/verification/proof-database/entries"
fail = 0
for eid in want_specimen:
    found = False
    for toml in entries.glob("*.toml"):
        for block in re.split(r"\[\[entry\]\]", toml.read_text(encoding="utf-8"))[1:]:
            if not re.search(rf'id\s*=\s*"{re.escape(eid)}"', block):
                continue
            found = True
            m = re.search(r'li_specimen\s*=\s*"([^"]+)"', block)
            if not m:
                print(f"wp-cq-05: {eid} missing li_specimen", file=sys.stderr)
                fail = 1
                continue
            path = root / m.group(1)
            if not path.is_file():
                print(f"wp-cq-05: {eid} specimen missing {path}", file=sys.stderr)
                fail = 1
    if not found:
        print(f"wp-cq-05: entry {eid} not found", file=sys.stderr)
        fail = 1
if fail:
    sys.exit(1)
print("wp-cq-05-lemma-enrichment: OK")
PY
