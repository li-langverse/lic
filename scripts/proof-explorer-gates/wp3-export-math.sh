#!/usr/bin/env bash
# WP3 — lic export-math MVP emits math-field catalog JSON with schema v3 rich fields.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
export LI_REPO_ROOT="$ROOT"

resolve_lic() {
  if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
    echo "$ROOT/build/compiler/lic/lic"
    return 0
  fi
  if command -v "$ROOT/scripts/resolve-lic.sh" >/dev/null 2>&1; then
    "$ROOT/scripts/resolve-lic.sh" 2>/dev/null && return 0
  fi
  return 1
}

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

if LIC="$(resolve_lic)"; then
  "$LIC" export-math -o "$TMP"
else
  echo "wp3-export-math: lic binary missing; running scripts/export-math.py"
  python3 scripts/export-math.py -o "$TMP"
fi

python3 - <<'PY' "$TMP"
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text(encoding="utf-8"))
entries = data.get("entries", [])
if not entries:
    print("wp3-export-math: empty entries", file=sys.stderr)
    sys.exit(1)

mconj = [e for e in entries if str(e.get("id", "")).startswith("M-CONJ-")]
if not mconj:
    print("wp3-export-math: no M-CONJ rows in export", file=sys.stderr)
    sys.exit(1)

anchor = next((e for e in mconj if e.get("id") == "M-CONJ-ABC"), None)
if anchor is None:
    print("wp3-export-math: M-CONJ-ABC missing", file=sys.stderr)
    sys.exit(1)
for field in ("latex", "context", "sources", "content_tier"):
    val = anchor.get(field)
    if val is None or (isinstance(val, str) and not val.strip()):
        print(f"wp3-export-math: M-CONJ-ABC missing {field}", file=sys.stderr)
        sys.exit(1)

footer = (data.get("attribution") or {}).get("footer") or {}
if not footer.get("line1") or not footer.get("line2"):
    print("wp3-export-math: attribution footer missing", file=sys.stderr)
    sys.exit(1)

print(f"wp3-export-math: OK ({len(entries)} math entries, {len(mconj)} M-CONJ)")
PY

python3 scripts/proof-db/proof-db.py verify-slice
echo "wp3-export-math: verify-slice OK"
