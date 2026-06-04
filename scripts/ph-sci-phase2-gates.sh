#!/usr/bin/env bash
# PH-SCI Phase 2 partial gate — WP-SCI-05 FEA + WP-SCI-06 CFD cavity oracles.
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

LIC="${LIC_BIN:-${LIC:-}}"
if [[ -z "$LIC" ]] || ! "$LIC" --version &>/dev/null; then
  LIC="$("$ROOT/scripts/resolve-lic.sh")"
fi
export LIC
BUILD_FLAGS=(--allow-open-vc --no-lean-verify)

echo "==> WP-SCI-05: rigid FEA bar lib + sim.scientific FEA oracle"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-rigid/src/lib.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-scientific/src/lib.li -o /dev/null

echo "==> WP-SCI-05: FEA smokes"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-scientific/li-tests/smoke/scientific_fea_elasticity.li -o /dev/null
"$LIC" verify "${BUILD_FLAGS[@]}" packages/li-sim-scientific/li-tests/smoke/scientific_fea_elasticity.li

echo "==> WP-SCI-06: fluids cavity lib + sim.scientific CFD oracle"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-fluids/src/lib.li -o /dev/null

echo "==> WP-SCI-06: cavity + tier-2 registry smokes"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-scientific/li-tests/smoke/scientific_cfd_cavity.li -o /dev/null
"$LIC" verify "${BUILD_FLAGS[@]}" packages/li-sim-scientific/li-tests/smoke/scientific_cfd_cavity.li
"$LIC" verify "${BUILD_FLAGS[@]}" packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li
"$LIC" verify "${BUILD_FLAGS[@]}" packages/li-sim-scientific/li-tests/smoke/scientific_oracle_bench.li

echo "ph-sci-simulation-gap-close: Phase 2 (WP-SCI-05, WP-SCI-06) gate OK"
