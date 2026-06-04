# PH-ML Stage 7 prep — streaming SSE tokens

**Gate (future):** `scripts/ph-ml-stage7-gates.sh` (not yet implemented)  
**Baseline:** Stage 6 li-httpd native generate

## Goal

Stream multi-token decode over li-httpd SSE (`/v1/chat/completions` chunked) using native `llm_generate_tracked` steps — no Ollama proxy.

## Prep work

- Extend `li-net-httpd` route handler for chunked SSE from native decode loop
- Bench: token latency per decode step
- Auth / rate limits (deferred from Stage 6)

## Deferred

- Production model download in cluster
- GPU decode device buffers
