#!/usr/bin/env bash
# Gates for World Studio master plan loop — native li-studio smokes + plan docs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_detect_compilers 2>/dev/null || true
export LI_REPO_ROOT="$ROOT"

fail() { li_gate_fail "$*"; exit 1; }

LIC="${LIC:-}"
for c in \
  "$ROOT/build-wsl/compiler/lic/lic" \
  "$ROOT/build/compiler/lic/lic" \
  "$ROOT/build/compiler/lic/lic.exe"; do
  if [[ -x "$c" ]]; then LIC="$c"; break; fi
done
if [[ -z "$LIC" && -x "$ROOT/scripts/resolve-lic.sh" ]]; then
  LIC="$("$ROOT/scripts/resolve-lic.sh" 2>/dev/null)" || true
fi

wsl_root_path() {
  local p="$ROOT"
  p="${p//\\//}"
  if [[ "$p" =~ ^/([a-zA-Z])/(.*)$ ]]; then
    echo "/mnt/${BASH_REMATCH[1],,}/${BASH_REMATCH[2]}"
    return
  fi
  if [[ "$p" =~ ^([A-Za-z]):/(.*)$ ]]; then
    echo "/mnt/${BASH_REMATCH[1],,}/${BASH_REMATCH[2]}"
    return
  fi
  echo "$p"
}

lic_check_rel() {
  local rel="$1"
  local path="$ROOT/$rel"
  [[ -f "$path" ]] || fail "missing $rel"
  if [[ -f "$ROOT/build-wsl/compiler/lic/lic" ]] && command -v wsl >/dev/null 2>&1; then
    local wsl_root
    wsl_root="$(wsl_root_path)"
    wsl -e bash -lc "cd '$wsl_root' && ./build-wsl/compiler/lic/lic check --no-cache $rel" \
      || fail "lic check $rel (wsl)"
  elif [[ -n "$LIC" && -x "$LIC" ]]; then
    "$LIC" check "$path" || fail "lic check $rel"
  else
    fail "lic not runnable for $rel"
  fi
}

li_phase "plan documents"
[[ -f "$ROOT/docs/game-dev/WORLD-STUDIO-MASTER-PLAN.md" ]] || fail "WORLD-STUDIO-MASTER-PLAN.md"
[[ -f "$ROOT/docs/superpowers/plans/2026-05-29-world-studio-master-plan-loop.md" ]] || fail "world-studio plan loop yaml"
[[ -f "$ROOT/.cursor/rules/li-studio-demo-native-only.mdc" ]] || fail "li-studio-demo-native-only rule"
[[ -f "$ROOT/docs/game-dev/studio-mcp-tools.md" ]] || fail "studio-mcp-tools.md"

li_phase "loop scripts"
[[ -x "$ROOT/scripts/world-studio-plan-loop.py" ]] || chmod +x "$ROOT/scripts/world-studio-plan-loop.py"
[[ -f "$ROOT/scripts/world-studio-plan-commit-push.sh" ]] || fail "world-studio-plan-commit-push.sh"

li_phase "design tokens"
[[ -f "$ROOT/docs/design/studio-design-tokens.toml" ]] || fail "studio-design-tokens.toml"

if [[ "${WORLD_STUDIO_GATES_SKIP_LIC:-0}" == "1" ]]; then
  li_warn "skip lic check smokes (WORLD_STUDIO_GATES_SKIP_LIC=1)"
else
  if [[ ! -f "$ROOT/build-wsl/compiler/lic/lic" && ( -z "$LIC" || ! -x "$LIC" ) ]]; then
    li_warn "lic not built — set WORLD_STUDIO_GATES_SKIP_LIC=1 or run ./scripts/build.sh"
  else
    li_phase "li-studio core smokes"
    for smoke in \
      studio_shell_demo.li \
      studio_vertical_profile_roundtrip.li \
      studio_sim_step_by_profile.li \
      studio_toml_engine_export.li \
      studio_sim_rl_step_hook.li \
      studio_sim_sensor_step_hook.li \
      studio_mcp_tools.li \
      studio_agentic_run.li; do
      lic_check_rel "packages/li-studio/li-tests/smoke/$smoke"
    done
    li_phase "li-sim-sensors smoke"
    lic_check_rel "packages/li-sim-sensors/li-tests/smoke/sensor_bus_raycast_contract.li"
  fi
fi

if [[ -f "$ROOT/scripts/bench-studio-viewport-perf.sh" ]]; then
  li_phase "viewport bench (soft)"
  "$ROOT/scripts/bench-studio-viewport-perf.sh" || li_warn "bench-studio-viewport-perf soft-fail"
fi

li_phase "iteration assessment"
assess="$ROOT/data/world-studio-plan-loop/latest-iteration-assessment.json"
if [[ -f "$assess" ]]; then
  (cd "$ROOT" && python3 -c "
import json, sys
from pathlib import Path
p = Path('data/world-studio-plan-loop/latest-iteration-assessment.json')
d = json.loads(p.read_text(encoding='utf-8'))
if not d.get('native_only', True):
    print('assessment: native_only must be true', file=sys.stderr)
    sys.exit(1)
") || fail "latest-iteration-assessment.json native_only=false"
else
  li_warn "no latest-iteration-assessment.json yet (agent should write after iteration)"
fi

li_ok "world-studio plan gates"
