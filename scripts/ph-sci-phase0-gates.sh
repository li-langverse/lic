#!/usr/bin/env bash
# PH-SCI Phase 0 completion gate — lib compile + science_gpu suite + honest smokes.
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

LIC="${LIC_BIN:-./build-wsl/compiler/lic/lic}"
BUILD_FLAGS=(--allow-open-vc --no-lean-verify)

echo "==> WP-SCI-BUILD-01: fluids / em / weather lib compile"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-fluids/src/lib.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-em/src/lib.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-weather/src/lib.li -o /dev/null

echo "==> WP-SCI-BUILD-02: numerics lib compile"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-math-numerics/src/lib.li -o /dev/null

echo "==> WP-SCI-BUILD-03: honest package smokes (Phase 0 blocked libs)"
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-fluids/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-em/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-weather/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-math-numerics/li-tests/smoke/builds.li -o /dev/null
"$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-particles/li-tests/smoke/builds.li -o /dev/null

echo "==> WP-SCI-GPU-00: science_gpu suite"
bash scripts/check-science-gpu-gate.sh

[[ -f data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md ]] \
  || { echo "missing sprint goal file"; exit 1; }

echo "ph-sci-simulation-gap-close: Phase 0 gate OK"
