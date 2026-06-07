#!/usr/bin/env bash
# WP-T10-05: stub-audit clean on all catalog li_specimen paths (M-AX + domain).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import re
import subprocess
import sys
from pathlib import Path

root = Path(".")
specimen_paths: list[Path] = []
entries_dir = root / "docs/verification/proof-database/entries"
for toml in entries_dir.glob("*.toml"):
    text = toml.read_text(encoding="utf-8")
    for block in re.split(r"\[\[entry\]\]", text)[1:]:
        m = re.search(r'li_specimen\s*=\s*"([^"]+)"', block)
        if m:
            specimen_paths.append(root / m.group(1))

proc = subprocess.run(
    [sys.executable, "scripts/formalization/stub-audit.py"],
    cwd=root,
    capture_output=True,
    text=True,
)
lines = (proc.stdout or "").splitlines()
scoped = [
    ln for ln in lines
    if any(str(p.relative_to(root)).replace("\\", "/") in ln.replace("\\", "/") for p in specimen_paths)
]
if scoped:
    for ln in scoped[:20]:
        print(ln, file=sys.stderr)
    print(f"wp-t10-05: {len(scoped)} catalog specimen violation(s)", file=sys.stderr)
    sys.exit(1)
print(f"wp-t10-05-stub-audit-catalog: OK ({len(specimen_paths)} specimen paths clean)")
PY
