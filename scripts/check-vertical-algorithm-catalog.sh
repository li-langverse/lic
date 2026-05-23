#!/usr/bin/env bash
# AL-2 gate: vertical-algorithm-catalog.md sections match verticals.toml rows.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"

li_phase "vertical algorithm catalog (AL-2)"
[[ -f "$VERTICALS" ]] || { li_fail "missing $VERTICALS"; exit 1; }
[[ -f "$CATALOG" ]] || { li_fail "missing $CATALOG"; exit 1; }

export VERTICALS CATALOG
python3 - <<'PY'
from __future__ import annotations

import os
import re
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

verticals_path = Path(os.environ["VERTICALS"])
catalog_path = Path(os.environ["CATALOG"])

data = tomllib.loads(verticals_path.read_text())
rows = data.get("vertical")
if not isinstance(rows, list) or not rows:
    print("verticals.toml: [[vertical]] must be non-empty", file=sys.stderr)
    sys.exit(1)

ids: list[str] = []
for i, row in enumerate(rows):
    if not isinstance(row, dict):
        print(f"vertical[{i}]: not a table", file=sys.stderr)
        sys.exit(1)
    vid = row.get("id")
    if not vid:
        print(f"vertical[{i}]: missing id", file=sys.stderr)
        sys.exit(1)
    if vid in ids:
        print(f"duplicate vertical id: {vid}", file=sys.stderr)
        sys.exit(1)
    ids.append(str(vid))

catalog = catalog_path.read_text()
# Level-2 headings only (## id), not ### subsections.
heading_re = re.compile(r"^## ([a-z0-9_]+)\s*$", re.MULTILINE)
catalog_ids = heading_re.findall(catalog)
# Skip document title if ever matched — our ids are snake_case registry keys.
catalog_set = set(catalog_ids)

errors: list[str] = []
for vid in ids:
    if vid not in catalog_set:
        errors.append(f"catalog missing section ## {vid}")
    # Section body: from ## id until next ## or EOF
    m = re.search(rf"^## {re.escape(vid)}\s*$", catalog, re.MULTILINE)
    if not m:
        continue
    rest = catalog[m.end() :]
    nxt = re.search(r"^## ", rest, re.MULTILINE)
    body = rest[: nxt.start()] if nxt else rest
    for token in ("workload_class", "li_package", "oracle", "stub"):
        if token not in body:
            errors.append(f"## {vid}: section must mention {token!r}")

for cid in catalog_set:
    if cid not in ids:
        errors.append(f"catalog has extra section ## {cid} not in verticals.toml")

if len(catalog_ids) != len(set(catalog_ids)):
    errors.append("catalog: duplicate ## headings")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print(f"vertical-algorithm-catalog: ok ({len(ids)} verticals)")
PY

li_ok "vertical algorithm catalog"
