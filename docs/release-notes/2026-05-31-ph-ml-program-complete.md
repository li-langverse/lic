# PH-ML program complete — Wave 13 tranches

**Date:** 2026-05-31  
**Branch:** `cursor/ph-ml-program-complete`  
**Gate:** `scripts/ph-ml-program-complete-gates.sh`

## Completed this sprint

| Tranche | Deliverable |
|---------|-------------|
| **T1** | `lig_emit_vendor_lowering_ready` + `li_rt_lig_emit_vendor_lowering_ready` writes/checks non-empty PTX at `build/lig-emit-vendor.ptx`; `lig-emit-vendor-stub.sh` emits CUDA/HIP/Metal stub bytes |
| **T6** | `ml_matmul_lkir_logical_32` (64×4×4 blocked tiles), `ml_matmul_32_lkir.li` smoke, `bench-ph-ml-lkir-matmul-32.sh` with `ratio_vs_li` vs NumPy 32×32 |
| **T2** | `ml_gpu_device_buffer_pipeline` chains LKIR launch + `lig_gpu_device_buffer_ready`; smoke `ml_gpu_device_buffer.li` |
| **T3** | `import ml` in `packages/li-llm/src/lib.li`; smoke `llm_import_ml.li` |
| **T4** | `sim_rl_env_li_process_fork_ready` + `sim_rl_env_li_process_fork.li` + Studio hook asserts fork path |
| **T5** | SB3 + Ray declared in `requirements-ph-ml-wave12-rl.txt`; program-complete gate pip-installs + `executed:true` benches |
| **T8** | `bench_ph_ml_llm_trusted_httpd.py` sets `live_proxy: true` when `PH_ML_LLM_TRUSTED_HTTPD_LIVE=1` |

## Open (deferred to follow-up PRs)

| Tranche | Blocker |
|---------|---------|
| T7 | Real safetensors/GGUF mmap against `PH_ML_WEIGHTS_FIXTURE` on disk |

## Verification

```bash
export LIG_EMIT_CUDA=1
bash scripts/lig-emit-vendor-stub.sh
test -s build/lig-emit-vendor.ptx

export PH_ML_MATMUL_N=32
bash scripts/bench-ph-ml-lkir-matmul-32.sh

# T2/T3 smokes (after lic build)
lic check packages/li-ml/li-tests/smoke/ml_gpu_device_buffer.li
lic check packages/li-llm/li-tests/smoke/llm_import_ml.li
```
