#!/usr/bin/env bash
# WP-DS-04 — float vs real discharge policy documented (BUG-L-01).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

policy="docs/verification/float-discharge-policy.md"
if [[ ! -f "$policy" ]]; then
  echo "wp-float-policy: missing $policy" >&2
  exit 1
fi

python3 - <<'PY'
from pathlib import Path
text = Path("docs/verification/float-discharge-policy.md").read_text(encoding="utf-8")
required = ("float", "real", "gap_kind", "discharge")
missing = [k for k in required if k.lower() not in text.lower()]
if missing:
    raise SystemExit(f"wp-float-policy: policy doc missing keywords: {missing}")
print("wp-float-policy: OK (policy doc present)")
PY
