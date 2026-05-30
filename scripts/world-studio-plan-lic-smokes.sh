#!/usr/bin/env bash
# Run World Studio plan-loop lic check smokes (Linux/WSL or native lic on PATH).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIC="${LIC:-}"
if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
elif [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic.exe" ]]; then
  LIC="$ROOT/build/compiler/lic/lic.exe"
fi
[[ -n "$LIC" && -x "$LIC" ]] || {
  echo "world-studio-plan-lic-smokes: lic not found (build lic or set LIC=)" >&2
  exit 1
}

for smoke in env_pool_stub.li env_pool_step_contract.li; do
  "$LIC" check "$ROOT/packages/li-sim/li-tests/smoke/$smoke"
done

for smoke in \
  studio_shell_demo.li \
  studio_vertical_profile_roundtrip.li \
  studio_sim_step_by_profile.li \
  studio_sim_rl_step_hook.li \
  studio_timeline_playback.li \
  studio_toml_engine_export.li \
  studio_command_palette.li \
  studio_keyboard_bridge.li \
  studio_mcp_tools.li \
  studio_mcp_dispatch_run.li \
  studio_mcp_stdio_server.li \
  studio_agentic_run.li \
  studio_agent_chrome.li \
  studio_agent_chrome_fsm.li \
  studio_viewport_hud.li \
  studio_viewport_error.li \
  studio_native_pixels_wgpu_readback.li; do
  (cd "$ROOT/packages/li-studio" && "$LIC" check "li-tests/smoke/$smoke")
done

echo "world-studio-plan-lic-smokes: ok"
