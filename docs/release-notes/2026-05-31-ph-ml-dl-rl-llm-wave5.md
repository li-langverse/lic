# PH-ML / DL / RL / LLM Wave 5 (2026-05-31)

## Summary

Wave 5 lands real pthread parallel env reward collection and JobGraph sample queue with G-ml-async timing proof.

## Parallel RL (Priority A)

| Item | Change |
|------|--------|
| Worker mode | `sim_rl_env_worker_mode()==1` (thread pool); `ml_rl_worker_mode()` delegates |
| Parallel fill | `env_pool_fill_rewards_parallel` via `@parallel(disjoint=disjoint_elem)` + `li_parallel_for_i64` |
| Collect path | `env_pool_stub_step_thread_pool` merges scratch rewards into session |
| Bench | `"worker": "thread_pool"`, `g_ml_async_proof: true`, `uses_li_parallel_for: true` |

## JobGraph sample queue (G-ml-async)

| API | Notes |
|-----|-------|
| `sample_queue_len`, `sample_q0..q3` | Four-slot queue filled on collect |
| `ml_rl_job_graph_fill_sample_queue` | Populates queue after >=4 samples |

## DL spine

| API | Notes |
|-----|-------|
| `ml_matmul_cpu_ref` | General m,n,k<=8 on flat `array[64,float]` via `ml_matmul_flat_idx` |
| `ml_version` | Bumped to 3 |

## Smokes

```bash
lic build --allow-open-vc packages/li-ml-rl/li-tests/smoke/env_pool_thread_parallel.li
lic build --allow-open-vc packages/li-ml-rl/li-tests/smoke/job_graph_sample_queue.li
lic build --allow-open-vc packages/li-ml/li-tests/smoke/ml_matmul_general.li
```

## Deferred

- OS process (not thread) env workers
- Full transformer / safetensors tensor parse / GGUF
- Vendor CUDA/HIP/Metal emit
