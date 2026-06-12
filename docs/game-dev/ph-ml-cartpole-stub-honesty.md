# PH-ML CartPole env semantics (honest labels)

**Phase M** (`ph-ml-training-toy-sota`) — RL competitive rows must not imply Gym physics when Li uses a stub.

## What Li runs today

| Field | Value | Meaning |
|-------|-------|---------|
| `env_semantics` | `cartpole_v1_reward_shard_stub_x4` | Four pthread workers; per-env fixed reward shards, **not** CartPole-v1 dynamics |
| `sim_rl_env_cartpole_v1_semantics()` | returns `1` | Routes `env_reward_for_action` to `env_cartpole_step_reward` — **naming legacy**, not OpenAI Gym |
| SB3 `async_env_collect` competitor | `CartPole-v1` via VecEnv | **Real** Gymnasium physics |

## Why comparisons are not apples-to-apples

- **Li** (`packages/li-ml-rl`, `packages/li-sim`): `env_pool_async_four.li` collects rewards from `env_cartpole_step_reward(env_index)` — deterministic shard penalties, no pole/cart state integration.
- **SB3** (`bench_ph_ml_competitor_sb3_vecenv.py`): `gym.make("CartPole-v1")` with random actions — full episode physics.

Li may appear faster on `async_env_collect` because the workload is lighter, not because Li RL env stepping beats SB3.

## Phase M minimum (this doc + JSON labels)

Real CartPole integration (state `(x, x_dot, theta, theta_dot)`, force actions, termination) is **future work** in `li-sim`. Until then:

1. Competitive JSON declares `env_semantics: cartpole_v1_reward_shard_stub_x4`.
2. `semantics_honesty_note` on async collect rows points here.
3. `sb3_train_step` bench row records SB3 `PPO.learn()` when deps exist; `executed: false` when not.

## SB3 train-step row (`sb3_train_step`)

| Field | When deps missing | When SB3+gymnasium installed |
|-------|-------------------|------------------------------|
| `executed` | `false` | `true` |
| `workload` | `sb3_ppo_cartpole_train_1epoch` | same |
| `note` | `stable_baselines3/gymnasium not installed` | `PPO.learn(total_timesteps=N) CartPole-v1` |

Li has **no** native policy-training loop on real CartPole yet; the `sb3_train_step` row is competitor-only honesty scaffolding.
