# PH-HW WP-HW-09: embedded PTX catalog + cuda-home-probe

**Date:** 2026-05-29  
**Branch:** `feat/ph-ml-gpu-swarm`

## Stub → Real

| Surface | Before | After |
|---------|--------|-------|
| PTX dispatch | Hard-coded `k_lig_matmul2x2_ptx` in `li_rt_lig_cuda.c` | `lig_cuda_ptx_catalog.c` lookup by symbol |
| Manifest | implicit | `runtime/lig-ptx-catalog.toml` + `check-lig-ptx-catalog.sh` |
| cuda-home-probe | `wp_hw_09` string only | `embedded_ptx_*`, `ready_emit_cpu_ref`, `device_timing_in_this_probe: false` |
| Blocked kernels | undocumented | `[[blocked]]` rows in manifest + `lig-cuda-ptx-catalog.md` |

## Verify

```bash
export CUDA_HOME=/usr/lib/cuda PATH=$CUDA_HOME/bin:$PATH
bash scripts/check-lig-ptx-catalog.sh
bash scripts/cuda-home-probe.sh
bash scripts/lig-cuda-timing-probe.sh
bash scripts/ph-ml-gpu-hw-gates.sh
```

Device timing remains **only** in `lig-cuda-timing-probe.sh` (positive ns after `cuCtxSynchronize`).
