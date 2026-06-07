# Security research — `sec-r1-httpd-fuzz-smoke`

**Goal:** `offensive_security` · **Issue:** [#521](https://github.com/li-langverse/lic/issues/521)  
**Agent:** `code_implementer` · **Mode:** study-only (posture locked)  
**North star:** PH-H — documented HTTP parse fuzz smoke before full 24h soak

---

## Problem

The httpd plan calls for standalone `http_parse_fuzz` (libFuzzer) alongside parser fuzz. The security-research runner stalled on sec-r1 with `agent_exit=1` while gates passed — missing CI-visible fuzz smoke and study artifact.

---

## HTTP parse entrypoints (inventory)

| Surface | Location | Fuzz status |
|---------|----------|-------------|
| Request-line witness | `runtime/li_rt.c` → `li_rt_http_parse_request_len_tag` | **Shipped:** `compiler/fuzz/http_parse_fuzz.cpp` |
| Full request-line parser | `runtime/li_rt_net.c` → `parse_request_line_c` (static) | Documented; standalone target deferred to httpd plan nightly |
| Routed parse | `runtime/li_rt_httpd.c` → `parse_http_request_line` | Tier5 live harness (`bad_method`, `oversized_request_line`) |
| Li witness | packages/li-http (forward-closed) | Compile-time bounds; no runtime fuzz yet |

---

## Deliverables

1. **`http_parse_fuzz`** libFuzzer target (CMake sibling to `parse_fuzz`) linking `li_rt`.
2. Seed corpus under `compiler/fuzz/corpus/http/` (`seed_get`, `seed_overlong_line`, `seed_bad_method`).
3. **`scripts/httpd-fuzz-smoke.sh`** — ≤120s smoke, no crash (`HTTPD_FUZZ_SMOKE=1` gate).
4. Tier5 exploit smoke subset (documented; live compare requires `build/li-httpd` + benchmarks harness):
   - `request_smuggling_cl_te`
   - `path_traversal`
   - `slowloris` (via connection_flood / slow header class rows)

Full live tier5 `--profile pr --compare-nginx` runs in httpd phase-2 gates when `HTTPD_RUN_PHASE2_GATES=1`.

---

## Evidence

```bash
cmake -B build-fuzz -G Ninja -DLI_BUILD_FUZZ=ON -DLLVM_DIR=/usr/lib/llvm-22/lib/cmake/llvm \
  -DCMAKE_C_COMPILER=clang-22 -DCMAKE_CXX_COMPILER=clang++-22
cmake --build build-fuzz --target http_parse_fuzz
HTTPD_FUZZ_SMOKE=1 ./scripts/httpd-fuzz-smoke.sh
SECURITY_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SECURITY_RESEARCH_REQUIRE_STUDY=docs/security/studies/2026-06-07-sec-r1-httpd-fuzz-smoke.md \
  HTTPD_FUZZ_SMOKE=1 ./scripts/security-research-gates.sh
```

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Posture validity | pass | — | No `li_stricter` weakening |
| CWE freshness | skip | study-only | Hard gate deferred |
| Fuzz coverage | pass | new smoke | `http_parse_fuzz` + corpus seeds |
| Tier5 parity | documented | 3-row subset | Live harness = benchmarks sibling |
| ASan / native | N/A | — | sec-r3 covers native slice |

## Tradeoffs

- **Locked:** security posture (exploit expectations, `li_stricter`)
- **Improved:** CI-visible HTTP parse fuzz smoke; closes sec-r1 plan debt
- **Deferred:** 24h libFuzzer soak; static `parse_request_line_c` export (httpd plan nightly)
