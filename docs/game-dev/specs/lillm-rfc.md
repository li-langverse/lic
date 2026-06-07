# RFC: lillm — native LLM inference library

**Status:** Draft (Wave 0 scaffold)  
**Date:** 2026-05-29  
**Program:** [PH-LLM-program.md](../PH-LLM-program.md)  
**Package:** `packages/li-llm` (`import llm`)

## Problem

World Studio agentic workflows need local LLM inference without shipping PyTorch or
vendor Python runtimes. Agents must call `llm.generate` from pure Li code with
honest correctness gates.

## Proposal

Composable modules:

1. **Tokenizer** (`llm_tokenize`, `llm_detokenize`) — BPE/byte-level, vocab file load
2. **Loader** (`llm_load_weights`) — safetensors primary, GGUF secondary (f32/f16)
3. **Forward** (`llm_forward`) — transformer blocks with RoPE, built on `li-ml` matmul
4. **Generate** (`llm_generate`) — KV-cache + greedy decode loop

## Weight format

| Format | Role | Notes |
|--------|------|-------|
| **safetensors** | Primary | HF export; no pickle |
| **GGUF** | Secondary | llama.cpp-compatible subset |
| **ONNX logits** | Oracle only (Tier-4) | Correctness reference, not runtime |

### HF → safetensors import path (WP-LLM-07)

1. Export model from Hugging Face Hub to safetensors (no custom code in runtime)
2. Place under `fixtures/` or user cache path documented in PH-LLM program
3. `llm_load_weights(path)` maps tensor names → Li layer structs
4. Future: `lillm import` CLI wrapper (Li script, not Python product helper)

**No PyTorch runtime in v1.**

## CPU vs GPU

| Wave | Path | Depends |
|------|------|---------|
| Wave 1 | CPU matmul via `li-ml` / `linalg` | PH-ML WP-ML-04 |
| Wave 2 | GPU via `@gpu` + LKIR emit | PH-HW WP-HW-06, PH-ML-GPU Wave 2 |

## Studio integration

```
User → li-studio → studio.ai.complete → llm.generate → native tokens
                  ↘ Cursor SDK cloud (fallback when no weights)
```

Orchestration lives in `li-studio-ai`; inference in `li-llm` only.

## Trusted backends (Wave 2 — WP-LLM-08)

Optional trait for Ollama / OpenAI-compatible HTTP backends:

- Marked `[trusted]` in docs
- Audit gate before product default
- Local native path remains default when weights present

## Li syntax

Use **`def`** for all APIs. **`extern proc`** only for documented FFI fences.
Every exported `def` needs `requires` / `ensures` / `decreases`.

## Proof / trust

| Component | Proved | Trusted |
|-----------|--------|---------|
| Tokenizer roundtrip | WP-LLM-01 smoke | vocab file bytes |
| Forward logits | ULP vs ONNX oracle (Tier-4) | weight file integrity |
| Generate | greedy smoke | sampling policy (v1: greedy only) |

## Open questions

- [ ] Fixed max seq len vs dynamic KV growth for v1
- [ ] GGUF quantization subset (Q4_K_M?) for Wave 2
- [ ] Model card / license gate in `llm_load_weights`
