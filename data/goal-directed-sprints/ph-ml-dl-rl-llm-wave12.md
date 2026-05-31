# PH-ML / DL / RL / LLM Wave 12 — final deferred sprint

Base: `main` @ Wave 11 merge (PR #673, ~a9441d8e).

## Implemented

- `LIG_EMIT_*` vendor emit progress (`lig_emit_vendor_progress`, `lig-emit-vendor-stub.sh`)
- `@gpu` → `ml_gpu_lkir_launch_pipeline` + `ml_gpu_lkir_launch.li` smoke
- Safetensors 64 B/tensor mmap chunk loader (`llm_safetensors_tensor_bytes_mmap`)
- `llm_gpu_lkir_matmul_progress` via `li_rt_lig_matmul_ready` when LIG valid
- `llm_trusted_backend_li_httpd_*` + `bench_ph_ml_llm_trusted_httpd.py`
- RL fork IPC bench (spawn; fork on Linux when available)
- SB3/gymnasium gate install + executed check when present
- Ray RLlib 2-iteration rollout when `ray`+RLlib installed
- 16×16 blocked CPU matmul + logical LKIR row uses 16×16
- Wave 12 gates: `ph-ml-wave12-gates.sh`

## Deferred (honest)

- Real PTX/HS/MSL vendor codegen (env progress only)
- `import ml` in li-llm (LLVM package graph blocker)
- Li runtime fork(2) from Li process (Python multiprocessing only)
- Triton CUDA kernel on CI without GPU (documented skip)
- Full HF weight tensor map / real mmap syscall

## Gate

`./scripts/ph-ml-wave12-gates.sh` (runs Wave 11 + Wave 12 smokes; `LIG_EMIT_CUDA=1` for GPU launch smoke)
