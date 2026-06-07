# Studio UI/UX iteration — studio-ux-21-wgpu-swapchain-gpu-runner

**UTC:** 2026-05-31T01:56:00Z  
**Branch:** `cursor/studio-ui-ux-plan-loop`  
**North star:** PH-UX viewport honesty (UX-13, UX-14) — swapchain readback on org GPU runner.

## Summary

Wired `lig.present` swapchain readback API + runtime hooks (`LIG_WGPU_SWAPCHAIN`, `LIG_GPU_RUNNER`, `LIG_HOST_PRESENT`). Bench probe compiles `lig_swapchain_bench_probe.c` for honest `swapchain_pass` / `blocked_runner`. Added CI job `wgpu-swapchain-gpu-runner`.

## Studio UI/UX iteration

- **todo:** `studio-ux-21-wgpu-swapchain-gpu-runner`
- **UX dimensions:** avg 2.79, pass — see `latest-ux-assessment.json`
- **PH-UX gates:** viewport_fps 60 ✓, panel_switch 95ms ✓, particle tiers native ✓, load_ms 0.12, memory 0.46 MiB
- **Capture:** exit 0 — [issue #182 comment](https://github.com/li-langverse/lic/issues/182#issuecomment-4585419521)
- **Bench:** load_ms 0.12, md_10k 60fps native, memory_mib 0.46, wgpu_swapchain swapchain_pass (local nvidia) / blocked_runner (CPU CI)
- **Regressions:** none vs studio-ux-23

## Agentic AI SOTA (≥3 refs)

| Ref | Pattern compared |
|-----|------------------|
| [Cursor agent](https://cursor.com/docs/agent/overview) | Honest blocked GPU path vs silent success |
| [Linear command menu](https://linear.app/docs/command-menu) | Fast panel transitions when native |
| [GitHub Copilot](https://docs.github.com/en/copilot) | Error recovery when GPU path unavailable |

## Deferred

- Real wgpu-rs texture readback (not runtime stub) on org self-hosted GPU runners
- ux-harness `world-studio-demo` non-mock RecursionError in web_gui adapter (capture used mock fallback)
