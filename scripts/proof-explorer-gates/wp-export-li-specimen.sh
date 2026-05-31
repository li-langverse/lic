#!/usr/bin/env bash
# WP-EF-05 / WP-RS-04 — export-math includes li_specimen on formalized rows.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
export LI_REPO_ROOT="$ROOT"

resolve_lic() {
  if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
    echo "$ROOT/build/compiler/lic/lic"
    return 0
  fi
  return 1
}

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

if LIC="$(resolve_lic)"; then
  "$LIC" export-math -o "$TMP" 2>/dev/null || python3 scripts/export-math.py -o "$TMP"
else
  python3 scripts/export-math.py -o "$TMP"
fi

python3 - <<'PY' "$TMP"
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
entries = data.get("entries", [])
with_specimen = [e for e in entries if e.get("li_specimen")]
if len(with_specimen) < 5:
    raise SystemExit(f"wp-export-li-specimen: only {len(with_specimen)} entries with li_specimen (want >=5)")

# At least one Erdős and one M-CONJ
erdos = [e for e in with_specimen if str(e.get("id", "")).startswith("E-")]
mconj = [e for e in with_specimen if str(e.get("id", "")).startswith("M-CONJ-")]
if not erdos or not mconj:
    raise SystemExit("wp-export-li-specimen: need both Erdős and M-CONJ rows with li_specimen")
print(f"wp-export-li-specimen: OK ({len(with_specimen)} entries with li_specimen)")
PY
