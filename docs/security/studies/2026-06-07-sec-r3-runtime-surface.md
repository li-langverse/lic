# sec-r3 — runtime native surface + ASan slice (`sec-r3-runtime-surface`)

**Issue:** [#521](https://github.com/li-langverse/lic/issues/521)  
**REQ:** REQ-SEC-NATIVE-1 — ASan slice when native HTTP/parse cores touched

---

## Native attack surface inventory

| Seam | Files | Notes |
|------|-------|-------|
| HTTP request parse | `runtime/li_rt_net.c` | Request line, headers, smuggling class, body meta |
| HTTP config / routing | `runtime/li_rt_httpd.c` | Config load, route match, M1 oracle |
| HTTP header tag | `runtime/li_rt.c` | `li_rt_http_parse_request_len_tag` (Lean witness) |
| TLS / RNG | `runtime/li_rt_tls.c`, `runtime/li_rt_rng.c` | Tier F exploit rows (`rng_*`) |
| Parser (compiler) | `compiler/fuzz/parse_fuzz.cpp` | Separate from httpd; libFuzzer CI |

**Invariants (no duplicate IV, bounded headers):** tier5 `rng_*` rows + httpd `HTTPD_MAX_HEADER_LINES` / `HTTPD_MAX_BODY` caps; Lean closed slice `http_parse_forward_closed.li`.

---

## ASan slice

`li-tests/run_security_asan_slice.sh` — runs `run_security.sh` + HTTP parse witness under `LI_SECURITY_ASAN=1` when ASan `lic` present. Wired into `scripts/security-research-gates.sh` (`asan_ok`).

```bash
LI_SECURITY_ASAN=1 ./li-tests/run_security_asan_slice.sh   # when build-asan/lic exists
./scripts/security-research-gates.sh
```

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Posture validity | pass | — | No trusted.lean / li_stricter changes |
| CWE freshness | pass | — | Inherited from gates |
| Fuzz coverage | pass | sec-r1 | http_parse_fuzz documents HTTP native path |
| Tier5 parity | N/A | — | sec-r2 row |
| ASan / native | pass | new slice | Script + gate wiring; skip when no ASan build |

## Tradeoffs

- **Locked:** security posture
- **Improved:** Documented native surface table + ASan slice hook for future `*_core.c` touches
- **Deferred:** Full TSan compiler CI; live tier5 nginx compare on all rows
