#!/usr/bin/env bash
# Phase 9 gate: catalog-referenced proof-db specimens must not contain proc.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 scripts/formalization/destub-proc-specimens.py --dry-run >/dev/null || true

hits=0
while IFS= read -r -d '' f; do
  if grep -qE '\bproc\b' "$f"; then
    echo "wp-destub-proc-specimens: proc in $f" >&2
    hits=$((hits + 1))
  fi
done < <(python3 - <<'PY'
import re
import tomllib
from pathlib import Path

root = Path(".")
entries_dir = root / "docs/verification/proof-database/entries"
specimens: set[Path] = set()
for path in sorted(entries_dir.glob("*.toml")):
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    rows = data.get("entry") or []
    if isinstance(rows, dict):
        rows = [rows]
    for row in rows:
        rel = row.get("li_specimen")
        if not rel or not str(rel).startswith("proof-db/"):
            continue
        p = root / str(rel)
        if p.is_file():
            specimens.add(p.resolve())
for p in sorted(specimens):
    print(p, end="\0")
PY
)

if [[ "$hits" -gt 0 ]]; then
  echo "wp-destub-proc-specimens: FAIL ($hits catalog specimen file(s) contain proc)" >&2
  exit 1
fi
echo "wp-destub-proc-specimens: OK (0 proc in catalog proof-db specimens)"
exit 0
