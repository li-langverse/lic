# PH-ML / DL / RL / LLM Wave 11 — Carryover sprint

Base: `main` @ Wave 10 merge (PR #669, ~7073daf0).

## Implemented

- WP-LLM-06: `@gpu` + `ml_gpu_matmul_lkir_progress` / `llm_gpu_lkir_matmul_progress`
- WP-LLM-07: `lillm-import.sh` HF download or `LILLM_IMPORT_OFFLINE=1`
- WP-LLM-08: trusted backend Ollama scaffold smokes
- Safetensors byte tensor scaffold (`tensor_bytes_read`, 8 bytes/tensor)
- `llm_matmul_indirect_bridge` (no `import ml` in li-llm)
- 16×16 logical LKIR matmul (`ml_matmul_lkir_logical_16`) + bench JSON
- RL fork IPC label + spawn pool driver
- Rust MLP competitor driver
- Triton row kernel fix (scalar acc)
- Ray RLlib honest partial train when installed

## Deferred (documented)

- Vendor CUDA/HIP/Metal `LIG_EMIT_*` codegen
- Full safetensors mmap loader
- Real in-process OS fork from Li runtime
- Ray full rollout bench at scale

## Gate

`./scripts/ph-ml-wave11-gates.sh` (runs Wave 10 gates + Wave 11 smokes)
