# PH-LLM — Hugging Face export / import (Wave 10)

## Goal

Import HF checkpoints into Li-native safetensors fixtures for `li-llm` smokes and tier-3 benches.

## CLI scaffold

```bash
bash scripts/lillm-import.sh meta-llama/Llama-3.2-1B packages/li-llm/fixtures/imported
```

Writes `manifest.json` with model id and format tag. Full `huggingface-cli download` + tensor map deferred until safetensors byte loader lands.

## Export path (future)

1. Load weights via `llm_load_weights`
2. Emit safetensors header + f32 tensors (no MoE v1)
3. Validate with `llm_safetensors_load_tensors_scaffold`

## LLVM / import ml note

Cross-package `import ml` in `li-llm` remains blocked for LLVM codegen. Use `llm_transformer_matmul_contrib` inline until linker story is fixed.

## Wave 11

- `LILLM_IMPORT_OFFLINE=1` for CI manifest-only smoke.
- `llm_matmul_indirect_bridge` avoids `import ml` LLVM blocker; use `packages/li-llm/li-tests/smoke/llm_matmul_bridge.li`.
