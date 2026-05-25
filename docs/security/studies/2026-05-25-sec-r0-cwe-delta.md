# Security study — `sec-r0-cwe-delta` (CWE Top 25 vs CVE catalog)

**Date:** 2026-05-25  
**Agent:** `security_auditor` (offensive_security / study_only)  
**Branch:** `cursor/security-research-loop`  
**Artifacts:** `benchmarks/data/latest/security-cwe-feed.json`, `security-cwe-feed-delta.json`  
**Catalog:** `security/cve-catalog.json` (v1, 38 CVE rows, 15 unique CWE ids)

## Summary

MITRE CWE Top 25 feed sync ran against the workspace `lic` catalog. **No new CWE ids** appeared vs the previous feed snapshot (`new_vs_prev=0`). **19 of 25** Top-25 CWEs are absent from `cve-catalog.json`; **6** are represented (memory, injection, race classes Li already models). Eight catalog rows still lack an `li_test` path (mostly `asan_target` / `http_future`). Tier5 HTTP exploits partially cover web-class CWEs (CWE-22, CWE-78, CWE-918, CWE-20) but do not substitute for catalog + `li-tests/security/*` obligations.

**Posture:** locked — no exploit TOML or `li_stricter` changes in this iteration.

## Feed sync (2026-05-25T19:06Z)

| Metric | Value |
|--------|-------|
| Source | `mitre_top25_baseline` (web fetch to MITRE 699 JSON unavailable in runner) |
| `catalog_cwe_count` | 15 |
| `top25_missing_in_catalog` | 19 |
| `new_vs_previous_sync` | 0 |
| Feed age | 0 days (fresh) |

### Top 25 — present in catalog (6)

| CWE | Catalog CVE examples | `li-tests` / obligation |
|-----|----------------------|-------------------------|
| CWE-787 | CVE-2019-1010206, CVE-2013-2028 | `li-tests/cve_patterns/cwe787_*.li` |
| CWE-416 | CVE-2018-1000217 | `li-tests/borrow/use_after_move.li` |
| CWE-78 | CVE-2021-44228, CVE-2014-6271 | `li-tests/security/codegen_path_injection.sh` |
| CWE-125 | CVE-2014-0160, CVE-2023-0286 | `li-tests/cve_patterns/cwe125_negative_index.li` |
| CWE-190 | CVE-2020-0601, CVE-2022-2274 | `li-tests/security/integer_literal_flood.li` |
| CWE-362 | CVE-2016-5195, CVE-2017-5715 | `li-tests/race_shared_memory/*.li` |

### Top 25 — missing from catalog (19)

| CWE | MITRE class (short) | Repo / surface | Recommended action |
|-----|---------------------|----------------|-------------------|
| CWE-79 | XSS | `lip` / Studio web, future `li-httpd` static | **issue_planner:** catalog row + CSP/HTML policy test; not compiler-core |
| CWE-89 | SQL injection | `lidb` (future PH-DB) | **issue_planner:** catalog row when DB pillar lands |
| CWE-20 | Improper input validation | `lic` http/parser | **tier5** `bad_method`, `absolute_uri_connect`; add catalog row + parser negative `li-tests/security` |
| CWE-22 | Path traversal | `li-httpd`, `std/net` | **tier5** `path_traversal`, `sensitive_file_read`; map to catalog; handoff **gap-exploit-owasp-cwe-suite** |
| CWE-352 | CSRF | `li-httpd` | catalog row + session cookie test when M1 auth ships |
| CWE-434 | Unrestricted upload | `li-httpd` | catalog row; defer until upload surface exists |
| CWE-862 | Missing authorization | `li-httpd` | catalog row; tie to M1.5 authz invariants |
| CWE-476 | NULL pointer deref | `trusted_c` | extend `cwe-to-li-tests.toml`; ASan on native seams |
| CWE-287 | Improper authentication | `li-httpd` / TLS | catalog row; **tlsfuzzer** when M2 touches `li-tls` |
| CWE-502 | Deserialization | ecosystem packages | catalog row (N/A compiler); survey only until serde surface |
| CWE-77 | Command injection (shell) | `lic` codegen | merge with CWE-78 obligation (already `codegen_path_injection.sh`) |
| CWE-119 | Buffer errors (generic) | `lic` / `trusted_c` | alias to CWE-120/787 patterns in catalog |
| CWE-798 | Hard-coded credentials | `li-httpd` leak censor | **tier5** `leak_openai_key_in_sse`; catalog row for censor tests |
| CWE-918 | SSRF | `li-httpd` proxy | **tier5** `host_header_ssrf`; catalog row |
| CWE-306 | Missing authentication | `li-httpd` | catalog row; M1.5 |
| CWE-269 | Privilege escalation | `li-httpd` | **tier5** `privilege_path_escalation` |
| CWE-94 | Code injection | `lic` compile | catalog row; overlap CWE-94 with macro/eval policy (future) |
| CWE-863 | Incorrect authorization | `li-httpd` | catalog row; M1.5 |
| CWE-276 | Incorrect default permissions | deploy / FS | **issue_planner** when static root permissions tested |

## Catalog gaps (`li_test` null) — 8 rows

Rows in `security/cve-catalog.json` with no `li_test` (audit script `catalog_gaps`):

| CVE | CWE | `li_mitigation` | Action |
|-----|-----|-----------------|--------|
| CVE-2022-37434 | CWE-787 | `asan_target` | ASan rebuild zlib seam; fuzz seed — **code_implementer** |
| CVE-2023-0286 | CWE-125 | `asan_target` | TLS native read bounds — **code_implementer** + tlsfuzzer M2 |
| CVE-2013-2028 | CWE-787 | `not_applicable` | **httpd:** tier5 `chunked_encoding_bomb` when live httpd — **gap-phase2-mitigation-exploits** |
| CVE-2017-7529 | CWE-125 | `not_applicable` | **httpd:** range filter — document in httpd plan |
| CVE-2021-23017 | CWE-787 | `not_applicable` | **httpd:** resolver — native fuzz |
| CVE-2023-4863 | CWE-787 | `asan_target` | libwebp class — trusted_c ASan |
| CVE-2019-1010022 | CWE-676 | `asan_target` | extern seam audit — `trusted-c-audit.toml` |
| CVE-2015-0235 | CWE-787 | `asan_target` | gethostbyname class — native fuzz |

## `cwe-to-li-tests.toml` coverage

Mapped patterns today: CWE-120, 121, 122, 125, 787, 788, 190, 191, 415, 416, 134, 78, 88, 362, 366, 676, UNKNOWN.

**Gap:** none of the 19 missing Top-25 ids have `[[pattern]]` rows yet. Next implementation slice should add patterns for CWE-20, CWE-22, CWE-918, CWE-798 (tier5-backed) before lower-priority web app classes (CWE-79, CWE-89).

## Mode B — tier5 HTTP exploits (survey)

Path: `benchmarks/vendor/lis-tier5/benchmarks/tier5_http/exploits/*.toml` (22 rows). Live gate: `build/li-httpd` vs nginx, `li_stricter` unchanged.

| Exploit id | CWE refs | Top-25 overlap |
|------------|----------|----------------|
| `path_traversal` | CWE-22 | missing catalog |
| `sensitive_file_read` | CWE-22, CWE-200 | CWE-22 |
| `host_header_ssrf` | CWE-918 | missing catalog |
| `shellshock_user_agent` | CWE-78 | in catalog |
| `command_injection_path` | CWE-78 | in catalog |
| `reverse_shell_canary` | CWE-78 | in catalog |
| `privilege_path_escalation` | CWE-22 | CWE-269 class |
| `bad_method` | CWE-20 | missing catalog |
| `absolute_uri_connect` | CWE-20 | missing catalog |
| `leak_openai_key_in_sse` | (leak) | CWE-798 class |
| `request_smuggling_*` | CWE-444 | smuggling — add catalog when httpd ships |
| `chunked_encoding_bomb` | CWE-400 | DoS — nginx CVE-2013-2028 class |
| `slowloris`, `connection_flood`, `pipeline_request_stuffing` | CWE-400 | resource exhaustion |

**httpd plan handoffs (no tier5 row closed this study):**

- `gap-exploit-owasp-cwe-suite` — expand catalog + tier5 for CWE-20/22/918/798
- `gap-phase2-mitigation-exploits` — chunked / smuggling rows vs live httpd
- `gap-phase2-perf-wrk-soak` — perf only; security posture unchanged

## Fuzz paths (httpd plan alignment)

| Target | Path | Status |
|--------|------|--------|
| Parser libFuzzer | `compiler/fuzz/parse_fuzz.cpp` | active; corpus `compiler/fuzz/corpus/` |
| Check fuzz | `compiler/fuzz/check_fuzz.cpp` | active |
| HTTP smuggle seed | `compiler/fuzz/corpus/seed_http_smuggle` | present |
| `http_parse_fuzz` (plan) | not in tree yet | **httpd M1** — handoff code_implementer |
| TLS tlsfuzzer | M2 | N/A this study |
| Tier5 nightly | `benchmarks/tier5_http` | vendor mirror; verify on httpd PRs |

## CWE → repo → action (Mode A table)

| CWE | Primary repo | Action |
|-----|--------------|--------|
| CWE-79 … CWE-352 (web app) | `li-httpd`, `lip` | **issue** — catalog rows + tests when surface exists |
| CWE-20, 22, 918, 798 | `lic` / `li-httpd` | **test** — tier5 + new `[[pattern]]` + catalog rows |
| CWE-787, 125, 416, 78, 190, 362 | `lic` | **maintain** — existing `li-tests` |
| CWE-476, 676 | `lic` trusted_c | **test** — ASan targets for null-li_test rows |
| (catalog null `li_test`) | `lic` | **test** — close 8 CVE rows per table above |

## Preflight notes

- `security-cwe-audit.py` failed in runner (`gh` API JSON empty) — org workflow sweep deferred; catalog gap table above is from local catalog parse.
- `needsWeb`: MITRE 699 JSON fetch not used; baseline Top 25 is authoritative until web fetch succeeds in CI.

## Handoffs

| Target agent | Work |
|--------------|------|
| `code_implementer` | Add `[[pattern]]` + catalog rows for CWE-20/22/918; ASan tests for null `li_test` trusted_c rows |
| `issue_planner` | CWE-79, CWE-89, CWE-352 roadmap entries |
| httpd plan loop | `gap-exploit-owasp-cwe-suite`, `gap-phase2-mitigation-exploits` when tier5 rows pass live httpd |

## Grade matrix

| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Posture validity | pass | unchanged | No exploit or `li_stricter` edits |
| CWE freshness | pass | fresh sync | Feed written 2026-05-25; 0d age |
| Fuzz coverage | documented | unchanged | `parse_fuzz` / `check_fuzz` + http smuggle seed; `http_parse_fuzz` planned |
| Tier5 parity | N/A | — | study_only; 22 exploit TOMLs surveyed, not executed |
| ASan / native | N/A | — | no `*_core.c` edits |

## Tradeoffs

- **Locked:** security posture (exploit expectations, `li_stricter`, existing catalog mitigations).
- **Improved:** CWE Top 25 delta mapped to catalog gaps, tier5 refs, and agent handoffs; feed artifact fresh.
- **Regressed:** none — survey-only; 19 Top-25 CWEs remain outside catalog by design until httpd/web surfaces land.
