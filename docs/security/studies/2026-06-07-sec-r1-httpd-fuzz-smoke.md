# sec-r1 — httpd fuzz smoke (`sec-r1-httpd-fuzz-smoke`)

**Issue:** [#521](https://github.com/li-langverse/lic/issues/521) · **Plan:** [sec-r1-r3](../superpowers/plans/2026-06-06-security-research-sec-r1-r3-plan.md)  
**Agent:** `code_implementer` · **Mode:** study-only gate + fuzz smoke shipped  
**North star:** PH-H — documented HTTP parse fuzz path; posture locked

---

## HTTP parse entrypoints

| Surface | Location | Fuzz / gate |
|---------|----------|-------------|
| Request-line + headers (native) | `runtime/li_rt_net.c` — `parse_request_line_c`, `request_headers_unsafe_c` | `li_rt_http_fuzz_parse_request` |
| Lean forward witness | `li-tests/contracts_verify/http_parse_forward_closed.li` | `lic build` / AutoVC |
| Header block tag | `runtime/li_rt.c` — `li_rt_http_parse_request_len_tag` | called from fuzz entry |
| libFuzzer target | `compiler/fuzz/http_parse_fuzz.cpp` | `scripts/http-parse-fuzz-smoke.sh` |
| Tier5 smoke subset | `request_smuggling_cl_te`, `path_traversal`, `slowloris` | `scripts/security-research-tier5-smoke.sh` |

---

## Evidence

```bash
cd lic
cmake -B build-fuzz -G Ninja -DLI_BUILD_FUZZ=ON \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
cmake --build build-fuzz --target http_parse_fuzz
./scripts/http-parse-fuzz-smoke.sh
SECURITY_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SECURITY_RESEARCH_REQUIRE_STUDY=docs/security/studies/2026-06-07-sec-r1-httpd-fuzz-smoke.md \
  HTTPD_FUZZ_SMOKE=1 ./scripts/security-research-gates.sh
```

Corpus seeds: `compiler/fuzz/corpus/http/` (`seed_valid_get`, `seed_smuggle_cl_te`, `seed_overlong_line_prefix`).

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Posture validity | pass | — | No `li_stricter` weakening |
| CWE freshness | skip | study-only | Hard gate deferred to non-study iterations |
| Fuzz coverage | pass | partial→pass | Standalone `http_parse_fuzz` + CI smoke |
| Tier5 parity | pass (stub) | — | 3-row PR subset via tier5 smoke script |
| ASan / native | N/A | — | Native parse touched; ASan slice in sec-r3 |

## Tradeoffs

- **Locked:** security posture (exploit expectations, `li_stricter`)
- **Improved:** libFuzzer HTTP parse smoke + documented entrypoint table
- **Deferred:** 24h fuzz soak (`httpd` plan nightly); live nginx compare requires `build/li-httpd` on runner
