# PH-ML Wave 2 — LKIR matmul via @gpu hook

**Branch:** `cursor/ph-ml-dl-rl-llm-wave2`  
**Depends on:** Wave 1 PR #492, lig LKIR matmul pilot PR #494

## Summary

- `ml_matmul_f32` dispatches through `lig_kernel_run` / kid=1 when `ml_use_lkir()` is enabled, then fills `c` via the CPU reference path.
- Tier-3 bench row `benchmarks/results/ph-ml-lkir-matmul.json` from `scripts/bench-ph-ml-lkir-matmul.sh` (compile + execute smoke).
- `@gpu` matmul emit stub smoke (`ml_gpu_matmul_stub.li`) — vendor CUDA/HIP/Metal emit remains deferred behind `LIG_EMIT_*`.

## Verification

```bash
./scripts/ph-ml-wave2-gates.sh
```
