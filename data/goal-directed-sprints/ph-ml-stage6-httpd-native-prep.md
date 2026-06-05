# PH-ML Stage 6 — li-httpd native route

**Branch:** `cursor/ph-ml-stage6-httpd-native`  
**Gate:** `scripts/ph-ml-stage6-gates.sh`  
**Baseline:** Stage 5 @ PR #856 merged (`cc3bde4c`)

## Goal

Wire native `li-llm` generate path into the trusted li-httpd route: load weights from `fixtures/ph-ml-weights`, run `llm_generate_tracked` (≥8 steps), bench with `native_generate` — retire Python T8 `live_proxy` for prod gates.

## Exit criteria

| Item | Artifact |
|------|----------|
| `li_llm_version` 7 | `packages/li-llm/src/lib.li` |
| Native generate OK | `llm_trusted_httpd_native_generate_ok` |
| Smoke | `llm_trusted_httpd_route.li` |
| Bench | `ph-ml-llm-trusted-httpd.json` with `native_generate: true` |

## Deferred (Stage 7+)

- Streaming SSE tokens — see `ph-ml-stage7-streaming-prep.md`
- Auth / rate limits
- Production model download in cluster
