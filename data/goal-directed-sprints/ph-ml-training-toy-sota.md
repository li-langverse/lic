# PH-ML training toy + SOTA benchmarks sprint

**Sprint ID:** `ph-ml-training-toy-sota`  
**Repos:** `lic` (primary), `benchmarks` (competitive rows)  
**Branch:** `cursor/ph-ml-training-toy-sota` → `main`  
**Runner:** goal-directed SDK `code_implementer` (`LI_SWARM_EXTERNAL=1`, `--max 0` until gate passes)  
**Gate:** `bash scripts/ph-ml-training-toy-sota-gates.sh`  
**Prior sprint:** `data/goal-directed-sprints/ph-ml-li-array-perf-ij.md` (Phase I/J **DONE**)  
**Perf snapshot:** `docs/game-dev/PH-ML-PERFORMANCE-SNAPSHOT.md`

## Audit context

Inference and pilot backward exist (`ml_mlp_train_step_f32` with full MLP backward). **No multi-step training loop**, **no competitive training row**, and **no SOTA training benchmarks** on real Li runtime gradients yet.

## Goal

Ship honest toy-dataset training loops and competitive training benchmarks (Li native SGD vs PyTorch CPU on the same fixture).

## Status

| Phase | Status |
|-------|--------|
| **K** | **DONE** — `ml_mlp_sgd_step_f32`, XOR smoke, gate |
| **L** | **DONE** — `mlp_train` competitive row + `bench_ph_ml_mlp_train_competitive.py` |
| **M** | **DONE** — CartPole stub honesty doc + `sb3_train_step` bench scaffold |
| **N** | pending |

## Phases

| Phase | Scope | Done when |
|-------|-------|-----------|
| **K** | Multi-step MLP training on synthetic XOR 2-2-1 — SGD weight update (`lr * dw`), gate asserts loss decreases over 10 steps | `ml_mlp_xor_sgd.li` exit 0; `ph-ml-training-toy-sota-gates.sh` exit 0 |
| **L** | Competitive training row `mlp_train` in `ph-ml.toml` + bench script comparing Li vs PyTorch CPU on same fixture (real Li runtime gradients, not env vars) | `ph-ml-competitive.json` row `mlp_train` with `executed:true` |
| **M** | Toy RL — wire real CartPole semantics or document honest stub; optional SB3 train-step bench (1 epoch) if feasible | RL row semantics honest; optional `sb3_train_step` bench |
| **N** | Refresh `ph-ml-competitive.json` training rows + `PH-ML-PERFORMANCE-SNAPSHOT.md` | Snapshot training table updated; gate green |

### Phase K (minimum — this session)

Deliverables:

- `ml_mlp_sgd_step_f32` — forward + MSE backward + `w -= lr * dw`
- `packages/li-ml/li-tests/smoke/ml_mlp_xor_sgd.li` — 10 SGD steps on XOR (1,1)→0; loss decreases
- `scripts/ph-ml-training-toy-sota-gates.sh`

Exit criteria:

- [x] `ml_mlp_sgd_step_f32` in `packages/li-ml/src/lib.li`
- [x] XOR smoke builds and runs with exit 0
- [x] Gate script passes

### Phase L

- Add `mlp_train` row to `benchmarks/workloads/competitive/ph-ml.toml`
- `scripts/bench-ph-ml-mlp-train-competitive.sh` — Li `ml_mlp_sgd_step_f32` loop vs PyTorch SGD on same weights/fixture
- Record `cpu_sec` per framework; no `PH_ML_LI_DW*` env-var gradient injection

### Phase M

- [x] `docs/game-dev/ph-ml-cartpole-stub-honesty.md` — explicit reward-shard stub vs real Gym labels
- [x] `env_semantics: cartpole_v1_reward_shard_stub_x4` on async collect JSON
- [x] `sb3_train_step` row in `ph-ml.toml` + `bench_ph_ml_competitor_sb3_train_step.py` (honest `executed:false` when deps missing)

### Phase N

- Regenerate `benchmarks/results/ph-ml-competitive.json` training section
- Update `docs/game-dev/PH-ML-PERFORMANCE-SNAPSHOT.md` training honesty table

## Agent rules

- One PR per phase when possible; merge to `main` when CI green.
- Do not weaken gates to exit 0 without real Li-native gradient + weight update.
- Training benches must use runtime autograd (`ml_mlp_sgd_step_f32`), not env-injected `dw`.

## Completion gate

```bash
bash scripts/ph-ml-training-toy-sota-gates.sh
```

Phases L–N extend the gate incrementally (competitive row, RL honesty, snapshot refresh).
