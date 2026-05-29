# RFC: Reverse-mode autograd for Li ML (WP-DOC-ML-04 / WP-ML-13)

**Status:** Draft — design only, no implementation  
**Date:** 2026-05-29  
**Track:** PH-ML ML-3+  
**Depends:** Dynamic `tensor[(M,N), T]` (language Phase 3, WP-ML-14)

## Summary

Li ML-2 ships **manual backward** for fixed-shape MLPs. This RFC sketches reverse-mode AD so ML-3+ can approach PyTorch ergonomics without user-authored vendor kernels.

## Goals

- Tape or trace over pure Li `def` bodies on fixed-shape tensors first.
- Preserve `requires` / `ensures` on public train APIs; device copies stay explicit (`copy_to_device`).
- No CUDA/HIP source in `.li`; gradients of device kernels use LKIR adjoint stubs (future).

## Non-goals (Wave 5)

- Full dynamic rank-N tensors.
- Second-order AD, checkpointing, or distributed autograd (see [ml-async-parallel-rfc.md](ml-async-parallel-rfc.md)).

## Proposed surface (sketch)

```li
def loss_fn(net: MlpMnist784, batch: array[784, float]) -> float
  requires ml.nn.valid_batch784(batch)
=
  ml.autograd.forward_backward(net, loss = ml.dl.mnist_ce)

def train_step(state: var TrainStateMnist, batch: array[784, float]) -> float
=
  ml.autograd.step(state.net, lr = 0.01, body = loss_fn)
```

## Blockers

| Blocker | Owner |
|---------|-------|
| `tensor[(M,N), f32]` type form | Compiler Phase 3 |
| G-gpu device alias proofs | G-gpu / Lean |
| GPU backward LKIR tiles | PH-HW WP-HW-12+ |

## Evidence to flip status

- RFC signed by PH-ML + compiler leads.
- One CPU-only autograd smoke with oracle ≤1e-4 vs manual backward (784→256→10).

**Honesty:** Until the smoke exists, do not claim autograd shipped.
