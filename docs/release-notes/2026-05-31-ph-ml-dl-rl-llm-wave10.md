# PH-ML / DL / RL / LLM Wave 10 (2026-05-31)

## Summary

Wave 10 advances deferred PH-LLM/RL/competitive work: BPE merge pass, safetensors tensor scaffold, KV-cache decode, tier-3 LLM bench, RL IPC multiprocess label, NumPy/C++ MLP competitors, SB3 SubprocVecEnv driver, and `lillm-import` CLI scaffold.

## PH-LLM (WP-LLM-01..07)

| API | Notes |
|-----|-------|
| `li_llm_version()` | 3 — BPE merge + tensor scaffold + KV decode |
| `llm_tokenize_bpe_merge_pass` | applies merges 257-260 |
| `llm_safetensors_load_tensors_scaffold` | tensors_loaded=2 |
| `llm_transformer_matmul_contrib` | inline 1×1 (no import ml) |
| `llm_generate` | multi-step KV-cache greedy |
| `ph-ml-llm-forward.json` | tier3_cpu, 50 runs |
| `scripts/lillm-import.sh` | HF import scaffold |
| `docs/game-dev/PH-LLM-hf-export.md` | export/import doc |

## RL (WP-RL-06..07)

| API | Notes |
|-----|-------|
| `sim_rl_env_ipc_multiprocess_label()` | mode 3 IPC scaffold |
| `env_pool_stub_step_ipc_scaffold` | honest multiprocessing label |
| SB3 SubprocVecEnv | executed when gymnasium+sb3 installed |
| Ray RLlib | honest pattern stub |

## Competitive SOTA

| Driver | Notes |
|--------|-------|
| NumPy MLP | 2-2-1 f32 executed |
| C++ MLP | serial pilot |
| TensorFlow matmul | attempted via requirements |
| Triton | GPU-only skip documented |
| Rust matmul | rustc in gate or honest skip |

## Li perf

| Change | Notes |
|--------|-------|
| `ml_version()` | 6 |
| `ml_matmul_max_dim()` | 32 |
| `@vectorized(lanes=4) — max_dim 32 blocked tile gate` | nested matmul |
| `ml_matmul_blocked_tile_ok` | 8×8 tile gate |

## Deferred

- WP-LLM-06 vendor CUDA/HIP/Metal LIG_EMIT (gpu hint returns 0)
- Real OS fork/subprocess env IPC
- Full HF weight download in lillm-import
- Ray RLlib full rollout bench
- Rust MLP competitor
