# PH-ML / DL / RL / LLM Wave 13 — program complete (2026-05-31)

## Summary

Closes all Wave 12 deferred tranches **T1–T8**: vendor LIG emit artifacts, `@gpu` device buffer pipeline, `import ml` in li-llm, in-process Li fork env pool + Studio hook, SB3/Ray hard CI deps, 32×32 matmul competitive row, real safetensors/GGUF mmap from fixture weights, and live li-httpd proxy bench row.

## Tranches

| ID | Deliverable | Verification |
|----|-------------|--------------|
| T1 | `lig_emit_vendor_lowering_ready` + PTX/HS/MSL stub bytes | `lig-emit-vendor-stub.sh` |
| T2 | `ml_gpu_device_buffer_pipeline` + smoke | `ml_gpu_device_buffer.li` |
| T3 | `import ml` + `llm_ml_import_bridge` | `llm_import_ml.li` |
| T4 | `sim_rl_env_li_process_fork_ready` + Studio hook | `studio_sim_rl_step_hook` |
| T5 | SB3 + Ray declared + `executed:true` benches | `requirements-ph-ml-wave12-rl.txt` |
| T6 | 32×32 matmul competitive ratio ≤ 2.0 | `bench-ph-ml-lkir-matmul-32.sh` |
| T7 | safetensors/GGUF mmap from fixture dir | `llm_weights_file_mmap.li` |
| T8 | trusted httpd bench with `live_proxy: true` | `bench_ph_ml_llm_trusted_httpd.py` |

## Gate

```bash
bash scripts/ph-ml-program-complete-gates.sh
```
