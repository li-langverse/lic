#!/usr/bin/env bash
# Shared counter for phase-8 basic corpus catalog rows.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ROOT
FIELD="${1:?field}"
MIN="${2:?min count}"
python3 - "$FIELD" "$MIN" <<'PY'
import re, sys
from pathlib import Path

root = Path(sys.argv[3] if len(sys.argv) > 3 else __import__("os").environ["ROOT"])
field = sys.argv[1]
min_count = int(sys.argv[2])
entries = root / "docs/verification/proof-database/entries"
note = "phase8-basic-corpus"
count = 0
for path in entries.glob("*.toml"):
    text = path.read_text(encoding="utf-8")
    if note not in text:
        continue
    blocks = re.split(r"\[\[entry\]\]", text)
    for block in blocks[1:]:
        if f'field = "{field}"' not in block:
            continue
        if note not in block:
            continue
        if "li_specimen" not in block:
            continue
        count += 1
if count < min_count:
    print(f"wp-basic-corpus-{field}: {count} entries (want >= {min_count})", file=sys.stderr)
    sys.exit(1)
print(f"wp-basic-corpus-{field}: OK ({count} entries with li_specimen)")
PY
