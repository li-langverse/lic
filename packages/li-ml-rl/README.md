# li-ml-rl (`import ml.rl`)

**PH-ML SIM-3 (partial):** `EnvPoolStub` + `EnvStepResult` contract (fixed `obs0..obs7`, `act0..act3`, scalar `reward`, `done`) over a shared `SimSessionStub`.

## Honest status

| Implemented | Not implemented |
|-------------|-----------------|
| `env_pool_stub_step` → `sim_step` × `pool_size` (serial) | Real `ml.rl.EnvPool` job graph |
| `env_step_contract_pre` / `env_step_contract_post` | Async parallel env workers |
| `env_obs_from_session`, `env_action_for_index` | Live training loops, GPU batching |
| `total_reward` accumulation on pool | Gymnasium env clones / vectorized IPC |

## Limits

- **One session, serial pool:** each env index runs pre/post contract around the same `SimSessionStub`; this models batched stepping, not isolated parallel worlds.
- **Terminal flag:** `done` when `session.tick >= pool_size * 8` (honest cap, not task-specific).
- **Actions:** deterministic stub actions from env index; no policy network.

## Verify

```bash
lic check packages/li-ml-rl/li-tests/smoke/env_pool_stub.li
lic check packages/li-ml-rl/li-tests/smoke/env_pool_step_contract.li
lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
```
