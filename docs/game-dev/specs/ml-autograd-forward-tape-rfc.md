# RFC: ML autograd forward tape (PH-ML Stage 2.3a)

**Status:** Draft scaffold (Stage 2)  
**Packages:** `li-ml`  
**Competitors:** bench scripts only (NumPy/PyTorch never in Li execution path)

## Goal

Record a minimal forward tape on native Li for matmul + MLP shapes with `m,n,k ≤ 32`, then run scalar/small backward without PyTorch.

## Tape design (v0)

| Field | Type | Notes |
|-------|------|-------|
| `op` | int | 1=matmul, 2=relu, 3=mlp_layer |
| `m,n,k` | int | matmul dims (≤8 nested tile today) |
| `slot` | int | index into fixed `array[16, TapeEntry]` |

`ml_autograd_tape_enabled()` stays `0` until v1 backward is proven under `lic check`.

## Stage 2.3b delivery

- **Stub:** `ml_autograd_matmul_backward_stub` returns `0` with `workload_class=0` (forward-only honesty).
- **Pilot:** when tape enabled, 2×2×2 backward fills `da`/`db` from `dc` (smoke-guarded).

## Bench

- Tier-1 row: `ph-ml-mlp-train-step.json` with `executed:true`, `autograd_mode: forward_only_scaffold`.

## Non-goals (Stage 2)

- GPU autograd, optimizer state, mixed precision, PyTorch interchange.
