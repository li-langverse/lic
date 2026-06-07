# Security research — `sec-r3-runtime-surface`

**Goal:** `offensive_security` · **Issue:** [#521](https://github.com/li-langverse/lic/issues/521)  
**Agent:** `code_implementer`  
**North star:** PH-H — native parse/crypto/HTTP surface inventory + ASan slice

---

## Problem

Runtime attack surface for httpd security (parse / crypto / HTTP native cores) lacked a documented inventory and ASan smoke gate when `*_core.c` or `li_rt*.c` seams are touched.

---

## Native surface inventory

| Seam | Files | Invariant |
|------|-------|-----------|
| HTTP parse | `runtime/li_rt.c`, `li_rt_net.c` | Bounded request line; reject overlong/malformed |
| HTTP server | `runtime/li_rt_httpd.c` | Route match; no path escape |
| TLS | `runtime/li_rt_tls.c` | OpenSSL dlopen; cert/key bounds |
| RNG/crypto | `runtime/li_rt_rng.c` | tier5 `rng_*` rows gate IV/nonce reuse |
| H2 | `runtime/li_rt_h2.c` | Rapid reset row (`h2_rapid_reset.toml`) |

---

## Deliverables

1. **`li-tests/security/run_security_asan_slice.sh`** — ASan smoke on `li_rt_http_parse_request_len_tag` when `LI_SECURITY_ASAN=1`.
2. Wired into `scripts/security-research-gates.sh` (`asan_ok` from slice).
3. Links to tier5 RNG rows and httpd Lean witnesses (no `trusted.lean` edits).

---

## Evidence

```bash
LI_SECURITY_ASAN=1 ./li-tests/security/run_security_asan_slice.sh
SECURITY_CWE_FEED_SKIP=1 LI_SECURITY_ASAN=1 ./scripts/security-research-gates.sh
```

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Posture validity | pass | — | No weakening |
| CWE freshness | skip | — | Optional feed |
| Fuzz coverage | pass | sec-r1 | http_parse_fuzz |
| Tier5 parity | N/A | — | sec-r2 catalog |
| ASan / native | pass | new slice | `run_security_asan_slice.sh` |

## Tradeoffs

- **Locked:** security posture; no `trusted.lean`
- **Improved:** ASan gate for touched native HTTP witness
- **Deferred:** Full `li_rt_net.c` ASan build (heavy); TSan compiler CI unchanged
