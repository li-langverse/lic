#!/usr/bin/env bash
# WP-CQ-04: stub-audit clean for math + vertical axiom catalog specimens.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import re
import subprocess
import sys
from pathlib import Path

root = Path(".")
axiom_paths: list[Path] = []
entries = root / "docs/verification/proof-database/entries"
for toml in sorted(entries.glob("*.toml")):
    text = toml.read_text(encoding="utf-8")
    for block in re.split(r"\[\[entry\]\]", text)[1:]:
        if not re.search(r'kind\s*=\s*"axiom"', block):
            continue
        m = re.search(r'li_specimen\s*=\s*"([^"]+)"', block)
        if m:
            axiom_paths.append(root / m.group(1))

proc = subprocess.run(
    [sys.executable, "scripts/formalization/stub-audit.py"],
    cwd=root,
    capture_output=True,
    text=True,
)
lines = (proc.stdout or "").splitlines()
scoped = [ln for ln in lines if any(str(p.relative_to(root)) in ln for p in axiom_paths)]
if scoped:
    for ln in scoped:
        print(ln, file=sys.stderr)
    print(f"wp-cq-04: {len(scoped)} axiom specimen violation(s)", file=sys.stderr)
    sys.exit(1)
print(f"wp-cq-04-axiom-specimen-audit: OK ({len(axiom_paths)} axiom specimens scoped)")
PY
