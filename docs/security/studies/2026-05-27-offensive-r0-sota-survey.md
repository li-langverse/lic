# Offensive security — SOTA survey (`offensive-r0-sota-survey`)

**Goal:** `offensive_security` · **Session:** `d6142e7a-d613-41cb-a295-4f5ffe1d2c5f` · **Run:** `security_auditor-1779904309903`  
**Agent:** `security_auditor` · **Mode:** study-only (posture validity locked; no weakening `li_stricter`)  
**North star:** secure pillar — fuzz + tier5 exploits + CWE feed vs nginx stricter-or-equal  
**Preflight:** `benchmarks/data/latest/security-cwe-feed-delta.json` @ 2026-05-27T17:51Z · [httpd plan](../../superpowers/plans/2026-05-16-li-httpd-plan.md)

---

## Problem

Li’s security posture combines **compile-time rejection** (borrowck, path gates, proved bounds) with **runtime exploit parity** against nginx on `build/li-httpd`. Industry practice for web servers relies on **years of CVE patches, module-specific checks, and continuous fuzzing** (libFuzzer, AFL++, protocol fuzzers). Li must close the gap between **MITRE CWE Top 25 coverage** in `security/cve-catalog.json` and **live tier5 exploit rows** without trading exploit expectations for bench throughput.

---

## Learned from (SOTA)

1. **MITRE CWE Top 25 (2024)** — ranked weakness classes for appsec prioritization.  
   - List: https://cwe.mitre.org/top25/  
   - **Takeaway:** Catalog must represent Top 25 CWE ids honestly (`needsWeb` rows) or document compile-time N/A with `li-tests/security/*` obligations in `cwe-to-li-tests.toml`.

2. **OWASP Top 10 (2021)** — web abuse classes (injection, broken access control, SSRF).  
   - https://owasp.org/Top10/  
   - **Takeaway:** Tier5 exploit TOML already tags `owasp = [...]` (e.g. `path_traversal` → A01); expand rows for CWE-79/89/352 gaps per httpd plan `gap-exploit-owasp-cwe-suite`.

3. **nginx security model** — distributed checks, `merge_slashes`, request-line limits, module CVE history; fuzzed for decades.  
   - Docs: https://nginx.org/en/docs/http/ngx_http_core_module.html  
   - **Takeaway:** Li maps nginx mitigations in `benchmarks/tier5_http/nginx_mitigations.toml` (~34 rows); every exploit cites `mitigation_id` and requires `li_behavior = "stricter"` on `[expect]`.

4. **libFuzzer / AFL++** — in-process coverage-guided fuzzing for parsers and protocol state machines.  
   - LLVM: https://llvm.org/docs/LibFuzzer.html · AFL++: https://github.com/AFLplusplus/AFLplusplus  
   - **Takeaway:** Parser fuzz lives at `compiler/fuzz/parse_fuzz.cpp` with corpus `compiler/fuzz/corpus/`; httpd plan calls for standalone `http_parse_fuzz` + nightly corpus merge (`scripts/merge_fuzz_corpus.sh`). Fuzz throughput is **documented only** — not traded for posture.

5. **tlsfuzzer / h2spec** — TLS record and HTTP/2 violation testing (M2 surfaces).  
   - tlsfuzzer: https://github.com/tlsfuzzer/tlsfuzzer · h2spec: https://github.com/summerwind/h2spec  
   - **Takeaway:** Tier5 `[attack] driver = tlsfuzzer` for M2 TLS; RNG exploit rows (`rng_*`) gate when touching `li-rng` / `li-tls`.

---

## Li inventory (2026-05-27)

| Surface | Location | Count / status |
|---------|----------|----------------|
| CVE catalog | `security/cve-catalog.json` | 39 entries, **15 unique CWEs** |
| CWE → tests map | `security/cwe-to-li-tests.toml` | 18 patterns (memory, race, path, fuzz_seed) |
| Parser fuzz | `compiler/fuzz/` | libFuzzer target + corpus seeds (`seed_http_smuggle`, `seed_decorators`) |
| Tier5 exploits | `benchmarks/tier5_http/exploits/*.toml` | **32** enabled scenarios vs nginx |
| nginx mitigations | `benchmarks/tier5_http/nginx_mitigations.toml` | ~34 machine-readable rows |
| Security tests | `li-tests/security/*` | 14 compile-fail / stress files |
| CWE feed sync | `benchmarks/data/latest/security-cwe-feed.json` | Top25=25, **missing_in_catalog=19**, feed age 0d |

**Briefing:** `catalog_gaps` (li-tests path coverage) = **0**; Top25 vs catalog gap = **19** (web/app CWE classes not yet in `cve-catalog.json`).

---

## SOTA → Li mapping (CWE Top 25)

| CWE | Top25 rank | Incumbent mitigation | Li today | Action (next todo) |
|-----|------------|----------------------|----------|-------------------|
| CWE-787 | #1 | Bounds checks, fuzz | `cve-catalog` + `cwe787_oob_index.li` | Maintain; extend fuzz corpus |
| CWE-79 | #2 | Output encoding, CSP | **Not in catalog** | `sec-r0` catalog row + XSS tier5 or compile N/A doc |
| CWE-89 | #3 | Parameterized SQL | **Not in catalog** | Catalog row; Li SQL surface TBD (`lidb`) |
| CWE-416 | #4 | UAF patches | borrowck `CWE-416` | Covered |
| CWE-78 | #5 | Shell escaping | `codegen_path_injection.sh` | Covered |
| CWE-20 | #6 | Input validation | **Not in catalog** | Map to httpd request-line/header limits + tier5 |
| CWE-125 | #7 | OOB read | `cwe125_negative_index.li` | Covered |
| CWE-22 | #8 | Path normalization | tier5 `path_traversal` | Catalog row (refs exist in exploit) |
| CWE-352 | #9 | CSRF tokens | **Not in catalog** | Study-only until HTTP forms surface |
| CWE-434 | #10 | Upload filters | **Not in catalog** | `client_max_body_size` tier5 + catalog |
| CWE-862 | #11 | Missing authorization | **Not in catalog** | Agent-gateway auth tier5 backlog |
| CWE-476 | #12 | NULL deref | **Not in catalog** | Native `*_core.c` + ASan slice |
| CWE-287 | #13 | Auth bypass | **Not in catalog** | `test-auth-bearer.sh` + tier5 auth rows |
| CWE-190 | #14 | Integer overflow | `integer_literal_flood.li` | Covered |
| CWE-502 | #15 | Deserialization | **Not in catalog** | Defer until serde attack surface |
| CWE-77 | #16 | Command injection | partial via CWE-78 | Unify catalog row |
| CWE-119 | #17 | Buffer overflow | **Not in catalog** | Alias to CWE-787 pattern in catalog |
| CWE-798 | #18 | Hard-coded creds | leak tier5 (`leak_*`) | Catalog + censor tests |
| CWE-918 | #19 | SSRF | `host_header_ssrf` tier5 | Catalog row |
| CWE-306 | #20 | Missing auth | **Not in catalog** | Map to M3 agent-gateway |
| CWE-362 | #21 | Race | `race_shared_memory` | Covered |
| CWE-269 | #22 | Privilege | `privilege_path_escalation` tier5 | Catalog row |
| CWE-94 | #23 | Code injection | **Not in catalog** | Compile-time seam rejects |
| CWE-863 | #24 | Incorrect authz | **Not in catalog** | Agent-gateway backlog |
| CWE-276 | #25 | Incorrect permissions | **Not in catalog** | Filesystem sandbox study |

---

## Tier5 exploit contract (stricter-or-equal)

Every row follows the machine contract:

```toml
[expect]
no_crash = true
reject_or_close_attack = true
legitimate_client_ok = true
li_behavior = "stricter"
```

Example: `request_smuggling_cl_te` (CWE-444, CVE-2019-20372) — live `build/li-httpd` vs nginx on `static_small` scenario. **Gate:** `m1-exploit-runtime` and httpd plan `gap-phase2-exploit-nginx-regression` require all enabled rows green; no nginx-pass/li-fail regressions.

**Open plan gaps (httpd):** `gap-phase2-mitigation-exploits` (empty exploit for some `nginx_mitigations.toml` rows), `gap-exploit-owasp-cwe-suite`, standalone `http_parse_fuzz` nightly.

---

## Fuzz campaign map

| Target | Tool | Corpus / repro | Status |
|--------|------|----------------|--------|
| Li parser | libFuzzer `parse_fuzz` | `compiler/fuzz/corpus/` | Shipped seeds; nightly merge scripted |
| HTTP parse (planned) | libFuzzer / AFL++ | httpd plan § fuzz table | **Pending** (`sec-r1-httpd-fuzz-smoke`) |
| TLS (M2) | tlsfuzzer | tier5 `driver = tlsfuzzer` | Partial via `rng_prng_on_tls_*` |
| HTTP/2 | h2spec + tier5 | `h2_rapid_reset.toml` | Row exists; live runtime gate pending |

---

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Posture validity | pass | — | No `li_stricter` weakening this survey |
| CWE freshness | pass | synced 2026-05-27 | `security-cwe-feed-sync.py` OK; audit script needs `gh` for workflow scan |
| Fuzz coverage | partial | — | Parser fuzz shipped; httpd parse fuzz not yet standalone |
| Tier5 parity | study-only | 32 rows | Live vs nginx = `sec-r2` implement pass |
| ASan / native | N/A | — | No `*_core.c` edits this step |

## Tradeoffs

- **Locked:** security posture (exploit expectations, `li_stricter`, no new `trusted.lean` axioms)
- **Improved:** SOTA map + Top25→action table for `li_gap_analysis` step
- **Deferred:** Catalog row authoring for 19 CWEs (human/CVE process); multi-repo httpd fixes → `code_implementer`

---

## Evidence

```bash
export LIC_ROOT=/path/to/lic
cd benchmarks
python3 scripts/security-cwe-feed-sync.py
cat data/latest/security-cwe-feed-delta.json
# security-cwe-audit.py requires gh API for org workflow scan
cd "$LIC_ROOT" && SECURITY_RESEARCH_BACKLOG_STUDY_ONLY=1 ./scripts/security-research-gates.sh
```
