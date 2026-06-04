# Swarm gap orchestration — security dimension

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `9b2781d3`  
**Date:** 2026-06-04  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/`  
**north_star_fit:** Ecosystem orchestration for secure Li — proof-before-perf; no unproved shortcuts in security claims.

---

## Abstract

This pass audits the Li agent swarm through a **security lens** for Mode B gap orchestration: registry ingest, backlog apply, and handoffs to `security_auditor` without product code changes in `lic`. The swarm is **degraded**: CWE catalog coverage lags MITRE Top 25, the `security-research` plan runner is stopped, and briefing/heap dispatch diverge on `security_auditor`. Gap pipeline blockers (ingest syntax, missing PyYAML) were remediated in-container; 62 open gaps remain org-wide.

---

## 1. Threat-model alignment (ecosystem)

Li’s north star orders **provability → easy → fast**. Security orchestration must not trade proof for perf narratives:

| Pillar | Security implication |
|--------|----------------------|
| Provable | CVE/catalog entries need traceable CWE→test mapping; defer `trusted.lean` |
| Easy | Agent JSON diagnostics (`lic check --format=json`) support auditor workflows |
| Fast | httpd tier5 exploit parity only after mitigations are proven stricter-or-equal |

---

## 2. CWE catalog gap analysis

**Source:** `benchmarks/data/latest/security-cwe-feed.json` (2026-06-04T10:30Z)

| Metric | Value |
|--------|------:|
| Top 25 baseline | 25 |
| Represented in `cve-catalog.json` | 15 |
| Missing in catalog | 19 |

Representative missing CWEs: CWE-79 (XSS), CWE-89 (SQLi), CWE-20 (input validation), CWE-22 (path traversal), CWE-352 (CSRF), CWE-502 (deserialization), CWE-918 (SSRF).

**Recommendation:** Human-gated PR to `lic/security/cve-catalog.json` with li-tests rows per CWE class; `security_auditor` drafts issues, does not auto-merge.

---

## 3. Security-research plan debt

**Backlog:** `lic/docs/ecosystem/security-research-backlog.md`

| Todo | Status | Gap registry id |
|------|--------|-----------------|
| sec-r0-cwe-delta | completed | closed |
| sec-r1-httpd-fuzz-smoke | pending | `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` |
| sec-r2-tier5-gap-exploit | pending | `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` |
| sec-r3-runtime-surface | pending | `gap-plan-pending-security-research-sec-r3-runtime-surface` |

**Snapshot:** `security-research` runner `running: false`, `status_note: supervisor off`, log age ~4.6 days.

**Swarm routing:** Dispatch `security_auditor` under goal `offensive_security` (see `li-cursor-agents/config/research-goals.yaml`) — not a new lic systemd loop.

---

## 4. Swarm control-plane findings

| Finding | Severity | Remediation owner |
|---------|----------|-------------------|
| Heap dispatches `ci_maintainer` only; ignores `security_auditor` | high | `li-cursor-agents` heap |
| `li-sec-agent` repo 404 in org CI audit | high | human + `ci_maintainer` |
| 21 benchmarks PRs CI-failing | high | `ci_maintainer`, `bug_fixer` |
| Gap ingest syntax (L229) | high | **fixed** `lic/scripts/swarm-gap-ingest.py` |
| Missing PyYAML in Job | medium | `li-cursor-agents` deploy image |
| Control-plane state not on disk | medium | persist `latest-report.json` on Job exit |

---

## 5. Evidence index

| Artifact | Path |
|----------|------|
| Ecosystem scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Agent briefing | `/workspace/benchmarks/data/latest/agent-briefing.json` |
| CWE feed | `/workspace/benchmarks/data/latest/security-cwe-feed.json` |
| Gap actions | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| Observer digest | `/app/data/runs/swarm_observer-1780567295917.md` |
| Orchestrator note | `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-04-orch-swarm-coverage-security.md` |

---

## 6. Conclusion

Security-oriented swarm coverage is **not unattended-safe** until: (1) CWE catalog gaps are staffed via `security_auditor`, (2) `security-research` todos advance or migrate fully to the agents plane, (3) CI/metrics PR wave unblocks fresh scorecards, and (4) control-plane heap aligns with briefing P0 signals. Gap orchestration infrastructure is **operational** after this pass’s ingest/apply remediation.

---

_Staging copy for research-findings publish — li-langverse swarm_observer 2026-06-04_
