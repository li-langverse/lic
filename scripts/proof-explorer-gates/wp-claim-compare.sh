#!/usr/bin/env bash
# WP-CM: compare model "proved" verdicts vs Li epistemic status.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
python3 scripts/research-audit/compare-claims.py --check
