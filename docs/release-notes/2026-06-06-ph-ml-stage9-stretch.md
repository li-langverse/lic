# Release notes — PH-ML Stage 9 stretch

**Date:** 2026-06-06  
**Gate:** `scripts/ph-ml-stage9-gates.sh`  
**Branch:** `cursor/ph-ml-stage9-stretch`

## Summary

Stage 9 closes post–Stage 8 stretch goals: multi-layer transformer forward parity, cluster GPU KV decode progress, and LLM competitor drivers wired into gates with honest skip when deps absent.

## Changes

| Area | Detail |
|------|--------|
| **Multi-layer transformer** | `llm_transformer_layer_count`, layer loop in `llm_forward_matmul_top_id`, `llm_transformer_multilayer_parity_ok` |
| **Reference parity** | `bench_ph_ml_transformer_multilayer_reference.py`, optional tiny-GPT2 HF smoke |
| **GPU KV cluster** | `llm_kv_cluster_gpu_decode_progress`, `bench-ph-ml-llm-kv-gpu-cluster.sh` |
| **Competitors** | llamacpp / vLLM / transformers in stage9 gate + `ph-ml-competitive.json` multilayer row |
| **Version** | `li_llm_version` → 10 |

## Deferred

- Full vLLM competitive ratios on GPU cluster
- HuggingFace weight-level parity (fixture remains matmul oracle)

## Verify

```bash
bash scripts/ph-ml-stage9-gates.sh
bash scripts/ph-ml-hpc-ai-library-gates.sh
```
