# PH-ML program complete — Wave 13 tranches

**Date:** 2026-05-31  
**Branch:** `cursor/ph-ml-program-complete`  
**Gate:** `scripts/ph-ml-program-complete-gates.sh`

## Completed this sprint

| Tranche | Deliverable |
|---------|-------------|
| **T1** | `lig_emit_vendor_lowering_ready` + `li_rt_lig_emit_vendor_lowering_ready` writes/checks non-empty PTX at `build/lig-emit-vendor.ptx`; `lig-emit-vendor-stub.sh` emits CUDA/HIP/Metal stub bytes |
| **T6** | `ml_matmul_lkir_logical_32` (64×4×4 blocked tiles), `ml_matmul_32_lkir.li` smoke, `bench-ph-ml-lkir-matmul-32.sh` with `ratio_vs_li` vs NumPy 32×32 |

## Open (deferred to follow-up PRs)

| Tranche | Blocker |
|---------|---------|
| T2 | `@gpu` device buffer pipeline + G-gpu proof row |
| T3 | `import ml` in li-llm (LLVM package graph) |
| T4 | Li process fork env pool + Studio hook |
| T5 | SB3/Ray hard CI `executed:true` without skip |
| T7 | Real safetensors/GGUF mmap against `PH_ML_WEIGHTS_FIXTURE` |
| T8 | Live Ollama / li-httpd proxy (`live_proxy: true`) |

## Verification

```bash
export LIG_EMIT_CUDA=1
bash scripts/lig-emit-vendor-stub.sh
test -s build/lig-emit-vendor.ptx

export PH_ML_MATMUL_N=32
bash scripts/bench-ph-ml-lkir-matmul-32.sh
```
