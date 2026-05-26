# li-ml-rl (`import ml.rl`)

**PH-ML SIM-3 (partial):** `EnvPoolStub` batches `sim_step` on a shared `SimSessionStub` — no async workers, no duplicate Gym physics.

## Honest status

| Implemented | Not implemented |
|-------------|-----------------|
| `env_pool_stub_step` → `sim_step` × `pool_size` | Real `ml.rl.EnvPool` job graph |
| Studio `sim_rl` profile hook | Live training loops, GPU batching |

## Verify

```bash
lic check packages/li-ml-rl/li-tests/smoke/env_pool_stub.li
lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
```
