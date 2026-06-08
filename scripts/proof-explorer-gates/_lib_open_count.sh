#!/usr/bin/env bash
# Shared open-catalog counters from proof-database TOML entries.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import json
import re
import sys
from pathlib import Path

root = Path(".")
entries_dir = root / "docs/verification/proof-database/entries"
if not entries_dir.is_dir():
    print("_lib_open_count: missing entries dir", file=sys.stderr)
    sys.exit(1)

total = proved = open_c = axiomatic = target = discrepancy = 0
open_non_erdos = open_erdos = 0

for path in sorted(entries_dir.glob("*.toml")):
    text = path.read_text(encoding="utf-8")
    is_erdos = "erdos" in path.name.lower()
    for block in re.split(r"\[\[entry\]\]", text)[1:]:
        total += 1
        m = re.search(r'proof_status\s*=\s*"([^"]+)"', block)
        status = m.group(1) if m else "open"
        if status == "proved":
            proved += 1
        elif status == "open":
            open_c += 1
            if is_erdos:
                open_erdos += 1
            else:
                open_non_erdos += 1
        elif status == "axiomatic":
            axiomatic += 1
        elif status == "target":
            target += 1
        elif status == "discrepancy":
            discrepancy += 1

out = {
    "total": total,
    "proved": proved,
    "open": open_c,
    "open_non_erdos": open_non_erdos,
    "open_erdos": open_erdos,
    "axiomatic": axiomatic,
    "target": target,
    "discrepancy": discrepancy,
}
print(json.dumps(out))
PY
