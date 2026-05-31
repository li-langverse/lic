# PH-ML / DL / RL / LLM Wave 6 (2026-05-31)

## Summary

Wave 6 extends matmul to 16×16 flat indexing, adds OS process env worker scaffold, PH-LLM forward bench row, and SOTA competitive benchmark registry with honest competitor columns.

## DL spine (WP-ML-11)

| API | Notes |
|-----|-------|
| `ml_matmul_max_dim()` | Returns 16 |
| `ml_matmul_flat_idx` | Flat row-major indexing for general matmul |
| `ml_matmul_cpu_ref_flat` | General m,n,k≤16 on `array[64,float]` |
| `ml_version` | Bumped to 4 |

## Parallel RL process scaffold (WP-RL-05)

| API | Notes |
|-----|-------|
| `sim_rl_env_worker_mode_process_scaffold()` | Mode 2 label |
| `env_pool_stub_step_process_pool` | Serial scaffold; real fork IPC deferred |
| `ml_rl_env_pool_process_scaffold_collect` | Smoke entry for process path |

## PH-LLM (WP-LLM-02..04)

Existing scaffolds now gated by `bench-ph-ml-llm-forward.sh` and competitive row `llm_forward`.

## Competitive benchmarks

| Artifact | Path |
|----------|------|
| Registry | `benchmarks/competitive/ph-ml.toml` |
| Harness | `scripts/bench-ph-ml-competitive.sh` |
| Results | `benchmarks/results/ph-ml-competitive.json` |

Competitors named: C++/OpenMP, Rust/rayon, NumPy BLAS, SB3 VecEnv, Ray RLlib, llama.cpp, vLLM, PyTorch transformers — competitor rows marked `executed: false` until external drivers land.

## Deferred

- Real OS subprocess/fork env workers
- Full transformer weights parse (safetensors/GGUF tensors)
- Vendor CUDA/HIP/Metal emit
- External competitor timing drivers in CI
