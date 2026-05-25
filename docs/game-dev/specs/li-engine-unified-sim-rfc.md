# RFC: Li Engine unified simulation

**Status:** Draft  
**Track:** PH-SIM  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Industry forks game engines for CARLA, GROMACS GUIs, and slicers — drift and duplicate physics.

## Proposal

One **Li Engine** core (`li-world`, `li-scene`, `li-physics-*`, `li-render`) with **runtime profiles**:

`game` | `sim_rl` | `sim_automotive` | `sim_robotics` | `sim_additive` | `sim_scientific` | `sim_drug_design`

**`li-sim`** exposes (stubs on `SimSessionStub` today; `SimWorld` later):

```li
def sim_reset(session: var SimSessionStub) -> int
def sim_step(session: var SimSessionStub, dt: float) -> int
def sim_checkpoint_tick(session: var SimSessionStub) -> int
def sim_replay_from_tick(session: var SimSessionStub, tick: int) -> int
```

Implementation: [`packages/li-sim/src/lib.li`](../../../packages/li-sim/src/lib.li) (SIM-0 profile bridge, SIM-1 tick counter, SIM-2 replay stub). Smoke: `packages/li-sim/li-tests/smoke/sim_replay_stub.li`.

**SIM-3 (partial, landed):** `packages/li-ml-rl` (`import ml.rl`) exports `EnvPoolStub` and `env_pool_step` → `sim_step` when the pool is active; `studio_sim_step_hook` routes profile `sim_rl` through `env_pool_activate` + `env_pool_step`. Evidence: `packages/li-ml-rl/li-tests/smoke/env_pool_step_stub.li`, `packages/li-studio/li-tests/smoke/studio_sim_rl_env_pool.li`. Full async multi-env pools remain future work.

## Li syntax

Use **`def`** for all new APIs. Do not document bare **`proc`**. **`extern proc`** only for FFI. Every exported `def` (and each `extern proc`) needs `requires` / `ensures` / `decreases`. The parser still accepts legacy bare `proc` in old trees only — reject that syntax in new Studio/game-dev docs and package code.

## Phases

SIM-0 (this RFC) → SIM-1 step/reset → **SIM-2 replay stub** (`sim_checkpoint_tick` / `sim_replay_from_tick`) → SIM-3 RL hookup (partial: `ml.rl.EnvPoolStub` + `sim_rl` studio route).
