# PH-HW: WP-HW-08 LKIR → CUDA dispatch (kid=1)

**Date:** 2026-05-29  
**Branch:** `feat/ph-ml-gpu-swarm`

## Stub → Real

| WP | Before | After | Verify |
|----|--------|-------|--------|
| WP-HW-08 LKIR | Device matmul without on-disk LKIR gate | **done** — `kid=1` requires valid `matmul_f32.lkir` before CUDA/HIP/Metal vendor path | `kernel_matmul_lkir_dispatch.li`, `lkir-validate.sh` |

## Behavior

- `li_rt_lig_kernel_run(1, bid=1)` validates `packages/lig/lkir/matmul_f32.lkir` (or `LIG_LKIR_MATMUL_PATH` / `LIC_ROOT`).
- When `LIG_EMIT_CUDA=1` and `CUDA_HOME` + `nvcc` probe pass, routes to `li_rt_lig_cuda_matmul2x2_device()` (honest `gpu_timing_ns` via `cuCtxSynchronize`).
- Missing/invalid LKIR → launch status `-1` (unavailable), not silent CPU ref.

## Verify

```bash
export CUDA_HOME=/usr/lib/cuda PATH=$CUDA_HOME/bin:$PATH
bash scripts/ph-ml-gpu-hw-gates.sh
bash scripts/lig-cuda-timing-probe.sh
./build/compiler/lic/lic check packages/lig/li-tests/smoke/kernel_matmul_lkir_dispatch.li
```
