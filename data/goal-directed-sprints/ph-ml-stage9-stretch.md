# PH-ML Stage 9 — post-completion stretch goals

**Branch:** `cursor/ph-ml-stage9-stretch`  
**Gate:** `scripts/ph-ml-stage9-gates.sh`  
**Baseline:** Stage 8 @ main (PR #862+ merged)

## Goal

Close Stage 8 deferred items: multi-layer transformer reference parity (Li `ml_matmul_f32` vs Python reference + optional HF smoke), cluster GPU KV decode progress with honest `LIG_EMIT` skip, LLM competitor drivers in gate/CI, and benchmarks dashboard summary baseline restore.

## Exit criteria

| Item | Artifact |
|------|----------|
| `li_llm_version` 10 | `packages/li-llm/src/lib.li` |
| Multi-layer forward | `llm_transformer_layer_count`, `llm_forward_matmul_top_id` loops `num_layers` |
| Reference parity | `ph-ml-transformer-multilayer-parity.json` Li vs Python reference |
| GPU KV cluster | `llm_kv_cluster_gpu_decode_progress`, `ph-ml-llm-kv-gpu-cluster.json` |
| LLM competitors | `bench-ph-ml-competitor-llm-all.sh` with `executed` + `note` |
| Competitive row | `ph-ml-competitive.json` `llm_transformer_multilayer` |

## Deferred

- Full vLLM competitive ratio gates (GPU cluster required)
- Weight-level HuggingFace parity (fixture is matmul oracle, not HF checkpoint)

## K8s GPU test

When homelab GPU node available:

```bash
export LIG_EMIT_CUDA=1
bash scripts/bench-ph-ml-llm-kv-gpu-cluster.sh
```

Otherwise gate records `executed: false` / honest skip note.

## Completion gate

```bash
bash scripts/ph-ml-stage9-gates.sh
```

Master library gate:

```bash
bash scripts/ph-ml-hpc-ai-library-gates.sh
```
