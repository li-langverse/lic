#!/usr/bin/env bash
# WP-HW-09: validate runtime/lig-ptx-catalog.toml vs embedded .inc files.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/runtime/lig-ptx-catalog.toml"
[[ -f "$MANIFEST" ]] || { echo "FAIL missing $MANIFEST" >&2; exit 1; }

python3 - "$ROOT" "$MANIFEST" <<'PY'
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

root = Path(sys.argv[1])
manifest = Path(sys.argv[2])
data = tomllib.loads(manifest.read_text(encoding="utf-8"))
embedded = data.get("embedded", [])
if not embedded:
    print("FAIL lig-ptx-catalog: no [[embedded]] rows")
    sys.exit(1)

for row in embedded:
    kid = row.get("kernel_id", "")
    inc = row.get("ptx_inc", "")
    sym = row.get("symbol", "")
    inc_path = root / inc
    if not inc_path.is_file():
        print(f"FAIL missing ptx inc for {kid}: {inc}")
        sys.exit(1)
    text = inc_path.read_text(encoding="utf-8", errors="replace")
    if sym not in text:
        print(f"FAIL symbol {sym!r} not referenced in {inc}")
        sys.exit(1)
    cu = row.get("source_cu", "")
    if cu and not (root / cu).is_file():
        print(f"FAIL missing source_cu for {kid}: {cu}")
        sys.exit(1)

blocked = data.get("blocked", [])
print(
    f"check-lig-ptx-catalog: ok ({len(embedded)} embedded, {len(blocked)} blocked documented)"
)
PY
