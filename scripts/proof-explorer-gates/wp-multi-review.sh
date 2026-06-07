#!/usr/bin/env bash
# WP-MR: each claim has min reviewers (default 2).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
python3 scripts/research-audit/check-reviews.py
