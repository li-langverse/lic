# Security research runner — sec-r1 / sec-r2 / sec-r3 closure

> **Issue:** [#521](https://github.com/li-langverse/lic/issues/521) · **Repo:** li-langverse/lic  
> **Vision:** **Secure** (CWE-informed, tier5 stricter-or-equal vs nginx), **Provable** (no posture trade for fuzz throughput)  
> **North star fit:** web/agent-gateway security surface (**PH-H**), offensive research goal `offensive_security`  
> **Learned from:** [httpd plan § fuzz + exploits](2026-05-16-li-httpd-plan.md), [offensive-r0 SOTA survey](../../security/studies/2026-05-27-offensive-r0-sota-survey.md), [security-research-grading.md](../../ecosystem/security-research-grading.md), [webserver-security.md](../../testing/webserver-security.md)

## Goal

Unblock the stalled `security-research` goal-directed runner (supervisor off since 2026-05-25; `sec-r1` last `agent_exit=1`) by **splitting sec-r1/2/3 into three scoped, plan-approved implementation tracks** instead of restarting the loop without gates. Each track ships a study + gates evidence, closes its `gap-plan-pending-security-research-*` registry row, and advances **PH-H** exploit/fuzz posture without weakening `li_stricter` or `threshold_ratio_cpp`.

## Non-goals

- Restarting `security-research-plan-loop` before **`plan-approved`** on #521 and this plan merged.
- Weakening tier5 `[expect]` rows, `li_stricter`, or CVE catalog honesty to green gates.
- Editing `trusted.lean` (human-approved issues only).
- Claiming **G-*** closure — CWE/tier5 parity stays **Partial** until measured live-vs-nginx evidence lands.
- Full 24h fuzz soak or perf wrk parity (tracked under httpd `gap-phase2-perf-wrk-soak`, separate issue #477).

## Dependencies

| Blocker | Owner | Notes |
|---------|-------|-------|
| **sec-r0** complete | — | `sec-r0-cwe-delta` done (`gates_ok=true`); SOTA survey merged (#347) |
| **benchmarks** sibling | harness | `tier5_http/exploits/*.toml`, `nginx_mitigations.toml`, `security-cwe-feed.json` |
| **PH-H** httpd runtime | httpd loop | Live `build/li-httpd` for tier5 smoke; config-only oracles insufficient |
| Registry ingest | #436, #471, #473 | `plan_debt` close semantics; not blocking plan approval |
| Supervisor infra | li-cursor-agents | Mount `LIC_ROOT` + `BENCHMARKS_ROOT` on org-research Jobs (parallel track) |

## Sub-phases (one PR per todo after plan-approved)

### A — `sec-r1-httpd-fuzz-smoke` (study-only gate)

**Deliverable:** Standalone HTTP parse fuzz **smoke** path documented + CI-visible; tier5 exploit **smoke subset** vs live li-httpd.

| Step | Work | Exit gate |
|------|------|-----------|
| A1 | Inventory HTTP parse entrypoints (`packages/li-http/`, `li-httpd` native parser, `http_parse_forward_closed.li` witness) | Table in study `docs/security/studies/YYYY-MM-DD-sec-r1-httpd-fuzz-smoke.md` |
| A2 | Add **`http_parse_fuzz`** libFuzzer target (CMake sibling to `compiler/fuzz/parse_fuzz.cpp`) with seed corpus under `compiler/fuzz/corpus/` (`seed_http_smuggle`, request-line overlong) | `cmake --build build-fuzz --target http_parse_fuzz` succeeds; 60s smoke in CI or `HTTPD_FUZZ_SMOKE=1` gate |
| A3 | Wire smoke into `scripts/security-research-gates.sh` when todo active: fuzz binary runs ≤120s, no crash; document nightly full soak deferral | `./scripts/security-research-gates.sh` exit 0 with `SECURITY_RESEARCH_BACKLOG_STUDY_ONLY=1` |
| A4 | Tier5 exploit smoke: `exploit_http.py --profile pr --compare-nginx` on **3-row subset** (smuggling, path traversal, slowloris) against live `build/li-httpd` | CSV artifact; no nginx-pass/li-fail regression |
| A5 | Update [security-research-backlog.md](../../ecosystem/security-research-backlog.md) todo → `completed`; close `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` via ingest | Registry row `status: closed` |

**REQ mapping:** REQ-SEC-FUZZ-1 (documented fuzz paths per grading contract).

### B — `sec-r2-tier5-gap-exploit` (live parity)

**Deliverable:** Close **one** highest-priority tier5 / CWE gap from [offensive-r0 SOTA survey](../../security/studies/2026-05-27-offensive-r0-sota-survey.md) Top25 table — catalog row + exploit TOML + live stricter-or-equal vs nginx.

| Step | Work | Exit gate |
|------|------|-----------|
| B1 | Pick row: prefer **CWE-20** (input validation) or **CWE-862** (missing authorization) — both missing from `cve-catalog.json` per r0 survey | Issue comment records choice + nginx `mitigation_id` |
| B2 | Add `security/cve-catalog.json` entry + `security/cwe-to-li-tests.toml` pattern (compile-fail or httpd N/A doc) | `./scripts/check-cve-catalog.sh` green |
| B3 | Add `benchmarks/tier5_http/exploits/<slug>.toml` + link in `nginx_mitigations.toml`; `[expect] li_behavior = "stricter"` | `check-tier5-mitigation-exploits-complete.sh` green |
| B4 | Live compare: `exploit_http.py --profile pr --compare-nginx --fail-on-regression` on new row | `results/exploit_report.csv` row green |
| B5 | Study `docs/security/studies/YYYY-MM-DD-sec-r2-tier5-gap-exploit.md` with grade matrix | `./scripts/security-research-gates.sh` exit 0 (non-study-only) |
| B6 | Close registry gap `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | Ingest + backlog todo `completed` |

**REQ mapping:** REQ-SEC-EXPLOIT-1 (tier5 stricter-or-equal); **PH-H** `m1-exploit-runtime` evidence extension.

### C — `sec-r3-runtime-surface` (ASan slice)

**Deliverable:** Runtime attack-surface inventory for **parse / crypto / HTTP native cores** + ASan gate when `*_core.c` touched.

| Step | Work | Exit gate |
|------|------|-----------|
| C1 | Inventory native seams: `compiler/*`, `packages/li-rng/*_core.c`, `packages/li-tls/*`, `packages/li-net-httpd/*_core.c` | Surface table in study |
| C2 | Extend `li-tests/security/` with ASan smoke script (`run_security_asan_slice.sh`) covering touched cores from A/B PRs | Script exit 0 on Linux CI slice (`LI_SECURITY_ASAN=1`) |
| C3 | Document crypto/HTTP invariants (no duplicate IV, bounded header parse) tied to existing tier5 RNG rows | Study links tier5 `rng_*` + httpd Lean witnesses |
| C4 | `./scripts/security-research-gates.sh` sets `asan_ok` from slice when native diff detected | `grade.json` shows `asan_ok: true` |
| C5 | Close `gap-plan-pending-security-research-sec-r3-runtime-surface` | Backlog todo `completed` |

**REQ mapping:** REQ-SEC-NATIVE-1 (ASan on native touch); defers full TSan to compiler-only CI.

## Tests / benches

| Artifact | Path | When |
|----------|------|------|
| Parser fuzz smoke | `compiler/fuzz/http_parse_fuzz.cpp`, `.github/workflows/fuzz.yml` | sec-r1 PR |
| Fuzz corpus merge | `scripts/merge_fuzz_corpus.sh` | sec-r1 (reuse existing nightly bot) |
| Tier5 exploit harness | `benchmarks/harness/exploit_http.py`, `tier5_http/exploits/*.toml` | sec-r1 smoke + sec-r2 row |
| Mitigation linkage | `scripts/check-tier5-mitigation-exploits-complete.sh` | sec-r2 PR |
| Security CI | `scripts/ci-security.sh`, `li-tests/run_security.sh` | all tracks |
| CWE feed | `benchmarks/scripts/security-cwe-feed-sync.py` | hard gate ≤7d (existing) |
| Research gates | `scripts/security-research-gates.sh` | every loop iteration |

## Provability / G-* updates

| Gap | Move | Evidence |
|-----|------|----------|
| **G-sec** (new register row) | Open → **Partial** | Document in `provability-gaps.md` — fuzz smoke + one tier5 row live |
| **PH-H** | Partial → Partial+ | Fuzz table row + tier5 row closure; not full OWASP suite |
| **G-lean** | unchanged | No new `trusted.lean`; httpd Lean gate unchanged |

No **G-*** row closes to Done until dashboard + live exploit CSV show stricter-or-equal on assigned rows.

## Rollout

1. **This PR** — plan doc + backlog content refresh (no product code).
2. Human adds **`plan-approved`** on #521; remove **`plan-needed`**.
3. **Implementation PRs** (sequential, one todo each):
   - PR-1: sec-r1 (`plan(security): http_parse_fuzz smoke + tier5 subset`) — branch `cursor/security-research-sec-r1`
   - PR-2: sec-r2 (`feat(security): tier5 CWE-20/862 row + catalog`) — after PR-1 merged or parallel if no file conflict
   - PR-3: sec-r3 (`feat(security): ASan native slice + surface study`) — may combine with PR-2 if same native files
4. After PR-3: human may restart `security-research-plan-loop` (supervisor) or leave runner idle — todos should read `completed` in snapshot.
5. Swarm-gap ingest closes three `gap-plan-pending-security-research-*` rows (#471 semantics).

## Human-only

- [ ] Label **`plan-approved`** on #521 before any codegen agent runs.
- [ ] Approve CWE row choice for sec-r2 (B1) if auth surface affects production gateway policy.
- [ ] Restart `li-security-research-plan-loop.service` after all three todos complete (optional — scoped PRs preferred).
- [ ] Merge registry conflict fix (#436) before relying on automated gap close.

## Runner recovery (orchestration)

Prefer **scoped PRs with plan-approved gates** over blind supervisor restart:

```bash
# After plan-approved — one iteration per todo (local smoke)
SECURITY_RESEARCH_BACKLOG_STUDY_ONLY=1 ./scripts/security-research-gates.sh  # sec-r1 study path
./scripts/security-research-plan-loop.py --once --todo sec-r1-httpd-fuzz-smoke  # after PR-1
```

Do **not** run codegen in plan loop until `plan-approved` present on #521.
