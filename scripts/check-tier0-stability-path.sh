#!/usr/bin/env bash
# Smoke: tier0_stability catalog path exists on lic (lic#24 / PH-5b).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TIER0="$ROOT/li-tests/benchmarks/tier0_correctness"
MANIFEST="$ROOT/li-tests/manifest.toml"

[[ -d "$TIER0" ]] || { echo "missing $TIER0" >&2; exit 1; }

expected=(float_binop.li md_energy_single_step.li three_body_invariants.li)
for f in "${expected[@]}"; do
  [[ -f "$TIER0/$f" ]] || { echo "missing $TIER0/$f" >&2; exit 1; }
done

for f in "${expected[@]}"; do
  grep -q "benchmarks/tier0_correctness/$f" "$MANIFEST" || {
    echo "manifest missing row for benchmarks/tier0_correctness/$f" >&2
    exit 1
  }
done

echo "tier0_stability path ok (${#expected[@]} smokes + manifest rows)"
