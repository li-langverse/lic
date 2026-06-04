# PH-ML HPC AI library — master completion

**Sprint:** `ph-ml-hpc`  
**Gate:** `scripts/ph-ml-hpc-ai-library-gates.sh`  
**Baseline:** Stage 4 @ `37345edf` (PR #852 merged)

## Goal

Close the native Li ML/HPC/AI library track through Stage 6: real transformer forward via `ml_matmul_f32` on safetensors bytes, greedy multi-token decode (≥8 steps), tier-3 competitive bench rows with **no `workload_class=stub` on executed Li rows**, and li-httpd native `llm_generate_tracked` (no Python T8 live_proxy prod gate).

## Stages

| Stage | Scope | Gate |
|-------|-------|------|
| 4 | LLM import (safetensors/GGUF, lillm-import) | `ph-ml-stage4-gates.sh` |
| 5 | Transformer forward + multi-decode | `ph-ml-stage5-gates.sh` |
| 6 | li-httpd native trusted route | `ph-ml-stage6-gates.sh` |
| 7 | SSE streaming prep + tier3 competitive + autograd pilot | `ph-ml-stage7-gates.sh` |
| 7 (prep doc) | SSE streaming decode | `ph-ml-stage7-streaming-prep.md` |

## Stage 5 exit criteria

- `li_llm_version() == 6`
- `llm_forward_matmul_top_id` uses `ml_matmul_f32` on mmap'd safetensors bytes
- `llm_generate_tracked` runs ≥8 decode steps with `forward_matmul == 1`
- `ph-ml-llm-forward.json`: `forward_matmul_ok`, `workload_class=tier3_cpu`
- Competitive `llm_forward` Li row: executed, not stub

## Stage 6 exit criteria

- `li_llm_version() == 7`
- `llm_trusted_httpd_native_generate_ok` — ≥8 decode steps, `forward_matmul == 1`
- `ph-ml-llm-trusted-httpd.json`: `native_generate: true`, `live_proxy: false`

## Deferred (Stage 8+)

- Full reference logits parity vs transformers
- GPU decode / KV-cache device buffers
- Production SSE route in cluster (Stage 7 prep landed compile/bench gate)
