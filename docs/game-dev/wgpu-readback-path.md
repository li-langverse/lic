# Native viewport pixels (gap #2)

Phase A: `lig.kernel.present_blit_rgba8` kid=3 via `lig_present_blit_paint_summary`.

Phase B: in-tree wgpu-rs swapchain readback (`native_pixel_source=3`).

Sources: 0 none, 1 external CPU host, 2 paint blit, 3 wgpu readback.
