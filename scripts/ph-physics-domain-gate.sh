#!/usr/bin/env bash
# PH-physics domain API gate — symbol presence + def-syntax for lic#7 packages.
set -euo pipefail
ROOT="${PH_PHYSICS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

echo "==> def-syntax (physics packages)"
bash scripts/check-li-def-syntax.sh packages/li-physics-hep
bash scripts/check-li-def-syntax.sh packages/li-physics-aero
bash scripts/check-li-def-syntax.sh packages/li-physics-chem
bash scripts/check-li-def-syntax.sh packages/li-physics-core

echo "==> domain symbol gate"
declare -A SYM_FILE=(
  [decay_branching]=packages/li-physics-hep/src/lib.li
  [isotropic_sample_angles]=packages/li-physics-hep/src/lib.li
  [hep_toy_cross_section_smoke]=packages/li-physics-hep/src/lib.li
  [gravity_accel_from_offset]=packages/li-physics-aero/src/lib.li
  [orbit_leapfrog_step]=packages/li-physics-aero/src/lib.li
  [orbit_two_body_smoke]=packages/li-physics-aero/src/lib.li
  [arrhenius_rate]=packages/li-physics-chem/src/lib.li
  [chem_arrhenius_smoke]=packages/li-physics-chem/src/lib.li
  [scalar_field2d_new]=packages/li-physics-core/src/lib.li
  [physics_core_units_smoke]=packages/li-physics-core/src/lib.li
)
for sym in "${!SYM_FILE[@]}"; do
  file="${SYM_FILE[$sym]}"
  if ! grep -q "def ${sym}" "$file"; then
    echo "ph-physics-domain-gate: missing def ${sym} in ${file}" >&2
    exit 1
  fi
done

LIC="${LIC_BIN:-${LIC:-}}"
if [[ -n "$LIC" ]] && "$LIC" --version &>/dev/null; then
  BUILD_FLAGS=(--allow-open-vc --no-lean-verify)
  echo "==> lic build smokes"
  "$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-hep/li-tests/smoke/hep_toy_mc_smoke.li -o /dev/null
  "$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-aero/li-tests/smoke/orbit_two_body_smoke.li -o /dev/null
  "$LIC" build "${BUILD_FLAGS[@]}" packages/li-physics-chem/li-tests/smoke/arrhenius_smoke.li -o /dev/null
fi

echo "ph-physics-domain-gate OK"
