# PH-HW: WP-HW-08 CUDA 2×2 device matmul hardening

**Date:** 2026-05-29  
**Branch:** `feat/ph-ml-gpu-swarm`

## Stub → Real

| WP | Before | After | Verify |
|----|--------|-------|--------|
| WP-HW-08 | partial — host clock around launch only | **done** — `cuCtxSynchronize` bounds honest ns; parity + probe green | `lig-cuda-timing-probe.sh`, `kernel_matmul_parity.li` |

## Changes

- `li_rt_lig_cuda_matmul2x2_device()` times kernel completion via `cuCtxSynchronize` (not launch-only host clock).
- Device success requires positive `li_rt_lig_cuda_last_timing_ns()`; probe rejects `ns <= 0`.
- Static probe main at `runtime/lig_cuda_timing_probe_main.c` (no generated `.c` in tree).

## Verify (NVIDIA lab)

```bash
export CUDA_HOME=/usr/lib/cuda PATH=$CUDA_HOME/bin:$PATH
bash scripts/ph-ml-gpu-hw-gates.sh
bash scripts/lig-cuda-timing-probe.sh   # cuda_timing_ns: positive integer
./build/compiler/lic/lic check packages/lig/li-tests/smoke/kernel_matmul_parity.li
```

**Evidence (2026-05-29):** `lig-cuda-timing-probe.sh` → `cuda_device_ok: true`, `gpu_timing_ns` ≈ 10–20 µs on RTX lab; `ph-ml-gpu-hw-gates.sh` exit 0.

LKIR dispatch for kid=1: `lig_run_matmul_lkir_path` validates `matmul_f32.lkir` before CUDA/HIP/Metal vendor stubs (`hw-cuda-08-lkir-dispatch` completed).
