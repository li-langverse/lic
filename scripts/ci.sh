#!/usr/bin/env bash
# CI entry: build lic, li-tests, tier-0 benchmarks (verify + stability).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export CC="${CC:-clang}"
export CXX="${CXX:-clang++}"

echo "==> build"
"$ROOT/scripts/build.sh"

export LIC="$("$ROOT/scripts/resolve-lic.sh")"

echo "==> security corpus (no crash on malformed input)"
chmod +x "$ROOT/li-tests/run_security.sh"
"$ROOT/li-tests/run_security.sh"

echo "==> tier 0 (li-tests incl. race_shared_memory + verify + stability)"
python3 "$ROOT/benchmarks/harness/bench.py" --tier 0

echo "==> race_shared_memory (parallel exploit suite)"
"$ROOT/li-tests/run_all.sh" race_shared_memory

echo "ci: ok"
