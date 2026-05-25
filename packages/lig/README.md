# lig (`import lig.present`)

PH-HW **HW-1** — swapchain create and present frame contracts for World Studio viewport.

## Trusted FFI edge

| Symbol | Role |
|--------|------|
| `li_rt_lig_wgpu_swapchain_create` | wgpu/SDL surface init (host) or stub `surface_ok=0` |
| `li_rt_lig_wgpu_present_frame` | Present one frame; sets `native_pixels` when host active |
| `li_rt_lig_host_present_active` | `1` on **aarch64-apple-darwin** with `LIG_HOST_PRESENT=1`, else `0` |
| `li_rt_lig_host_present_dt_ms` | Wall-clock ms for FPS counter (not simulate-only) |
| `li_rt_lig_host_native_pixels` | `1` after successful host present |

Implementations live in `runtime/li_rt.c`. Native SDL+Metal path: `deploy/studio-demo/native/studio_shell_present_host.c`.

**Out of scope (WP3):** LKIR kernels, VRAM budgets, full wgpu-rs crate.

## Bench

`bench/wgpu_smoke.toml` — consumed by `scripts/bench-studio-viewport-perf.sh` (prefer over `packages/li-gpu/bench/wgpu_smoke.toml`).

## Smokes

```bash
lic check packages/lig/li-tests/smoke/wgpu_smoke.li
lic check packages/li-render/li-tests/smoke/viewport_fps_counter.li
```
