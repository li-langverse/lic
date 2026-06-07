# Release notes: PH-ML Stage 7 streaming + SOTA non-pilot benches

**Date:** 2026-06-05  
**Gate:** `scripts/ph-ml-stage7-gates.sh`  
**Baseline:** Stage 6 @ PR #858 merged (`4db435cd`)

## Summary

Stage 7 upgrades competitive matmul/MLP rows from `pilot` to `tier3_cpu` (32×32 LKIR matmul + pilot autograd backward), adds native SSE streaming decode prep on `llm_generate_tracked` steps, and enables a 2×2×2 matmul backward pilot in `ml_autograd_*`.

## Changes

| Area | Detail |
|------|--------|
| **LLM v8** | `llm_streaming_sse_*` prep oracles; smoke `llm_streaming_sse_prep.li` |
| **Autograd** | `ml_autograd_tape_enabled=1`; pilot backward in `ml_mlp_train_step_f32` |
| **Benches** | `ph-ml-lkir-matmul-32`, `ph-ml-mlp-train-step` (`pilot_backward`), `ph-ml-llm-streaming-sse` |
| **Competitive** | `matmul_lkir` / `mlp_forward` Li rows → `tier3_cpu` when gates pass |
| **Flake fix** | Double-run warmup in `bench-ph-ml-llm-trusted-httpd-native.sh` |

## Deferred

- Full li-httpd chunked SSE route wiring in production cluster
- Reference logits parity vs transformers
- GPU decode / KV-cache device buffers
