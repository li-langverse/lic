# PH-ML Stage 5 — transformer forward + multi-token decode

**Branch:** `cursor/ph-ml-stage5-transformer-forward`  
**Gate:** `scripts/ph-ml-stage5-gates.sh`  
**Baseline:** Stage 4 @ `37345edf`

## Goal

Replace checksum-oracle `llm_forward` with a real (scaffold) transformer block using `ml_matmul_f32` on safetensors tensor bytes, and greedy decode via `llm_generate_tracked` with ≥8 steps — not a checksum oracle gate.

## Delivered

| Item | Evidence |
|------|----------|
| `li_llm_version` 6 | `packages/li-llm/src/lib.li` |
| Matmul forward | `llm_forward_matmul_top_id`, `llm_matmul_block_contrib` |
| Multi-decode | `llm_generate_tracked`, `llm_generate_multi_decode.li` |
| Smokes | `llm_forward_matmul_real.li` |
| Bench | `forward_matmul_ok`, `workload_class=tier3_cpu` |

## Deferred

- Full layer stack / attention (Stage 6+)
- Reference logits parity
- GPU forward path
