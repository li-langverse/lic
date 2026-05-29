# Vertical gap #2 — wgpu readback (phase A)

## Summary
Adds `native_pixel_source` and `lig.kernel.present_blit_rgba8` (runtime kid=3); studio requires paint blit before host present when `LIG_HOST_PRESENT=1`.

## Agent continuation
1. Read `docs/game-dev/wgpu-readback-path.md`
2. Run `lic check packages/lig/li-tests/smoke/present_blit_rgba8.li` and `lic check packages/li-studio/li-tests/smoke/studio_vertical_demo_env.li`
3. Then wgpu-rs readback phase B

## Changed
- `runtime/li_rt.c`, `runtime/li_rt.h`, `runtime/li_rt_lig.c`
- `packages/lig/present/lib.li`, `packages/lig/li-tests/smoke/present_blit_rgba8.li`
- `packages/li-studio/src/lib.li`

## Not changed
Full wgpu-rs readback; MP4 capture host binary.

## Breaking
N/A

## Security
N/A

## Performance
N/A

## Downstream
wgpu-rs phase B PR.
