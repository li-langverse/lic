# PH-ML / DL / RL / LLM Wave 7 (2026-05-31)

## Summary

Wave 7 advances PH-LLM Wave 1 (tokenizer, safetensors header, transformer scaffold), lands one honest NumPy competitive driver, and documents deferred OS process env workers.

## PH-LLM (WP-LLM-01..03)

| API | Notes |
|-----|-------|
| `li_llm_version()` | Bumped to 2 |
| `llm_tokenizer_mode_*` + BPE merge scaffold | `fixtures/vocab.bpe.json` enables merges th/he/ll/lo |
| `llm_safetensors_parse_header` | Fixture header len=64, tensor_count=2, tensors_loaded=0 |
| `llm_transformer_matmul_contrib` | 1×1 `ml_matmul_f32` layer stub in `llm_forward` |
| Smokes | `llm_tokenize_bpe.li`, `llm_safetensors_header.li`, updated forward/load |

## Competitive SOTA (Priority B)

| Artifact | Notes |
|----------|-------|
| `scripts/bench-ph-ml-competitor-numpy-matmul.sh` | Real NumPy 4×4 matmul timing when numpy installed |
| `ph-ml-competitive.json` | `python_numpy.executed: true` with honest `cpu_sec` |

## RL process workers (Priority C — deferred)

| API | Notes |
|-----|-------|
| `sim_rl_env_worker_process_mode_label()` | Mode 2 serial scaffold label |
| `env_pool_stub_step_process_pool` | Still serial; fork IPC deferred |

## Deferred

- Real OS subprocess/fork env workers
- Full safetensors/GGUF tensor bytes load
- Remaining competitive drivers (C++/OpenMP, SB3, llama.cpp, …)
- GPU vendor emit
