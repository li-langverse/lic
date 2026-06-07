# Studio UI/UX iteration — `studio-ux-19-wgpu-swapchain-readback`

**Branch:** `cursor/studio-ui-ux-plan-loop`  
**North star:** PH-UX viewport honesty (UX-13, UX-14) — swapchain pixels deferred until GPU CI.

## Summary

Added honest wgpu-rs swapchain readback hooks in `li-gpu`, bench/CI scaffolding, and capture-deps probe for Vulkan/GPU runners. CPU ubuntu-24.04 CI expects `status=blocked_runner` (not a PH gate failure).

## Changes

- `packages/li-gpu`: `GpuWgpuSwapchainReadback`, `gpu_wgpu_swapchain_readback_*`
- `packages/li-gpu/bench/wgpu_smoke.toml`: `[wgpu_swapchain]`
- `scripts/bench-studio-viewport-perf.sh`: `wgpu_swapchain` + informational gate
- `scripts/ci-studio-ui-ux-wgpu-swapchain.sh`, `studio-ui-ux-verify-wgpu-swapchain.py`
- `scripts/studio-ui-ux-probe-capture-deps.sh`: vulkan/nvidia-smi + `ready_for_wgpu_swapchain`
- `.github/workflows/studio-ui-ux-native.yml`: `wgpu-swapchain-readback` job

## SOTA (agentic_ai)

- [Cursor agent overview](https://cursor.com/docs/agent/overview) — honest blocked state vs silent success
- [Linear](https://linear.app/) — fast panel transitions; swapchain perf when native
- [GitHub Copilot](https://docs.github.com/en/copilot) — error recovery when GPU path unavailable

## Deferred

- Real wgpu-rs swapchain texture readback in `lig` host on org GPU runners (`studio-ux-20` proactive follow-ups)
