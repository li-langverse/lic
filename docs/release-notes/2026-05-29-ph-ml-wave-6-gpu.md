# PH-ML Wave 6 — MLP LKIR dispatch + Vulkan compute symbols

**Branch:** `feat/ph-ml-gpu-swarm`  
**WPs:** WP-HW-07 (partial), WP-HW-12 (partial), WP-GPU-06 (partial)

## Changes

| WP | Deliverable |
|----|-------------|
| WP-HW-12 | `li_rt_lig_kernel_run` kid=2 validates `mlp_forward_f32.lkir` before vendor/Vulkan stub path |
| WP-HW-07 | `li_rt_lkir_vulkan_compute_symbols_ok()` — dlopen resolves compute entry points (no pipeline dispatch) |
| WP-GPU-06 | `MirFn.gpu_kernel_id`; `@gpu` defs with `mlp` in name emit `kid=2` prologue |

## Verify

```bash
./scripts/build.sh
li-tests/run_all.sh gpu
bash scripts/lkir-validate.sh
lic check packages/lig/li-tests/smoke/kernel_mlp_launch_status.li
```

## Honesty

- No `gpu_timing_ns` from Vulkan path
- Full `vkCreateComputePipelines` dispatch remains **blocked** (see [lavapipe-vulkan-smoke.md](../ci/lavapipe-vulkan-smoke.md))
