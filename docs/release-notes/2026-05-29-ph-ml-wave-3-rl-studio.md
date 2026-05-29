# PH-ML Wave 3 — persistent RL pool + Studio sim_rl

**Date:** 2026-05-29  
**Branch:** `feat/ph-ml-gpu-swarm`

## Summary

Wave 3 adds `EnvPoolPersistent`, `rl_policy_forward`, `rl_train_tick` in `li-ml-rl`; `SimSessionStub.rl_persistent_*` + `sim_rl_tick_session` in `li-sim`; Studio `sim_rl` profile calls `sim_rl_tick_session` on the live session; fills [ml-async-parallel-rfc.md](../game-dev/specs/ml-async-parallel-rfc.md) (four axes).

## Verify

```bash
./scripts/build.sh
build/compiler/lic/lic check --no-cache packages/li-ml-rl/li-tests/smoke/env_pool_persistent.li
build/compiler/lic/lic check --no-cache packages/li-ml-rl/li-tests/smoke/policy_forward.li
build/compiler/lic/lic check --no-cache packages/li-sim/li-tests/smoke/env_pool_stub.li
build/compiler/lic/lic check --no-cache packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
```

## Not in this wave

- True async env workers (axis 1 serial loop only)
- GPU policy forward on device
