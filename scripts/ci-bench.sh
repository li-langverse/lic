#!/usr/bin/env bash
# Optional CI bench smoke: tier-1 micro timings (no julia required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
export LIC="$ROOT/build/compiler/lic/lic"

if [[ ! -x "$LIC" ]]; then
  echo "ci-bench: run scripts/ci.sh first" >&2
  exit 1
fi

li_phase "HPC competitive registry (advisory)"
chmod +x "$ROOT/scripts/check-hpc-competitive.sh" "$ROOT/scripts/hpc-competitive-snapshot.sh"
export LI_HPC_COMPETITIVE_STRICT=0
"$ROOT/scripts/check-hpc-competitive.sh"
"$ROOT/scripts/hpc-competitive-snapshot.sh" || true

python3 "$ROOT/benchmarks/harness/bench.py" --tier 1 --runs 1 --skip-verify
python3 "$ROOT/benchmarks/harness/bench.py" --tier 2 --ci
python3 "$ROOT/benchmarks/harness/bench_ecosystem.py" --runs 1 --skip-security
echo "ci-bench: ok"
