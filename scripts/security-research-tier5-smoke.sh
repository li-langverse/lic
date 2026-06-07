#!/usr/bin/env bash
# Tier5 exploit smoke subset for sec-r1 (smuggling, path traversal, slowloris).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
if [[ ! -x "$HTTPD" ]]; then
  echo "security-research-tier5-smoke: skip (build li-httpd first)" >&2
  exit 0
fi
if [[ ! -f "$HARNESS/exploit_http.py" ]]; then
  echo "security-research-tier5-smoke: skip (benchmarks harness missing)" >&2
  exit 0
fi

SUBSET=(request_smuggling_cl_te path_traversal slowloris)
export PYTHONPATH="$HARNESS${PYTHONPATH:+:$PYTHONPATH}"
export LI_HTTPD_BIN="$HTTPD"
export TIER5_EXPLOIT_STUB="${TIER5_EXPLOIT_STUB:-1}"

echo "security-research-tier5-smoke: stub run ${SUBSET[*]}"
python3 "$HARNESS/exploit_http.py" --profile pr "${SUBSET[@]}"
echo "security-research-tier5-smoke: ok"
