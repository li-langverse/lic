# PH-HW: CUDA device matmul pilot + Vulkan loader smoke

**Date:** 2026-05-29  
**Branch:** `feat/ph-ml-gpu-swarm`

## Unblocked (partial)

| WP | Change |
|----|--------|
| WP-HW-08 | `li_rt_lig_cuda_matmul2x2_device()` launches embedded PTX on GPU |
| WP-HW-09 | PTX from `runtime/kernels/lig_matmul2x2.cu` via `gen-lig-cuda-matmul-ptx.sh` |
| WP-HW-07 | `li_rt_lkir_vulkan_loader_smoke()` creates/destroys VkInstance (no compute yet) |

## Verify (NVIDIA lab)

```bash
export CUDA_HOME=/usr/lib/cuda PATH=$CUDA_HOME/bin:$PATH
./scripts/build.sh
bash scripts/lig-cuda-timing-probe.sh
LIG_EMIT_CUDA=1 ./scripts/bench-lig-gpu-suite.sh   # gpu_timing_ns: integer ns
li-tests/run_all.sh gpu
```

Mac M1: Metal path unchanged — see [metal-macos-smoke.md](../ci/metal-macos-smoke.md).
