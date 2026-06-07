#!/usr/bin/env bash
# WP2 — M-CONJ rows carry schema v3 rich fields (latex, context, sources, content_tier).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

TOML="docs/verification/proof-database/entries/math-conjectures.toml"
grep -q 'M-CONJ-ABC' "$TOML"

python3 - <<'PY'
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

path = Path("docs/verification/proof-database/entries/math-conjectures.toml")
entries = tomllib.loads(path.read_text(encoding="utf-8")).get("entry", [])
mconj = [e for e in entries if str(e.get("id", "")).startswith("M-CONJ-")]
if not mconj:
    print("wp2-m-conj: no M-CONJ entries", file=sys.stderr)
    sys.exit(1)

required_rich = ("content_tier", "latex", "context", "sources")
missing = []
for e in mconj:
    eid = e.get("id", "?")
    for field in required_rich:
        val = e.get(field)
        if val is None or (isinstance(val, str) and not val.strip()):
            missing.append(f"{eid}: missing {field}")
        elif field == "sources" and isinstance(val, list) and len(val) == 0:
            missing.append(f"{eid}: empty sources")

if missing:
    for msg in missing:
        print(f"wp2-m-conj: {msg}", file=sys.stderr)
    sys.exit(1)

anchor = next((e for e in mconj if e.get("id") == "M-CONJ-ABC"), None)
if anchor is None:
    print("wp2-m-conj: M-CONJ-ABC not found", file=sys.stderr)
    sys.exit(1)

print(f"wp2-m-conj: OK ({len(mconj)} M-CONJ rows with rich fields)")
PY

python3 scripts/proof-db/proof-db.py verify-slice
echo "wp2-m-conj: verify-slice OK"
