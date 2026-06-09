# Swarm coverage — security dimension whitepaper

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Date:** 2026-06-06  
**Worker:** `fe7061e7`  
**north_star_fit:** ecosystem, ai — orchestration secures the swarm; security gaps route to proved offensive research, not ungoverned auto-merge.

---

## Abstract

This pass audits swarm gap orchestration through a **security lens**: CWE catalog completeness, security-research plan debt, tier-db security bench posture, and control-plane blockers that prevent unattended security dispatch. The ecosystem scorecard is **62.6 / D** with `unattended_safe: false`. Nineteen MITRE CWE Top 25 classes are absent from `lic/security/cve-catalog.json`. Three `security-research` backlog todos remain pending and should route via the `offensive_security` research goal to `security_auditor`, not retired systemd loops.

## Key findings

### 1. CWE catalog gap (P0)

| Signal | Value | Evidence |
|--------|-------|----------|
| Catalog CWE count | 15 | `security-cwe-feed.json` |
| Top25 missing | 19 | `security-cwe-feed-delta.json` |
| New vs previous sync | 0 | feed stable @ 2026-06-06T09:38Z |

Representative missing classes: CWE-79 (XSS), CWE-89 (SQLi), CWE-20 (input validation), CWE-352 (CSRF), CWE-918 (SSRF). These require human-gated catalog entries and `li-tests` mapping — route to `security_auditor` + `issue_planner`.

### 2. Security plan_debt gaps (P1)

Open registry rows patch to `security-research-backlog.md`:

- `sec-r1-httpd-fuzz-smoke` — httpd fuzz smoke (study_only)
- `sec-r2-tier5-gap-exploit` — tier5 exploit expansion
- `sec-r3-runtime-surface` — runtime attack surface survey

Snapshot runner `security-research` is **stopped** (snapshot 2026-05-30); active todo `sec-r1-httpd-fuzz-smoke`. Dispatch via research lane:

```yaml
# config/research-goals.yaml
- id: offensive_security
  agent: security_auditor
  priority: 9
  cadence_hours: 12
```

### 3. Tier-db security bench (P2)

`tier-db-security.json` status **stub** — scenarios `injection_blocked` and `rls_bypass_blocked` have no engine results. Links to `wp-n5-security-bench` plan_debt (deferred — no backlog mapping).

### 4. Control-plane security of orchestration

| Blocker | Impact |
|---------|--------|
| PyYAML missing | Gap ingest/apply cannot run; security backlog patches stale |
| CP state absent | Observer retry ledger unavailable |
| `security_cwe_audit` skipped | Preflight `--skip-slow` hides CWE regression |
| 36 failed PRs | Metrics/security refresh PRs (#365–#375) blocked on CI |

## Recommendations

1. **Immediate:** Dispatch `security_auditor` on `offensive_security` for `sec-r1-httpd-fuzz-smoke`.
2. **Image:** Add `python3-yaml` to org-research Job; re-run ingest/apply.
3. **Catalog:** Human-gated PR mapping 19 CWE Top25 into `cve-catalog.json`.
4. **Preflight:** Enable `security_cwe_audit` on security-dimension `swarm_coverage` runs.
5. **CI:** `ci_maintainer` for 6 repos missing main workflow before expanding security gates.

## Links

- Run digest: `/app/data/runs/swarm_observer-1780736988612.md`
- Orchestrator note: `lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r6-security-fe7061e7.md`
- Scorecard: `benchmarks/data/latest/ecosystem-quality-report.json`
- CWE feed: `benchmarks/data/latest/security-cwe-feed.json`

**Publish target (out of band):** `research-findings/whitepapers/2026-06/swarm_coverage/security/2026-06-06-whitepaper.md`
