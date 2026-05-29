# Release notes — PH-ML Wave 0 li-ml stack

**Date:** 2026-05-29  
**Branch:** `feat/ph-ml-gpu-swarm`  
**Wave:** 0 (ML-0 foundation) + Wave -1 (agent-kit bootstrap)

## Summary

Land `li-ml` and `li-ml-rl` workspace packages with pure-Li activations, MLP forward, SGD/Adam optimizers, batch inference API, and RL env pool contract smokes. Add PH-ML `.cursor` rules, skills, hooks, and execution tracker.

## Scope fence (honesty)

- **No** PyTorch/JAX parity or GPU speedup claims.
- **No** `@gpu` codegen or LKIR emit claims — G-gpu and WP-HW-06 remain blocked.
- `lic check` green = interface and contracts landed (Tier **T0**), not benchmark performance.
- MNIST-shaped helpers are fixed-size accumulation stubs until Wave 1 tier-3 oracles.

## Packages

| Package | Import | Smokes |
|---------|--------|--------|
| `li-ml` | `ml`, `ml.nn`, `ml.optim`, `ml.dl`, `ml.ai` | 6 |
| `li-ml-rl` | `ml.rl` | 3 |

## Work packages closed

WP-ML-01, WP-ML-02, WP-ML-03, WP-ML-06, WP-ML-09, WP-RL-02, WP-DOC-ML-03 (+ Wave -1 cursor bootstrap)

## Verify

```bash
./scripts/build.sh
lic check packages/li-ml/li-tests/smoke/*.li
lic check packages/li-ml-rl/li-tests/smoke/*.li
```

## Cross-links

- [PH-ML-GPU-battle-plan.md](../game-dev/PH-ML-GPU-battle-plan.md)
- [PH-ML-GPU-execution-tracker.md](../game-dev/PH-ML-GPU-execution-tracker.md)
- [packages/li-ml/README.md](../../packages/li-ml/README.md)
