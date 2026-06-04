#!/usr/bin/env bash
# PH-SCI Phase 1 completion gate — science_gpu @gpu smokes + extended honest package smokes.
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

LIC="${LIC_BIN:-${LIC:-}}"
if [[ -z "$LIC" ]] || ! "$LIC" --version &>/dev/null; then
  LIC="$("$ROOT/scripts/resolve-lic.sh")"
fi
export LIC
BUILD_FLAGS=(--allow-open-vc --no-lean-verify)

echo "==> WP-SCI-BUILD-03 (extended): li-sim + li-physics-core honest smokes"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-core/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-scientific/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-sensors/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-additive/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-automotive/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-drug-design/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-sim-robotics/li-tests/smoke/builds.li -o /dev/null

echo "==> WP-SCI-GPU-01..15: science_gpu suite"
bash scripts/check-science-gpu-gate.sh

echo "ph-sci-simulation-gap-close: Phase 1 gate OK"
