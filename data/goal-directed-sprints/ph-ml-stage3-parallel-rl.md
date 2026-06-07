# PH-ML Stage 3 — Parallel RL

**Repos:** `lic`  
**Branch:** `cursor/ph-ml-stage3-parallel-rl`  
**Gate:** `bash scripts/ph-ml-stage3-gates.sh` (WSL + `build-wsl/compiler/lic/lic`)

## Phases

| Phase | Scope | Done when |
|-------|--------|-----------|
| **3.1** | Li `async_env_collect` competitive row `executed:true` | `bench-ph-ml-async-env-collect.sh`, workspace `li-ml-rl`, thread_pool metadata |
| **3.2** | IPC shard scaffold + CartPole-v1 stub semantics | `env_pool_ipc_prepare_shards`, `sim_rl_env_cartpole_v1_semantics` |
| **3.3** | JobGraph train beyond `loss_stub` | `policy_loss_mean` scaffold; PPO deferred in RFC |

## Status

| Phase | Status |
|-------|--------|
| 3.1 | **DONE** — workspace import + async bench + competitive Li row |
| 3.2 | **DONE** — IPC shard labels; CartPole +1/step stub; SB3/Ray remain opt-in honest |
| 3.3 | **DONE** — reward-mean train scaffold; full PPO deferred |

## Completion gate

```bash
bash scripts/ph-ml-stage3-gates.sh
```

Keeps `bash scripts/ph-ml-program-complete-gates.sh` green (invoked inside stage3 gate).

## Deferred

- Full PPO / policy-gradient backward — see `docs/game-dev/specs/ml-rl-ppo-deferral.md`
- Real OS fork IPC for env workers (Stage 3 uses shard labels + pthread fill)
- `PH_ML_REQUIRE_SB3` / `PH_ML_REQUIRE_RAY` hard CI (opt-in only)
