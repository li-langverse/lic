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

**Agent verification (2026-06-04):** run `code_implementer-1780540275403` — `bash scripts/ph-ml-program-complete-gates.sh` exit 0 (~122s) on Debian glibc 2.36 with `scripts/lib/lic-bin-select.sh` (prefers `build/compiler/lic` when runnable; falls back to `build-wsl` only when native lic is missing or not loadable).

**Agent verification (2026-06-04):** run `code_implementer-1780537415293` — `bash scripts/ph-ml-program-complete-gates.sh` exit 0 (~120s) on Linux agents with stale `build-wsl/` glibc; native `build/compiler/lic/lic` via runnable probe; `ratio_vs_li` 0.000129; `live_proxy` true; SB3/Ray `executed:true`. PR [#676](https://github.com/li-langverse/lic/pull/676) merged to `main`.

**Agent verification (2026-06-01):** latest run `code_implementer-1780280189367` — `bash scripts/run-ph-ml-program-complete-gates-wsl.sh` exit 0 (~115s); `ratio_vs_li` 0.001065; PR [#676](https://github.com/li-langverse/lic/pull/676) — all CI green, await human `merge-approved`.

**Prior run `code_implementer-1780279881936`:** `bash scripts/ph-ml-program-complete-gates.sh` exit 0 (~116s); `ratio_vs_li` 0.0044 (T6), `live_proxy` true (T8).

**Prior run `code_implementer-1780279148925`:** exit 0 (~113s); all CI green (build-and-test linux/macos/windows, studio-ui native capture).

**Prior run `code_implementer-1780278582087`:** `bash scripts/run-ph-ml-program-complete-gates-wsl.sh` exit 0 (~106s).

**Prior run `code_implementer-1780274694421`:** exit 0 (~115s); studio-ui swapchain/wgpu CI legs exit 0 locally.

**Prior run `code_implementer-1780273535258`:** exit 0 (~144s); T1–T8 unchanged; `ratio_vs_li` 0.001014.

**Prior run `code_implementer-1780272858157`:** exit 0 (~116s); T1–T8 unchanged.

**Prior run `code_implementer-1780272693434`:** `bash scripts/run-ph-ml-program-complete-gates-wsl.sh` exit 0 (~115s); bench spot-check (`ratio_vs_li` 0.000804).

**Prior run `code_implementer-1780272305121`:** exit 0 (~111s); studio-ui gate fix (`verify-wgpu-swapchain` after bench).

**Prior run `code_implementer-1780271725006`:** exit 0 (~157s); bench spot-check (`ratio_vs_li` 0.001007).
