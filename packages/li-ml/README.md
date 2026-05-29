# li-ml

Pure-Li ML stack (PH-ML **ML-0…2**): activations, fixed-shape neural nets, optimizers, training steps, and batch inference orchestration.

**Honesty:** `lic check` green means contracts and interfaces landed — not PyTorch parity or GPU speedup. See [PH-ML-GPU-battle-plan.md](../../docs/game-dev/PH-ML-GPU-battle-plan.md).

## Modules

| Import | Path | Role |
|--------|------|------|
| `ml` | `src/lib.li` | Activations, loss scalars, softmax, `lig` matmul bridge |
| `ml.nn` | `nn/lib.li` | Linear layers, MLP 4×4×2, conv acc helpers |
| `ml.optim` | `optim/lib.li` | SGD, momentum, Adam (scalar + vec4) |
| `ml.dl` | `dl/lib.li` | Train state, manual backward stub, `dl_train_step4` |
| `ml.ai` | `ai/lib.li` | Batch predict orchestration, GPU readiness probe |

## GPU boundary

- Product logic is **pure Li**; `import lig` only for `ml_lig_matmul_run_auto` / kernel id at the runtime boundary.
- No user-authored CUDA/HIP/Metal/Vulkan strings (`li-native-li-only`).

## Verify

```bash
./scripts/build.sh
lic check packages/li-ml/li-tests/smoke/*.li
```

## Traceability

| Artifact | ID |
|----------|-----|
| Package | `PKG-li-ml` |
| Battle plan | [PH-ML-GPU-battle-plan.md](../../docs/game-dev/PH-ML-GPU-battle-plan.md) |
| Tracker | [PH-ML-GPU-execution-tracker.md](../../docs/game-dev/PH-ML-GPU-execution-tracker.md) |
| Smokes | `li-tests/manifest.toml` |

## Wave 0 scope fence

- Fixed-shape arrays only (no dynamic `tensor[(M,N)]` — blocked on WP-ML-14).
- MNIST-shaped helpers are accumulation stubs, not tier-3 oracles (Wave 1).
- GPU matmul bridge returns probe status; LKIR emit blocked on WP-HW-06.
