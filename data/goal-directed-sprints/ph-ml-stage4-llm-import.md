# PH-ML Stage 4 — LLM import pipeline

**Branch:** `cursor/ph-ml-stage4-llm-import`  
**Gate:** `scripts/ph-ml-stage4-gates.sh`  
**Baseline:** Stage 3 @ `c454aeab`

## Goal

Production import path for native `li-llm`: real safetensors header (dtype/shape/tensor count), minimal GGUF header + tensor table, documented `fixtures/ph-ml-weights` load, `lillm-import.sh`, honest `workload_class=pilot` on tier-3 LLM bench when tensor metadata smokes pass.

## Delivered (Stage 4.2)

| Item | Evidence |
|------|----------|
| `runtime/li_rt_llm.c` | On-disk safetensors/GGUF probe + byte read |
| `packages/li-llm` | `llm_safetensors_parse_header_file`, `llm_gguf_parse_header`, import path |
| Smokes | `llm_safetensors_parse_real.li`, `llm_gguf_header.li`, `llm_import_fixture_path.li` |
| CLI | `lillm-import.sh` offline manifest + minimal weights |
| Bench | `ph-ml-llm-forward.json` `tensor_metadata_ok`, competitive `llm_forward` pilot |

## Deferred

- Full GGUF KV/tensor name table walk
- Llama-3.2-1B HF download in CI (optional `LILLM_IMPORT_OFFLINE`)
- Transformer forward vs reference logits (WP-LLM-03)
- GPU decode (WP-LLM-06)
