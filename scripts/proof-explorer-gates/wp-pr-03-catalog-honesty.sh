#!/usr/bin/env bash
# WP-PR-03: catalog honesty — no proved rows while gap scripts fail.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

bash scripts/proof-explorer-gates/wp-catalog-honesty.sh
bash scripts/proof-explorer-gates/wp-t10-08-erdos-honesty.sh
echo "wp-pr-03-catalog-honesty: OK"
