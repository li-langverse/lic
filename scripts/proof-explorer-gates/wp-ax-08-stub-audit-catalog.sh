#!/usr/bin/env bash
# WP-AX-08: stub-audit clean for math axiom_layer catalog specimens.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import re
import subprocess
import sys
from pathlib import Path

root = Path(".")
math_axiom_paths: list[Path] = []
toml = root / "docs/verification/proof-database/entries/math-axioms.toml"
for block in re.split(r"\[\[entry\]\]", toml.read_text(encoding="utf-8"))[1:]:
    m = re.search(r'li_specimen\s*=\s*"([^"]+)"', block)
    if m:
        math_axiom_paths.append(root / m.group(1))
# Run full stub-audit; allow violations outside math axiom_layer paths
proc = subprocess.run(
    [sys.executable, "scripts/formalization/stub-audit.py"],
    cwd=root,
    capture_output=True,
    text=True,
)
lines = (proc.stdout or "").splitlines()
scoped = [ln for ln in lines if any(str(p.relative_to(root)) in ln for p in math_axiom_paths)]
if scoped:
    for ln in scoped:
        print(ln, file=sys.stderr)
    print(f"wp-ax-08: {len(scoped)} math axiom specimen violation(s)", file=sys.stderr)
    sys.exit(1)
print("wp-ax-08-stub-audit-catalog: OK (math axiom paths clean)")
PY
