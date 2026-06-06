#!/usr/bin/env bash
# WP-T10-09: main CI smoke â€” check-li-def-syntax + proof-db verify slice.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

bash scripts/check-li-def-syntax.sh
python3 scripts/proof-db/proof-db.py verify-slice
echo "wp-t10-09-main-ci: OK"
