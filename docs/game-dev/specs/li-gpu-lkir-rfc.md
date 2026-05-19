# RFC: li-gpu, LKIR, AMD ROCm parity (PH-HW)

**Status:** Draft  
**Track:** PH-HW  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Proposal

| Layer | Role |
|-------|------|
| **LKIR** | Li Kernel IR — tiled GPU kernels; map to CUDA, **HIP/ROCm**, Metal, SPIR-V |
| **li-gpu** | `gpu.cuda`, `gpu.rocm`, `gpu.wgpu` backends |
| **Triton interop** | Optional emit/import Triton-IR for autotune (PH-ML) |

**No CUDA-only user kernels** — use LKIR or `gpu.*` APIs.

```toml
[engine.gpu]
backend = "rocm"   # cuda | rocm | metal | webgpu
```

## ROCm

- Probe `hipcc`, `ROCM_PATH`, `gfx*` arch  
- CI smoke: HIP matmul vs CUDA reference  
- Triton-distributed patterns for multi-GPU overlap (PH-ML)

## Proof

GPU bodies trusted until Lean device calculus; host launch preconditions proved.
