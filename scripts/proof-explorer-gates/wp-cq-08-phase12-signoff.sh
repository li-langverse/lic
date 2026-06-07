#!/usr/bin/env bash
# WP-CQ-08: phase12 sign-off + proof-library deploy posture.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

test -f data/proof-explorer-loop/wp-cq-catalog-quality.signoff

PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
if [[ -f data/proof-explorer-loop/wp-cq-proof-library-deploy.signoff ]]; then
  echo "wp-cq-08-phase12-signoff: OK (deploy sign-off)"
  exit 0
fi

if [[ -n "$PL" && -f "$PL/data/library.json" ]]; then
  python3 - "$PL/data/library.json" <<'PY'
import json
import sys
from pathlib import Path
data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
if not data.get("lic_commit"):
    sys.exit(1)
div = data.get("summary", {}).get("divergent", 99)
if div > 5:
    sys.exit(1)
print(f"wp-cq-08: library lic_commit={data['lic_commit'][:8]} divergent={div}")
PY
  echo "wp-cq-08-phase12-signoff: OK (library.json fresh; merge PR for Pages)"
  exit 0
fi

echo "wp-cq-08: proof-library not verified" >&2
exit 1
