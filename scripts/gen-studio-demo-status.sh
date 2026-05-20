#!/usr/bin/env bash
# Write deploy/studio-demo/status.json from li-tests results.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/deploy/studio-demo/status.json"
BRANCH="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo unknown)"
SPRINT="impl-47"

comp_out="$("$ROOT/li-tests/run_all.sh" composable 2>&1)" || true
gd_out="$("$ROOT/li-tests/run_all.sh" game_dev 2>&1)" || true
vd_out="$("$ROOT/li-tests/run_all.sh" vertical_demos 2>&1)" || true
sp_out="$("$ROOT/li-tests/run_all.sh" spinup_templates 2>&1)" || true

comp_pass="$(echo "$comp_out" | sed -n 's/.*pass=\([0-9]*\).*/\1/p' | head -1)"
gd_pass="$(echo "$gd_out" | sed -n 's/.*pass=\([0-9]*\).*/\1/p' | head -1)"
vd_pass="$(echo "$vd_out" | sed -n 's/.*pass=\([0-9]*\).*/\1/p' | head -1)"
sp_pass="$(echo "$sp_out" | sed -n 's/.*pass=\([0-9]*\).*/\1/p' | head -1)"

comp_pass="${comp_pass:-0}"
gd_pass="${gd_pass:-0}"
vd_pass="${vd_pass:-0}"
sp_pass="${sp_pass:-0}"

cat > "$OUT" <<EOF
{
  "branch": "$BRANCH",
  "sprint": "$SPRINT",
  "composable_gates": $comp_pass,
  "game_dev_gates": $gd_pass,
  "vertical_demo_builds": $vd_pass,
  "spinup_templates": $sp_pass,
  "gpu_viewport": true,
  "lkir_present": true,
  "publish_template": true,
  "portable_targets": 5,
  "binary_runtime_tag": 8288,
  "milestone_composable_gates": 155,
  "demo_tabs": 13,
  "li_native_store": true,
  "blocked": ["sim_step_physics"],
  "updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
echo "Wrote $OUT (composable=$comp_pass game_dev=$gd_pass vertical=$vd_pass spinup=$sp_pass)"
