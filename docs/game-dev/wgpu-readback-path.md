# Native viewport pixels — honest path (vertical gap #2)

**Phase A:** PR #288 — `native_pixel_source` 0–2, `lig.kernel.present_blit_rgba8`.  
**Phase B:** [wgpu-readback-phase-b.md](wgpu-readback-phase-b.md) — `native_pixel_source=3` stub + `LIG_WGPU_READBACK` gate.

## Pixel source taxonomy

| `native_pixel_source` | Meaning | `native_pixels` |
|----------------------|---------|-----------------|
| `0` | None / simulated compose | `0` |
| `1` | External CPU present host | `1` |
| `2` | `lig.kernel.present_blit_rgba8` (phase A) | `1` |
| `3` | wgpu-rs readback (`LIG_WGPU_READBACK=1`; stub `0` today) | `1` when readback succeeds |

## Commands

```bash
lic check packages/lig/li-tests/smoke/wgpu_readback_stub.li
```
