#!/usr/bin/env bash
# Verification gates for sim / algorithm goal-directed agent (package-scoped).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export LIC="$("$ROOT/scripts/resolve-lic.sh")"

fail() { echo "sim-plan-gates: $*" >&2; exit 1; }

echo "==> build lic (if missing)"
if [[ ! -x "$LIC" ]]; then
  "$ROOT/scripts/build.sh" >/dev/null
fi

PKG="${SIM_PLAN_PACKAGE:-li-sim-scientific}"
echo "==> bench-package $PKG (verify + summaries)"
"$ROOT/scripts/bench-package.sh" "$PKG" --write-summary || fail "bench-package $PKG"

echo "==> algo registry"
python3 "$ROOT/benchmarks/harness/bench_sim.py" --package li-sim --skip-tier2 || fail "registry hook"

if [[ "${SIM_PLAN_FULL_TIER2:-0}" == "1" ]]; then
  echo "==> full tier-2 CI smoke (optional)"
  python3 "$ROOT/benchmarks/harness/bench.py" --tier 2 --ci || fail "tier-2 ci"
else
  echo "==> skip full tier-2 (set SIM_PLAN_FULL_TIER2=1 to enable)"
fi

echo "sim-plan-gates: ok"
