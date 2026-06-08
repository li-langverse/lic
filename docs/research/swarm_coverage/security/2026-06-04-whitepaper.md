# Swarm coverage — security dimension (2026-06-04)

**Goal:** `swarm_coverage`  
**north_star_fit:** ecosystem, ai — secure pillar (proof → easy → fast)  
**Worker:** `0ce8605b`  
**Evidence bundle:** `benchmarks/data/latest/security-cwe-feed.json`, `lic/docs/ecosystem/security-research-backlog.md`, `benchmarks/data/latest/swarm-gap-actions.json`

---

## 1. Security posture summary

The Li org maintains a **CWE catalog** (`lic/security/cve-catalog.json`) synced against a MITRE Top25 baseline (`benchmarks/scripts/security-cwe-feed-sync.py`). As of **2026-06-04T16:12Z**:

| Signal | Value | Severity |
|--------|-------|----------|
| Catalog CWE count | 15 | — |
| Top25 missing in catalog | **19** | high |
| Repos missing security workflow (briefing) | 0 | — |
| `sec-r1` httpd fuzz smoke | pending | high |
| `sec-r2` tier5 gap exploit | pending | high |
| `sec-r3` runtime surface | pending | high |

Briefing and scorecard both recommend **`security_auditor`**; compact heap currently prioritizes **`ci_maintainer`** only — orchestration drift risks starving the security lane.

---

## 2. Gap orchestration (security `plan_debt`)

Swarm gap apply patched three security-research todos to `lic/docs/ecosystem/security-research-backlog.md`:

- `sec-r1-httpd-fuzz-smoke` — HTTPd fuzz / smoke parity with tier5 gates  
- `sec-r2-tier5-gap-exploit` — close remaining tier5 exploit rows vs nginx  
- `sec-r3-runtime-surface` — runtime attack surface audit on Li HTTP stack  

**Routing:** enqueue via research goal `offensive_security` (`security_auditor` agent) — **not** a new lic systemd loop (`docs/ecosystem/swarm-architecture.md`).

---

## 3. Ecosystem blockers affecting security signals

1. **32 open PRs with failing CI** — predominantly `benchmarks` PH-5b catalog honesty (#266 family). Until merged, vertical ingest and benchmark honesty gates stay stale.  
2. **3 repos missing CI on main** (ecosystem audit) — includes security-adjacent tooling; `org_ci_audit` incomplete (GitHub API 403 rate limit).  
3. **Control plane disk cache empty** on org-research host — no `observer.retry_counts`; meta-audits cannot see programmatic self-heal.  
4. **`security_cwe_audit` preflight skipped** (`--skip-slow`) — full CWE narrative deferred to `security_auditor` runs.

---

## 4. Recommended dispatch order

1. `security_auditor` — expand `cve-catalog.json` for 19 Top25 gaps (human review on PR).  
2. `security_auditor` — execute `sec-r1` (httpd fuzz smoke) under `offensive_security`.  
3. `ci_maintainer` — add CI on repos missing `ci.yml` on main; unblock metrics PR CI.  
4. `gap_explorer` — reconcile 62 open registry rows after catalog merge.  
5. `plan_verifier` — re-enable `plan_audit` preflight when `LIC_ROOT` stable.

---

## 5. Provability alignment

Security work must not weaken proof gates: fuzz/exploit rows remain **study-only** in backlog until `lic build` / tier5 gates document stricter-or-equal vs nginx. No `trusted.lean` changes via agents.

---

_Publish target: `research-findings/whitepapers/2026-06/swarm_coverage/security/2026-06-04-whitepaper.md`_
