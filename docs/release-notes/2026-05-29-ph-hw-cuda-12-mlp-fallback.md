# PH-ML HW — WP-HW-12 MLP forward vendor fallback

**Branch:** `feat/ph-ml-gpu-swarm`  
**WP:** WP-HW-12 (`hw-cuda-12-mlp-stub`)

## Stub→Real

| Stub (before) | Real (this PR) | Verify |
|---------------|----------------|--------|
| kid=2 reused matmul CUDA device after LKIR gate | Dedicated `lig_run_mlp_forward_vendor_stub` — CPU 2→2→1 ref, status `EMIT_STUB` | `lic check packages/lig/li-tests/smoke/kernel_mlp_launch_status.li` |
| Risk of matmul `gpu_timing_ns` on MLP path | MLP never calls `li_rt_lig_cuda_matmul2x2_device()` | `bash scripts/ph-ml-gpu-hw-gates.sh` (timing probe still matmul-only) |
| Vulkan only in smoke | kid=2 + bid=5 SPIR-V validation path unchanged | `li-tests/run_all.sh gpu` |

## Behavior

- `li_rt_lig_kernel_run(kid=2, …)` validates `packages/lig/lkir/mlp_forward_f32.lkir` first.
- **CUDA / HIP / Metal:** when emit env is set, returns host status `1` (`EMIT_STUB`) after CPU pilot forward; when emit off, returns `-2` (`EMIT_OFF`).
- **Vulkan (bid=5):** SPIR-V smoke + symbol probe; no `gpu_timing_ns`.
- Embedded PTX for `lig.kernel.mlp_forward_f32` remains **blocked** in `runtime/lig-ptx-catalog.toml`.

## Verify

```bash
export CUDA_HOME=/usr/lib/cuda PATH="$CUDA_HOME/bin:$PATH"
bash scripts/ph-ml-gpu-hw-gates.sh
lic check packages/lig/li-tests/smoke/kernel_mlp_launch_status.li
# Optional: LIG_EMIT_CUDA=1 must not device-launch MLP (status 1, timing probe unchanged)
LIG_EMIT_CUDA=1 lic run -e 'extern proc li_rt_lig_kernel_run(int,int)->int; print(li_rt_lig_kernel_run(2,1))'
```
