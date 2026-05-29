# GPU host / device alias verification (WP-GPU-05 Partial)

**Status:** Partial — Lean `DeviceArray` disjoint laws not yet in corpus  
**Battle plan:** [PH-ML-GPU-battle-plan.md](../game-dev/PH-ML-GPU-battle-plan.md) WP-GPU-05  
**Tracker:** `partial` until `P-gpu-*` proofs land

## Intent

Reject programs where host memory aliases device-resident buffers (G-gpu § device address space).

## Current gate (compile-time)

| Case | Expected | Command |
|------|----------|---------|
| `@gpu proc` (must be `def`) | `compile_fail` | `li-tests/run_all.sh gpu` |
| `@gpu` on type alias | `compile_fail` | `gpu_decorator_type_alias_compile_fail.li` |
| `@gpu` MIR smoke (2 defs) | `verify_ok` | `lic check li-tests/gpu/gpu_decorator_mir.li` |
| Lean `P-gpu-*` | not started | [gpu-lean-p-gpu-corpus-note.md](gpu-lean-p-gpu-corpus-note.md) |

## Stub → real (WP-GPU-05)

| Stub | Real | Verify |
|------|------|--------|
| `@gpu proc` reject | Typechecker `host[T]` / `device[T]` + alias law | `gpu_host_device_alias_compile_fail.li` (future) |
| Doc-only checklist | Lean `P-gpu-*` discharge | `lake build` in G-gpu package |

## Honesty

No claim that host/device lowering is sound until proof gate is **done** in tracker.
