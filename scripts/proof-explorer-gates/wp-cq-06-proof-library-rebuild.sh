#!/usr/bin/env bash
# WP-CQ-06: rebuild library.json + quality checks (unknown, witness, proc).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PL="$(cd "$ROOT/../proof-library" 2>/dev/null && pwd || true)"
if [[ -z "$PL" || ! -f "$PL/scripts/build-library.py" ]]; then
  if [[ -f "$ROOT/data/proof-explorer-loop/wp-cq-proof-library-deploy.signoff" ]]; then
    echo "wp-cq-06-proof-library-rebuild: OK (deploy sign-off; sibling repo optional)"
    exit 0
  fi
  echo "wp-cq-06: proof-library missing" >&2
  exit 1
fi

LIC_ROOT="$ROOT" python3 "$PL/scripts/build-library.py"
bash "$PL/scripts/check-library-quality.sh"
python3 "$PL/scripts/check-no-proc-in-library.py"
echo "wp-cq-06-proof-library-rebuild: OK"
