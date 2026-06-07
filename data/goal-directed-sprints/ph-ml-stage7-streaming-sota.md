# PH-ML Stage 7 — streaming SSE + SOTA non-pilot benches

**Branch:** `cursor/ph-ml-stage7-streaming-sota`  
**Gate:** `scripts/ph-ml-stage7-gates.sh`  
**Baseline:** Stage 6 @ PR #858 merged (`4db435cd`)

## Goal

Upgrade competitive DL rows to **non-pilot** `tier3_cpu`, prep native SSE streaming from `llm_generate_tracked` decode steps, and land pilot autograd backward (2×2×2 matmul stub).

## Exit criteria

| Item | Artifact |
|------|----------|
| `li_llm_version` 8 | `packages/li-llm/src/lib.li` |
| SSE prep OK | `llm_streaming_sse_prep_ok`, smoke `llm_streaming_sse_prep.li` |
| Autograd pilot | `autograd_mode=pilot_backward` in `ph-ml-mlp-train-step.json` |
| Non-pilot competitive | `matmul_lkir`, `mlp_forward` → `tier3_cpu` |
| Streaming bench | `ph-ml-llm-streaming-sse.json` with `native_decode: true` |

## Deferred (Stage 8+)

- Production li-httpd SSE route handler wiring in cluster
- Full MLP backward (not 2×2×2 stub)
- LLM competitor drivers (llama.cpp, vLLM, transformers)

## Completion gate

```bash
bash scripts/ph-ml-stage7-gates.sh
```
