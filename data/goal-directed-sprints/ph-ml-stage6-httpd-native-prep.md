# PH-ML Stage 6 prep — li-httpd native route

**Gate (future):** `scripts/ph-ml-stage6-gates.sh` (not yet implemented)  
**Baseline:** Stage 5 transformer forward

## Goal

Wire native `li-llm` generate path into `li-httpd` trusted route: load weights from `fixtures/ph-ml-weights`, tokenize prompt, return multi-token decode result over HTTP without Ollama proxy.

## Prep work

- Extend `llm_trusted_httpd_route.li` smoke to call `llm_generate_tracked`
- Bench: `bench_ph_ml_llm_trusted_httpd.py` native mode (not live_proxy only)
- K8s wave13 engine image refresh with Stage 5 lic binary

## Deferred

- Streaming SSE tokens
- Auth / rate limits
- Production model download in cluster
