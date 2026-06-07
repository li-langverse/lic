# PH-ML Stage 2 — Native DL spine

**Date:** 2026-06-04  
**Branch:** `cursor/ph-ml-stage2-dl-spine`  
**Gate:** `scripts/ph-ml-stage2-gates.sh`

## Delivered

| Phase | Deliverable |
|-------|-------------|
| **2.1** | Loop-based `ml_matmul_flat_to_nested_general` / `nested_to_flat_general` (8×8 tiles); LKIR 32×32 prologue; `lig_run_mlp_forward_f32` kid=2; HIP/MSL vendor stub bytes; `ml_gpu_mlp_lkir_progress` in device buffer pipeline |
| **2.2** | `ml_mlp_forward_f32` dispatches lig kid=2; `bench-ph-ml-mlp-competitive.sh` with `ratio_vs_li` vs NumPy 2-2-1 |
| **2.3** | Autograd RFC; `ml_autograd_*` + `ml_mlp_train_step_f32` forward-only scaffold; tier-1 `ph-ml-mlp-train-step.json` |

## Verification

```bash
export LIG_EMIT_CUDA=1
bash scripts/ph-ml-stage2-gates.sh
```

Program-complete regression remains inside the stage2 gate.
