#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
python3 scripts/proof-db/proof-db.py verify-slice
echo "wp4-audit: verify-slice OK"
