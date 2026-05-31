#!/usr/bin/env bash
# WP-RS-05 — proof-library consumes export-math with li_specimen.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

signoff="data/proof-explorer-loop/wp-proof-library-export.signoff"
if [[ ! -f "$signoff" ]]; then
  echo "wp-proof-library-export: missing $signoff (add PR URL after proof-library integration)" >&2
  exit 1
fi

bash scripts/proof-explorer-gates/wp-export-li-specimen.sh
echo "wp-proof-library-export: OK (signoff + export li_specimen)"
