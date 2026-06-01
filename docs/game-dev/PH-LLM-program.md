# PH-LLM — native LLM inference program

**Status:** Planning (Wave 0 scaffold landed)  
**Vision:** [world-studio-vision.md](world-studio-vision.md)  
**RFC:** [specs/lillm-rfc.md](specs/lillm-rfc.md)  
**Package:** `packages/li-llm` (`import llm`)

## Overview

**PH-LLM** delivers native Li LLM inference for World Studio agentic workflows.
Complements **PH-ML** (classical DL) and **li-studio-ai** (orchestration, not inference).

**Native-first:** CPU decode path in Wave 1; GPU via `@gpu` + LKIR in Wave 2.
**No PyTorch runtime** in v1 — weights via HF safetensors / GGUF export.

## Work packages

| WP | Deliverable | Depends | Gate | Status |
|----|-------------|---------|------|--------|
| **WP-LLM-01** | BPE/byte-level tokenizer + vocab load | std strings | smoke roundtrip | **partial** (byte+BPE scaffold) |
| **WP-LLM-02** | Safetensors + GGUF loader (f32/f16; no MoE v1) | WP-LLM-01 | load Llama-3.2-1B-class fixture | **partial** (header parse scaffold) |
| **WP-LLM-03** | Transformer graph (`llm.attn`, `llm.ffn`, RoPE) | `li-ml` matmul | forward vs reference logits ULP | **partial** (matmul layer stub) |
| **WP-LLM-04** | KV-cache + decode loop (`llm_generate`) | WP-LLM-03 | greedy decode smoke | **stub** |
| **WP-LLM-05** | CPU perf via `li-ml`/`linalg` matmul | PH-ML WP-ML-04 | tier-3 bench row | **partial** (`llm_forward_matmul_cpu_hint` → `ml_lig_matmul_run_auto`) |
| **WP-LLM-06** | GPU matmul/attention via `@gpu` + LKIR | PH-HW WP-HW-06 | tier-3 GPU column | planned |
| **WP-LLM-07** | HF → safetensors export doc + `lillm import` CLI | WP-LLM-02 | one documented model path | planned |
| **WP-LLM-08** | Trusted backend (Ollama/OpenAI-compatible) — Wave 2 | `li-httpd` | audit + `[trusted]` fence | optional |

## Not in v1

Fine-tuning, autograd, MoE, multimodal.

## Studio integration

- `packages/li-studio-ai` — `studio_ai_complete` → `llm_generate` when weights loaded
- Fallback: Cursor SDK cloud when no local weights
- See [studio-cursor-sdk-rfc.md](specs/studio-cursor-sdk-rfc.md)

## Milestones (from battle plan)

| Milestone | When | Evidence |
|-----------|------|----------|
| M3 | Week 16 | lillm loads + greedy-decodes 1B model on CPU (tier-3 correctness row) |
| M4 | Week 20 | Agent apply_patch loop in Studio (WP-AG-04) |
| M6 | Month 12 | lillm GPU decode + sim_rl training visible |

## Tracker linkage

Add PH-LLM row to [PH-world-studio-program.md](PH-world-studio-program.md) after Wave 1 CPU matmul (PH-ML Wave 1).
