# PH-ML Stage 6 — li-httpd native `llm_generate_tracked`

**Date:** 2026-06-05  
**Gate:** `scripts/ph-ml-stage6-gates.sh`

## Summary

Stage 6 wires native `li-llm` greedy decode into the trusted li-httpd route smoke and bench. Production gates use `native_generate` via compiled `llm_trusted_httpd_route.li` instead of the Wave 13 Python `HTTPServer` live_proxy probe.

## Changes

- `li_llm_version` bumped to **7**
- `llm_trusted_httpd_native_generate_ok` — loads `fixtures/ph-ml-weights`, runs ≥8 decode steps with `forward_matmul == 1`
- Bench `ph-ml-llm-trusted-httpd.json`: `native_generate: true`, `live_proxy: false` (default `PH_ML_LLM_TRUSTED_HTTPD_NATIVE=1`)

## Verify

```bash
PH_ML_STAGE6_INNER=1 bash scripts/ph-ml-stage6-gates.sh
PH_ML_HPC_AI_LIBRARY_INNER=1 bash scripts/ph-ml-hpc-ai-library-gates.sh
```
