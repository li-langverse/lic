# li-llm

Native LLM inference library for Li (`import llm`).

## Status: **STUB** (Wave 0)

All inference APIs are contract stubs. See `docs/game-dev/PH-LLM-program.md` and
`docs/game-dev/specs/lillm-rfc.md`.

| WP | API | Status |
|----|-----|--------|
| WP-LLM-01 | `llm_tokenize`, `llm_detokenize` | stub |
| WP-LLM-02 | `llm_load_weights` | stub |
| WP-LLM-03 | `llm_forward` | stub |
| WP-LLM-04 | `llm_generate` | stub |

## Verify

```bash
lic check packages/li-llm/li-tests/smoke/llm_tokenize_roundtrip.li
```

## Weight path

No PyTorch runtime. Import Hugging Face weights via safetensors/GGUF export (see RFC).
