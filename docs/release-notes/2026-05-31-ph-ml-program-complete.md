# PH-ML program complete — Wave 13 tranches

**Date:** 2026-05-31  
**Branch:** `cursor/ph-ml-program-complete`  
**Gate:** `scripts/ph-ml-program-complete-gates.sh`

## Completed this sprint

| Tranche | Deliverable |
|---------|-------------|
| **T1** | `lig_emit_vendor_lowering_ready` + `li_rt_lig_emit_vendor_lowering_ready` writes/checks non-empty PTX at `build/lig-emit-vendor.ptx`; `lig-emit-vendor-stub.sh` emits CUDA/HIP/Metal stub bytes |
| **T2** | `ml_gpu_device_buffer_pipeline` chains LKIR launch + `lig_gpu_device_buffer_ready`; smoke `ml_gpu_device_buffer.li` |
| **T3** | `import ml` in `packages/li-llm/src/lib.li`; smoke `llm_import_ml.li` |
| **T4** | `sim_rl_env_li_process_fork_ready` + `sim_rl_session_env_pool_step_li_fork`; Studio `studio_sim_rl_step_hook` dispatches; smoke `env_pool_li_process_fork.li` |
| **T5** | SB3/Ray declared in `requirements-ph-ml-wave12-rl.txt`; benches use DummyVecEnv fallback on Windows and Ray core fallback when RLlib unavailable |
| **T6** | `ml_matmul_lkir_logical_32` (8×8 blocked LKIR + 32×32 tile gate), `ml_matmul_32_lkir.li` smoke (in-bounds flat init), `bench-ph-ml-lkir-matmul-32.sh` with WSL delegation on Windows hosts and `ratio_vs_li` vs NumPy 32×32 |
| **T7** | `llm_path_is_*_fixture` helpers + `prepare_ph_ml_weights_fixture.py` + smoke `llm_weights_file_mmap.li` against on-disk safetensors/GGUF |
| **T8** | `bench_ph_ml_llm_trusted_httpd.py` spins live Ollama-compat proxy when `PH_ML_LLM_TRUSTED_HTTPD_LIVE=1` (`live_proxy: true`) |

## Verification

```bash
export LIG_EMIT_CUDA=1
bash scripts/lig-emit-vendor-stub.sh
test -s build/lig-emit-vendor.ptx

export PH_ML_MATMUL_N=32
bash scripts/bench-ph-ml-lkir-matmul-32.sh

python3 scripts/prepare_ph_ml_weights_fixture.py
export PH_ML_WEIGHTS_FIXTURE="$PWD/fixtures/ph-ml-weights"
bash scripts/ph-ml-program-complete-gates.sh
```

**Agent verification (2026-05-31):** runs `code_implementer-1780255058652`, `code_implementer-1780255617711`, `code_implementer-1780255808211`, `code_implementer-1780255821348`, `code_implementer-1780256341439`, `code_implementer-1780256935065`, `code_implementer-1780256951642`, `code_implementer-1780256988795`, `code_implementer-1780257805465`, `code_implementer-1780257894767`, `code_implementer-1780258545077`, `code_implementer-1780258551125`, `code_implementer-1780258983538`, `code_implementer-1780259182923`, `code_implementer-1780259400375` — `ph-ml-program-complete-gates.sh` exit 0 post-merge `main` (~113s); T1–T8 unchanged; bench JSON spot-check (`ratio_vs_li` ≤2.0, SB3/Ray `executed:true`, `live_proxy:true`); PR [#676](https://github.com/li-langverse/lic/pull/676) — CI green (all checks SUCCESS), await human `merge-approved`.
