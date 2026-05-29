---
workflow_repo: lic
branch: feat/ph-ml-gpu-swarm
gates: bash scripts/ph-ml-gpu-hw-gates.sh
agent: code_implementer
platform: linux-nvidia-cuda
---

# PH-ML GPU hardware sprint — CUDA (Linux NVIDIA)

**Branch:** `feat/ph-ml-gpu-swarm`  
**Host:** Linux + NVIDIA (RTX); `CUDA_HOME=/usr/lib/cuda`  
**Tracker:** `docs/game-dev/PH-ML-GPU-execution-tracker.md`  
**Rules:** `ph-ml-stub-then-implement.mdc`, `ph-ml-gpu-honesty.mdc`

Do **not** claim Mac Metal timing from this host. M1 work is documented only.

todos:

- id: hw-cuda-08-device-matmul
  content: "WP-HW-08: Harden 2x2 CUDA device matmul — lig-cuda-timing-probe honest ns; kernel_matmul_parity.li green"
  status: completed

- id: hw-cuda-08-lkir-dispatch
  content: "WP-HW-08: Route lig kernel kid=1 through CUDA device when LIG_EMIT_CUDA=1 and cuda probe passes"
  status: completed

- id: hw-cuda-09-ptx-catalog
  content: "WP-HW-09: Extend embedded PTX path or document blocked; cuda-home-probe ready_emit_cpu_ref + device timing only if real"
  status: pending

- id: hw-cuda-12-mlp-stub
  content: "WP-HW-12: kid=2 mlp_forward CUDA/Vulkan fallback after LKIR file gate — no fake gpu_timing_ns"
  status: pending

- id: hw-cuda-bench-tracker
  content: "Refresh benchmarks/results/lig-gpu-suite-honest.json; tracker WP-HW-08/09 partial→done only with verify evidence"
  status: pending

---

## Verify (every iteration)

```bash
export CUDA_HOME=/usr/lib/cuda PATH="$CUDA_HOME/bin:$PATH"
bash scripts/ph-ml-gpu-hw-gates.sh
```

## Honesty

- `gpu_timing_ns` only from `li_rt_lig_cuda_last_timing_ns()` after successful device launch
- Stubs must move to **partial** or **done** with release-note Stub→Real table in same branch
