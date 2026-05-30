# RFC: ml-async-parallel — async JobGraph for ML/RL on Li

**Status:** Draft (Wave 1 deepen)  
**Date:** 2026-05-30  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)  
**Battle plan:** [PH-ML-GPU-battle-plan.md](../PH-ML-GPU-battle-plan.md)

## Problem

Studio sim_rl and chem.ml workloads need **async sample collection** across multiple environments without blocking the main sim tick. Today SIM-3 provides session-persistent EnvPool stubs in li-sim; PH-ML Wave 3 must add worker processes and a JobGraph scheduler.

## Proposal

### JobGraph

- **JobGraph** — DAG of `SampleJob`, `TrainStep`, `EvalStep` nodes
- **EnvPoolWorker** — N worker handles referencing `SimSessionStub` clones
- **AsyncCollect** — non-blocking `env_pool_collect(batch)` returning when >=K samples ready

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

Env obs contracts proved at SIM-3 smoke level; async timing is trusted until G-ml-async lands.

## Dependencies

PH-HW-1 (lig), PH-SIM SIM-3 (env pool session fields).

## Open questions

- [ ] Process vs thread workers on Windows host
- [ ] Integration with li-studio-ai agent loop
