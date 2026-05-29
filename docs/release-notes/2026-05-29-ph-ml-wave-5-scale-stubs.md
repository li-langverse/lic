# Release notes: 2026-05-29 — PH-ML Wave 5 scale stubs and RFCs

**Status:** Ready for review  
**Branch:** `feat/ph-ml-gpu-swarm`  
**PR:** [#367](https://github.com/li-langverse/lic/pull/367)

## Summary

Wave 5 lands design-only artifacts for autograd, async RL env pools, ResNet18 tier-4 bench stub, multi-GPU scheduler sketch, and documented blockers for dynamic `tensor` / autograd — no implementation claims.

## Deliverables

| WP | Artifact |
|----|----------|
| WP-DOC-ML-04 | `docs/game-dev/specs/ml-autograd-rfc.md` |
| WP-RL-04 | `docs/game-dev/specs/ml-rl-async-env-pool.md` + `async_env_pool_tick_stub` |
| WP-BENCH-ML-07 | `benchmarks/competitive/resnet18_infer.toml` (stub, no perf) |
| WP-HW-14 | Multi-GPU section in `lig-rfc.md` |
| WP-ML-13/14 | Blockers recorded in execution tracker |

## Honesty

Do not claim autograd, rank-N `tensor`, async RL throughput, ResNet18 parity, or multi-GPU overlap until respective proof gates green.
