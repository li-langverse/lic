# Studio UI/UX iteration — `studio-ux-17-gpu-fail-recovery`

- **Branch:** `cursor/studio-ui-ux-plan-loop`
- **Capture:** issue #182 (post-push)
- **Release:** `studio-ui-ux-progress`

## Shipped

- `li-ui` — `StudioGpuFailCompose`, `studio_compose_gpu_fail`, `paint_studio_gpu_fail` (viewport overlay strip + retry btn)
- `li-studio` — `studio_compose_shell_gpu_fail`, `studio_paint_gpu_fail_overlay`, shell wiring
- `li-gpu` — `gpu_wgpu_smoke_fail_run()` for fail-state bench hooks
- `packages/li-studio/bench/gpu_fail_recovery.toml` — retry 15ms (budget 100ms)
- Smokes: `studio_gpu_fail_recovery.li` (li-ui + li-studio)
- HTML mock: `04-studio-gpu-fail.html` (journey `gpu_fail_recovery`)

## PH-UX gates

| Gate | Target | Measured | Pass |
|------|--------|----------|------|
| gpu_fail_retry_ms | 100 | 15 | yes |
| panel_switch_ms | 100 | 95 | yes |
| viewport_fps | 60 | 60 | yes |
| palette_open_ms | 50 | 12 | yes |

## UX-08 SOTA (agentic_ai)

- Cursor — actionable error strip + retry without raw stack in chrome
- Linear — fast recovery affordance on blocked operations
- GitHub Copilot — inline failure message + dismiss/retry pattern

## Regressions

none vs studio-ux-16 (UX-08 improved 2.0 → 2.8)
