# Native viewport pixels (gap #2)

**Status:** Phase A shipped; **Phase B scaffold** (runtime stub + `LIG_WGPU_READBACK=1`) — in-tree wgpu-rs swapchain readback not yet wired.

Phase A: `lig.kernel.present_blit_rgba8` kid=3 via `lig_present_blit_paint_summary`.

Phase B (scaffold): `lig_present_wgpu_readback_paint_summary` / `li_rt_lig_wgpu_readback_stub` sets `native_pixel_source=3` when `LIG_WGPU_READBACK=1` and `LIG_HOST_PRESENT=1`. `lig.kernel.present_wgpu_readback` kid=4 dispatches via `li_rt_lig_kernel_run`. Studio vertical demo exit codes **54** (readback paint fail) / **55** (wrong pixel source).

Phase B (future): in-tree wgpu-rs swapchain texture readback (no env stub).

Sources: 0 none, 1 external CPU host, 2 paint blit, 3 wgpu readback.

| Env | Present path | `native_pixel_source` |
|-----|----------------|----------------------|
| `LIG_HOST_PRESENT=1` (default blit) | `lig_present_blit_paint_summary` | 2 paint blit |
| `LIG_HOST_PRESENT=1` + `LIG_WGPU_READBACK=1` | `lig_present_wgpu_readback_paint_summary` | 3 wgpu readback (stub) |

`lig_present_blit_paint_summary` delegates to the readback stub when `LIG_WGPU_READBACK=1`.
