# RFC: ml-async-parallel — async JobGraph for ML/RL on Li

**Status:** Draft (Wave 1 deepen)  
**Date:** 2026-05-30  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)  
**Battle plan:** [PH-ML-GPU-battle-plan.md](../PH-ML-GPU-battle-plan.md)

## Problem

Studio sim_rl and chem.ml workloads need **async sample collection** across multiple environments without blocking the main sim tick. Today SIM-3 provides session-persistent EnvPool stubs in li-sim; PH-ML Wave 3 must add worker processes and a JobGraph scheduler.

## Proposal

### JobGraph (Wave 3 — implemented in li-ml-rl)

| Symbol | Kind | Role |
|--------|------|------|
| `SampleJob` | type | One env transition: `env_index`, `sample_id`, `reward`, `done` |
| `JobGraphStub` | type | DAG scaffold: `pool_size`, `job_count`, `samples_collected`, `total_reward`, `async_workers` |
| `job_graph_stub_default()` | def | Default graph with `pool_size == async_workers == 4` |
| `ml_rl_job_graph_collect(session, dt, graph)` | def | Run EnvPool step across >=4 env slots; fill graph counters |
| `ml_rl_env_pool_async_collect(session, dt)` | def | Convenience wrapper; returns `sim_status_ok()` when >=4 samples |
| `ml_rl_async_env_count()` | def | Honest parallel env handle count (currently `sim_rl_env_pool_size_default() == 4`) |

Wave 4 adds `TrainStepJob` / `EvalStepJob` dispatch, session-persistent EnvPool in `ml_rl_job_graph_collect`, and `SampleJob` fill on collect. Worker model is **sync** (`ml_rl_worker_mode()==0`); bench JSON uses `"worker": "sync"` (not `"stub"`). Wave 5 adds pthread thread-pool reward fill (env_pool_fill_rewards_parallel) and JobGraph sample queue; OS process pool workers remain deferred.

### Packages

| Package | Role |
|---------|------|
| li-ml | Tensor ops, matmul spine |
| li-ml-rl | EnvPool re-export (Wave 1), JobGraph (Wave 3) |
| li-sim | Session tick + obs contract |

### Phases

1. Wave 1 — CPU matmul + li-ml-rl scaffold (this sprint)
2. Wave 2 — LKIR GPU matmul via lig
3. Wave 3 — JobGraph + >=4 async envs in bench

## Li syntax

Use **def** for all new APIs. Every exported def needs requires/ensures/decreases.

## Proof / trust

Env obs contracts proved at SIM-3 smoke level; Wave 5 bench records g_ml_async_proof when thread-pool collect smoke passes.

## Dependencies

PH-HW-1 (lig), PH-SIM SIM-3 (env pool session fields).

## Open questions

- [ ] Process vs thread workers on Windows host
- [ ] Integration with li-studio-ai agent loop
