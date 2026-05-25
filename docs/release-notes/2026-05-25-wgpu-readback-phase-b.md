# wgpu readback phase B scaffold (vertical gap #2)

## Summary

Scaffolds `native_pixel_source=3` with `LIG_WGPU_READBACK=0` and `li_rt_lig_wgpu_readback_rgba8` stub (returns `0`). Full wgpu-rs readback **N/A** this session.

## Agent continuation

1. **Read:** `docs/game-dev/wgpu-readback-phase-b.md`, `runtime/li_rt.c`, `packages/lig/present/lib.li`.
2. **Run:** `lic check packages/lig/li-tests/smoke/wgpu_readback_stub.li`.
3. **Then:** phase B+1 — in-tree `wgpu` crate + swapchain readback after #288 merges.
4. **Blocked on:** wgpu-rs dependency policy and SDL FFI.

## Changed

- `runtime/li_rt.c`, `runtime/li_rt.h` — gate + stub
- `packages/lig/present/lib.li` — `lig_present_wgpu_readback_rgba8`
- `packages/lig/li-tests/smoke/wgpu_readback_stub.li`
- `docs/game-dev/wgpu-readback-phase-b.md`, `wgpu-readback-path.md`

## Not changed

- Full wgpu-rs readback; phase A `present_blit_rgba8` (PR #288); verticals MP4 binary; SDL demo window.

## Breaking / Security / Performance

N/A — additive; no new attack surface; O(1) env check.

## Downstream

studio/li-render: call readback after #288 + wgpu crate.
