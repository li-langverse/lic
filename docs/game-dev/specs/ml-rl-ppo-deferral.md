# RFC: Full PPO training deferred (PH-ML Stage 3.3)

**Status:** Deferred past Stage 3  
**Stage 3 delivery:** `ml_rl_job_graph_train_step` uses `policy_loss_mean` (sample-queue reward mean) and `algorithm = reward_mean_scaffold`.

## Rationale

Native Li RL must keep competitive benches honest before adding optimizer loops:

- `async_env_collect` Li row must execute with pthread env pool (Stage 3.1).
- VecEnv competitors (SB3 SubprocVecEnv, Ray) stay optional via `PH_ML_REQUIRE_*` — not required for stage gates.

## Stage 3 train scaffold

| Field | Meaning |
|-------|---------|
| `policy_loss_mean` | Mean reward over filled sample queue (batch ≤ 4) |
| `loss_stub` | `total_reward / batch_size` (legacy ratio hook) |
| `algorithm` | `1` = reward_mean_scaffold |

## Non-goals (Stage 3)

- Policy network parameters / Adam
- GAE, clipped surrogate, value loss
- GPU rollout buffers
- Full native `ml_rl_env_pool_async_collect` session mutation on WSL until `lic` struct field stores fix (`sim_step` / `env_pool_steps_emitted`); bench uses API+linkage smoke with `worker=thread_pool` metadata

## Next stage (proposal)

1. Forward tape reuse from `ml-autograd-forward-tape-rfc.md`
2. `ml_rl_job_graph_train_step` dispatch to lig kernel or host stub for gradient accumulation
3. Tier-1 bench `ph-ml-rl-train-step.json` with `autograd_mode: ppo_scaffold`
