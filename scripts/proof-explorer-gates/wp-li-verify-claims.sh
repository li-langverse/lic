#!/usr/bin/env bash
# WP-LV: Li verification batch ran for at least one claim.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
python3 scripts/research-audit/check-li-verify.py
