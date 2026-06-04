# PH-ML Stage 4 — LLM import pipeline (2026-06-04)

## Summary

Native weight import for `packages/li-llm`: safetensors headers parsed from disk (tensor count, F32/F16 dtype, shape), minimal GGUF magic/version/tensor_count, `lillm-import.sh` offline path, and tier-3 `ph-ml-llm-forward` bench tagged `workload_class=pilot` when tensor-metadata smokes pass.

## Changes

| Area | Detail |
|------|--------|
| Runtime | `li_rt_llm.c` linked from codegen; file byte read + safetensors/GGUF probe |
| li-llm | `li_llm_version` 5; legacy `fixtures/model.safetensors` scaffold unchanged for smokes |
| Import | `llm_import_model_path_default()` → `fixtures/ph-ml-weights/model.safetensors` |
| Gates | `ph-ml-stage4-gates.sh` runs program-complete + new smokes + benches |

## Verify

```bash
bash scripts/ph-ml-stage4-gates.sh
```
