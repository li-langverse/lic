# PH-ML / DL / RL / LLM Wave 9 (2026-05-31)

## Summary

Wave 9 recovers Wave 7 PH-LLM scaffold onto main post-Wave 8, extends competitive drivers (C++/OpenMP + Rust), improves native matmul perf, and lands honest process-worker mode 2 label.

## PH-LLM (WP-LLM-01..05)

| API | Notes |
|-----|-------|
| `li_llm_version()` | 2 — BPE + safetensors header + matmul forward |
| `llm_tokenizer_mode_bpe_scaffold` | `fixtures/vocab.bpe.json` merge scaffold |
| `llm_safetensors_parse_header` | header_len=64, tensor_count=2 |
| `llm_transformer_matmul_contrib` | 1×1 `ml_matmul_f32` in `llm_forward` |
| `llm_generate` | greedy decode smoke |
| `ph-ml-llm-forward.json` | `validity_gate_pass: true` when lic built |

## Competitive SOTA (Priority B)

| Driver | Notes |
|--------|-------|
| `bench_ph_ml_competitor_cpp_openmp_matmul.py` | 4×4 f32 OpenMP when g++/clang++ available |
| `bench_ph_ml_competitor_rust_ndarray_matmul.py` | 4×4 f32 rustc pilot |
| TensorFlow | attempted via requirements; honest executed:false if install fails |

## RL process workers (Priority C)

| API | Notes |
|-----|-------|
| `sim_rl_env_worker_process_mode_label()` | mode 2 label |
| `env_pool_stub_step_process_pool` | thread-pool fill under mode 2 until fork IPC |

## Li perf (Priority D)

| Change | Notes |
|--------|-------|
| `ml_version()` | 5 |
| `ml_matmul_max_dim()` | 32 |
| `@vectorized(lanes=8)` | nested matmul |

## Deferred

- WP-LLM-06 vendor CUDA/HIP/Metal LIG_EMIT
- Full safetensors tensor byte load
- WP-LLM-07 HF CLI, WP-LLM-08 optional backend
- Real OS fork/subprocess env IPC
- SB3 SubprocVecEnv full bench
