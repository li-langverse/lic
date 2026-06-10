#!/usr/bin/env bash
# PH-SCI Phase 2 completion gate — package smokes + phase0 regression spine.
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

LIC="${LIC_BIN:-${LIC:-}}"
if [[ -z "$LIC" ]] || ! "$LIC" --version &>/dev/null; then
  LIC="$("$ROOT/scripts/resolve-lic.sh")"
fi
export LIC
BUILD_FLAGS=(--allow-open-vc --no-lean-verify)

echo "==> Phase 0 regression spine"
bash scripts/ph-sci-phase0-gates.sh

echo "==> WP-SCI-03/05/06: scientific registry + oracles"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li -o /dev/null

echo "==> WP-SCI-06: CFD cavity"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-fluids/li-tests/smoke/cfd_cavity_smoke.li -o /dev/null

echo "==> WP-SCI-04: viz wgpu field draw progression"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-viz/li-tests/smoke/viz_wgpu_field_draw.li -o /dev/null

echo "==> WP-SIM-04: SimWorld replay snapshot"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim/li-tests/smoke/sim_world_replay_roundtrip.li -o /dev/null

echo "==> WP-SIM-05: sensor scene bounds raycast"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-sensors/li-tests/smoke/sensor_bus_raycast_contract.li -o /dev/null

echo "==> WP-AM-02: thermal gate witness"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-additive/li-tests/smoke/slicer_workflow.li -o /dev/null

echo "==> WP-AUTO-02: map + odometry"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-automotive/li-tests/smoke/automotive_map_odom.li -o /dev/null

echo "==> WP-DRUG-04: chem.dft queue"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-drug-design/li-tests/smoke/drug_dft_queue.li -o /dev/null

echo "==> WP-PLAT-05: md_oracle external column driver"
bash scripts/run-md-oracle-external.sh

echo "ph-sci-gap-close Phase 2 gate OK"
