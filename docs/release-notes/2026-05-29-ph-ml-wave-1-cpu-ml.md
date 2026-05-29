# Release notes: 2026-05-29 — PH-ML Wave 1 CPU ML

**Branch:** `feat/ph-ml-gpu-swarm`  
**Scope:** ML-1 + ML-2 (Wave 1 gate)

## Summary

Wave 1 lands **real** pure-Li CPU forward and train-step kernels for the PH-ML stack — no fake benchmark loops, no GPU or PyTorch parity claims.

## Delivered

| WP | Status | Evidence |
|----|--------|----------|
| WP-ML-04 | done | `nn_mlp_mnist_forward` — 784→256→10 loops with trainable `w1_scale` + `w2` |
| WP-ML-05 | done | `nn_conv2d3x3_forward` — naive 3×3 on 4×4→2×2 |
| WP-ML-07 | done | `dl_mlp4_backward_apply` — weight + bias SGD (not bias-only) |
| WP-ML-08 | done | `dl_mnist_train_step` + smoke `mnist_train_step.li` |
| WP-BENCH-ML-01 | done | tier1 `ml_mlp_*` / `ml_conv2d_forward` call real `ml.nn` / `ml.dl` |
| WP-BENCH-ML-02 | partial | `benchmarks/tier3_ml/mlp_forward/` + NumPy oracle script |
| WP-BENCH-ML-03 | done | tier1 `ml_mlp_train_step` uses `dl_mnist_train_step` |
| WP-BENCH-ML-04 | partial | `benchmarks/harness/pytorch_cpu_mlp.py` — honest `N/A` without torch |

## Verify

```bash
./scripts/build.sh
lic check --no-cache packages/li-ml/li-tests/smoke/*.li
python3 benchmarks/tier3_ml/mlp_forward/oracle_mlp_forward.py
```

## Honesty fence

- **No** PyTorch/JAX parity or GPU speedup claims — Tier-3 timing CSV ingest pending.
- MNIST weights use deterministic base LUT + `w1_scale` (rank-1 modulator) until dynamic `tensor` (WP-ML-14).
- Loss-decrease smoke uses fixed fixture + manual backward; not full MNIST epoch accuracy.

## Cross-links

- [PH-ML-GPU-battle-plan.md](../game-dev/PH-ML-GPU-battle-plan.md) § Wave 1
- [PH-ML-GPU-execution-tracker.md](../game-dev/PH-ML-GPU-execution-tracker.md)
