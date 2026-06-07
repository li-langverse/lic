# PH-ML Stage 7 prep — streaming SSE tokens

**Gate (future):** `scripts/ph-ml-stage7-gates.sh`  
**Baseline:** Stage 6 li-httpd native generate @ PR #858 (`4db435cd`)

## Goal

Stream multi-token decode over li-httpd SSE (`/v1/chat/completions` chunked) using native `llm_generate_tracked` steps — no Ollama proxy.

## Prep work

- Extend `li-net-httpd` route handler for chunked SSE from native decode loop
- Bench: token latency per decode step
- Auth / rate limits (deferred from Stage 6)

## Deferred

- Production model download in cluster
- GPU decode device buffers
