# PH-ML Stage 8 — production HPC AI library

**Branch:** `cursor/ph-ml-stage8-production`  
**Gate:** `scripts/ph-ml-stage8-gates.sh`  
**Baseline:** Stage 7 @ `ac42e256` (PR #859 merged)

## Goal

Close remaining production gaps: native Li inference SSE upstream for li-httpd, full MLP backward with PyTorch parity, honest GPU KV device-buffer progress, LLM competitor drivers, and reference logits oracle smoke.

## Exit criteria

| Item | Artifact |
|------|----------|
| `li_llm_version` 9 | `packages/li-llm/src/lib.li` |
| Production SSE | `llm_streaming_sse_production_ok`, `build/inference-native-backend`, `test-m15-inference-live.sh` Li backend |
| Full MLP backward | `autograd_mode=full_backward`, `bench_ph_ml_mlp_train_parity.py` |
| GPU KV progress | `llm_kv_device_buffer_progress` honest skip when no LIG_EMIT |
| LLM competitors | `bench-ph-ml-competitor-llm-all.sh` (llamacpp, vllm, transformers) |
| Logits oracle | `ph-ml-llm-logits-oracle.json` with `ulp_smoke: true` |

## Deferred (post Stage 8)

- Multi-layer transformer reference parity vs transformers
- Cluster model download / GPU production decode
- Full vLLM competitive ratio gates (GPU required)

## Completion gate

```bash
bash scripts/ph-ml-stage8-gates.sh
```

Master library gate:

```bash
bash scripts/ph-ml-hpc-ai-library-gates.sh
```
