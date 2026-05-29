# CUDA / GPU smoke (WP-HW-09)

**Status:** Host probe only — no PTX timing in default CI.  
**Script:** [`scripts/detect-cuda-home.sh`](../../scripts/detect-cuda-home.sh)  
**Related:** [Lavapipe Vulkan smoke](lavapipe-vulkan-smoke.md) (WP-HW-07, SPIR-V / `bid=5`).

## Goal

Document honest CUDA readiness for `LIG_EMIT_CUDA=1` without faking `gpu_timing_ns` in bench JSON.

## Local / self-hosted GPU runner

```bash
./scripts/detect-cuda-home.sh
# Apply suggested export, then:
export LIG_EMIT_CUDA=1
./scripts/build.sh
lic check packages/lig/li-tests/smoke/kernel_matmul_parity.li
```

## CI expectations

| Runner | Job | Assert |
|--------|-----|--------|
| `ubuntu-24.04` (default) | lavapipe workflow | `nvidia_smi=absent` or `present_no_gpu`; no CUDA timing |
| `self-hosted` + NVIDIA label | future `cuda-gpu-smoke.yml` | `nvidia_smi=visible`, `CUDA_HOME` set, emit smoke only |

Wave 6 lands the **probe** in [lavapipe-vulkan-smoke.yml](../../.github/workflows/lavapipe-vulkan-smoke.yml) as an advisory step. Full timed CUDA benches stay in [benchmarks/competitive/lig-kernels.toml](../../benchmarks/competitive/lig-kernels.toml) with `cuda` = `N/A` until emit is green.

## Blockers (honest)

- PTX emit pilot (WP-HW-09) needs `CUDA_HOME` + `nvcc` on path.
- Vulkan compute dispatch (WP-HW-07) — see [lavapipe doc](lavapipe-vulkan-smoke.md).
