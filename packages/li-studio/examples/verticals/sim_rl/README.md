# Studio vertical: `sim_rl`

**Focus:** Profile chip + agent strip training-env context; **PH-ML SIM-3 partial** — `env_pool_stub_step` (4× `sim_step` per studio tick).

## Honest status

| Implemented | Not implemented |
|-------------|-----------------|
| `EnvStepResult` — `obs[8]`, `action[4]`, `reward`, `done` | Async parallel env workers |
| `env_pool_stub_step` → serial `sim_step` × `pool_size` | Live PPO / Ray training |
| Replay metadata via `sim_step` | Real `ml.rl.EnvPool` job graph |

## Verify

```bash
lic check packages/li-ml-rl/li-tests/smoke/env_pool_stub.li
lic check packages/li-ml-rl/li-tests/smoke/env_pool_step_contract.li
lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
```

## Mock

`deploy/studio-demo/archive/verticals-html-mocks/sim_rl.html`
