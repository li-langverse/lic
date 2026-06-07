# Release notes — PH-ML Stage 5 transformer forward

**Date:** 2026-06-04  
**Gate:** `scripts/ph-ml-stage5-gates.sh`

## Summary

Stage 5 replaces the checksum-oracle LLM forward with `ml_matmul_f32` on safetensors mmap bytes and adds greedy multi-token decode (≥8 steps) via `llm_generate_tracked`. Benchmark rows upgrade to `tier3_cpu` when matmul forward smokes compile.

## Changes

- `li_llm_version` bumped to 6
- `LlmKVCache.forward_matmul`, `LlmGenerateResult`
- Smokes: `llm_forward_matmul_real.li`, `llm_generate_multi_decode.li`
- Bench: `forward_matmul_ok` in `ph-ml-llm-forward.json`

## Verification

```bash
PH_ML_STAGE5_INNER=1 bash scripts/ph-ml-stage5-gates.sh
```
