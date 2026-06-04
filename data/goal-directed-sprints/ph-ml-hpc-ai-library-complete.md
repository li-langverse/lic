# PH-ML HPC AI library — master completion

**Sprint:** `ph-ml-hpc`  
**Gate:** `scripts/ph-ml-hpc-ai-library-gates.sh`  
**Baseline:** Stage 4 @ `37345edf` (PR #852 merged)

## Goal

Close the native Li ML/HPC/AI library track through Stage 5: real transformer forward via `ml_matmul_f32` on safetensors bytes, greedy multi-token decode (≥8 steps), tier-3 competitive bench rows with **no `workload_class=stub` on executed Li rows**, and Stage 6 prep for li-httpd native route.

## Stages

| Stage | Scope | Gate |
|-------|-------|------|
| 4 | LLM import (safetensors/GGUF, lillm-import) | `ph-ml-stage4-gates.sh` |
| 5 | Transformer forward + multi-decode | `ph-ml-stage5-gates.sh` |
| 6 (prep) | li-httpd native trusted route | `ph-ml-stage6-httpd-native-prep.md` |

## Stage 5 exit criteria

- `li_llm_version() == 6`
- `llm_forward_matmul_top_id` uses `ml_matmul_f32` on mmap'd safetensors bytes
- `llm_generate_tracked` runs ≥8 decode steps with `forward_matmul == 1`
- `ph-ml-llm-forward.json`: `forward_matmul_ok`, `workload_class=tier3_cpu`
- Competitive `llm_forward` Li row: executed, not stub

## Deferred (Stage 6+)

- Full reference logits parity vs transformers
- GPU decode / KV-cache device buffers
- Live li-httpd native inference route (see Stage 6 prep)
