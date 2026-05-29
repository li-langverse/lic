# PH-HW: Metal device matmul pilot (macOS M1+)

**Date:** 2026-05-29  
**Branch:** `feat/ph-ml-gpu-swarm`

## Summary

- **WP-HW-11 partial:** `lig_matmul2x2_f32` on Metal via `li_rt_lig_metal.mm` (runtime MSL compile).
- Matmul routing for `bid=3`; `LIG_EMIT_METAL=1` required (same pattern as CUDA emit).
- Mac verify: `./scripts/macos-metal-smoke.sh`

## Verify on Mac

```bash
git pull origin feat/ph-ml-gpu-swarm
./scripts/macos-metal-smoke.sh
```

Expected: `metal_device_ok: true`, bench `status: metal_device_pilot`, integer `gpu_timing_ns`.
