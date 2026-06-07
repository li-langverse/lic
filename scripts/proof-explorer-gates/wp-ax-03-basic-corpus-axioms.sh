#!/usr/bin/env bash
# WP-AX-03: basic-corpus axiom_layer — track non-witness primary defs (≥5% or ≥10 files).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
MIN_RATIO="${MIN_AXIOM_CONTRACT_RATIO:-0.05}"
MIN_COUNT="${MIN_AXIOM_CONTRACT_COUNT:-10}"

python3 - "$MIN_RATIO" "$MIN_COUNT" <<'PY'
import re
import sys
from pathlib import Path

root = Path(".")
min_ratio = float(sys.argv[1])
min_count = int(sys.argv[2])
entries = root / "docs/verification/proof-database/entries"
specimens: set[str] = set()
for path in entries.glob("*.toml"):
    text = path.read_text(encoding="utf-8")
    if "gap_kind = \"axiom_layer\"" not in text and "gap_kind = 'axiom_layer'" not in text:
        continue
    for block in re.split(r"\[\[entry\]\]", text)[1:]:
        if "axiom_layer" not in block:
            continue
        m = re.search(r'li_specimen\s*=\s*"([^"]+)"', block)
        if m:
            specimens.add(m.group(1))
witness = 0
contract = 0
for rel in sorted(specimens):
    p = root / rel
    if not p.is_file():
        continue
    text = p.read_text(encoding="utf-8", errors="replace")
    if "_axiom_witness" in text:
        witness += 1
    defs = re.findall(r"^def\s+(\w+)", text, re.M)
    primary = [d for d in defs if d != "main" and not d.endswith("_axiom_witness")]
    if primary:
        has_nt = any(
            ln.strip() != "ensures result == 0"
            for ln in text.splitlines()
            if ln.strip().startswith("ensures")
        )
        if has_nt:
            contract += 1
total = witness + contract
if total == 0:
    print("wp-ax-03: no axiom_layer specimens", file=sys.stderr)
    sys.exit(1)
ratio = contract / total
if contract < min_count and ratio < min_ratio:
    print(
        f"wp-ax-03: {contract}/{total} contract-like ({ratio:.2%}); "
        f"want >= {min_count} or >= {min_ratio:.0%}",
        file=sys.stderr,
    )
    sys.exit(1)
print(f"wp-ax-03-basic-corpus-axioms: OK ({contract}/{total} contract-like)")
PY
