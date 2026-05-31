# PH-ML / DL / RL / LLM Wave 4 (2026-05-30)

## Summary

Wave 4 closes the parallel RL honesty gap and extends the DL CPU spine beyond 1×1×3 smoke matmul.

## Parallel RL (Priority A)

| Item | Change |
|------|--------|
| Persistent EnvPool | `ml_rl_job_graph_collect` uses `sim_session_env_pool_*` on the live session |
| SampleJob | `graph.last_sample` populated after collect |
| TrainStep / EvalStep | `TrainStepJob`, `EvalStepJob`, dispatch defs on JobGraph |
| Workers | Sync sequential env stepping; bench JSON `"worker": "sync"`, `worker_count`, `cpu_sec` |

**Parallelism model:** env collection is **sync** (one session, sequential env slots). Matmul inner loops use **`@vectorized(lanes=4)`** SIMD on one core. OS process / thread pool workers deferred.

## DL spine (Priority B)

| API | Notes |
|-----|-------|
| `ml_matmul_cpu_ref` | General m,n,k ≤ 8 in `array[64,float]` |
| `ml_mlp_forward_f32` | 2-layer ReLU MLP; probes `lig.kernel.mlp_forward_f32` kid=2 |
| `ml_lig_matmul_run_auto` | Fixes WP-LLM-05 bridge for `llm_forward_matmul_cpu_hint` |

## Smokes

```bash
lic check --allow-open-vc packages/li-ml/li-tests/smoke/ml_matmul_general.li
lic check --allow-open-vc packages/li-ml/li-tests/smoke/ml_mlp_forward.li
lic check --allow-open-vc packages/li-ml-rl/li-tests/smoke/job_graph_train_eval.li
```

## Benches

- `scripts/bench-ph-ml-async-env-collect.sh` — honest sync worker metadata
- `scripts/bench-ph-ml-mlp-forward.sh` — tier-3 MLP row with `executed: true`

## Deferred

- OS process env worker pool
- Full transformer / safetensors / GGUF
- Vendor CUDA/HIP/Metal emit