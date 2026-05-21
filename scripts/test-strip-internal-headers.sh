#!/usr/bin/env bash
# M1 wave 8 — x-internal-* strip policy + optional live proxy check.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 "$ROOT/scripts/test-header-filter-policy.py"
if [[ "${LI_SKIP_HEADER_STRIP_LIVE:-}" == "1" ]]; then
  echo "test-strip-internal-headers: skipped live proxy (LI_SKIP_HEADER_STRIP_LIVE=1)"
  exit 0
fi
exec python3 "$ROOT/scripts/_run_header_strip_check.py"
