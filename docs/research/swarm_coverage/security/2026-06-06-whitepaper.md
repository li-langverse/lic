# Swarm gap orchestration — security dimension audit

**Goal id:** `swarm_coverage`  
**Dimension:** `security`  
**Agent:** `swarm_observer`  
**Run id:** `swarm_observer-1780745989625`  
**Generated:** 2026-06-06T12:20Z  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai  
**Validity grade:** C (orchestration audit; blocked on ingest script)

---

## Abstract

This whitepaper documents the **security lens** of swarm gap orchestration for the Li agent control plane. The swarm is **not unattended-safe** (ecosystem grade **D**, 62.6) because gap ingest is broken and CWE catalog coverage lags the Top 25 feed. We reconcile four open `security-research` plan_debt registry rows, quantify **19 missing CWE catalog entries**, and route work through existing research goals (`offensive_security` → `security_auditor`) without reviving retired systemd plan loops.

---

## 1. Threat model for the swarm control plane

| Surface | Risk | Mitigation in Li policy |
|---------|------|-------------------------|
| Agent SDK credentials | Key exfil via run logs | `CURSOR_API_KEY` env-only; no commit of secrets |
| Auto-merge of security PRs | Weakening tier5 / CWE gates | Observer + `pr_merger` gates; human-only on exploit policy |
| Stale gap registry | Agents work on wrong backlog | `swarm-gap-ingest.py` + apply pipeline (currently broken) |
| Skipped security preflight | Missing CWE audit when P0 | Briefing recommends `security_auditor` but `security_cwe_audit` skipped |
| Ghost repo CI audit | False "missing CI" signals | 6 repos return HTTP 404 — pollutes `ci_maintainer` queue |

---

## 2. CWE Top 25 catalog gap analysis

**Source:** `/workspace/benchmarks/data/latest/agent-briefing.json` → `cwe_feed_delta` (2026-06-06T12:19Z)

| Metric | Value |
|--------|-------|
| Top 25 in feed | 25 |
| New vs previous | 0 |
| Missing in `cve-catalog.json` | **19** |

Representative missing CWEs: CWE-79 (XSS), CWE-89 (SQLi), CWE-20 (input validation), CWE-22 (path traversal), CWE-352 (CSRF), CWE-502 (deserialization), CWE-798 (hard-coded credentials).

**Interpretation:** Feed sync runs (`security-cwe-feed-sync.py` exit 0) but catalog backfill lags. `sec-r0-cwe-delta` is **completed** in the goal-directed snapshot; remaining gap is **implementation** (catalog + tests), not feed ingestion.

**Recommended handoff:** `security_auditor` under goal `offensive_security` — one study per CWE cluster mapping to `li-tests/security/*` and `cve-catalog.json`.

---

## 3. Security-research plan_debt registry

| Todo | Registry gap id | Backlog status | Next owner |
|------|-----------------|----------------|------------|
| sec-r0-cwe-delta | `gap-plan-pending-security-research-sec-r0-cwe-delta` | completed | Close on ingest |
| sec-r1-httpd-fuzz-smoke | `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | pending | `security_auditor` |
| sec-r2-tier5-gap-exploit | `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | pending | `security_auditor` |
| sec-r3-runtime-surface | `gap-plan-pending-security-research-sec-r3-runtime-surface` | pending | `security_auditor` |

Runner `security-research`: `running: false` (snapshot @ 2026-05-30). Issue lic#521 tracks supervisor gap.

**Orchestration rule:** Route via `config/research-goals.yaml` → `offensive_security` (agent `security_auditor`). Do **not** install `security-research` systemd loop.

---

## 4. Gap pipeline failure (blocking)

```
SyntaxError: unterminated string literal — swarm-gap-ingest.py:229
swarm-gap-apply-actions: PyYAML required
```

Fix path: merge **lic#904**; add PyYAML to org-research worker image.

Until fixed, registry rows from 2026-05-31 remain authoritative; apply patches for sec-r1/2/3 are **stale confirmations** only.

---

## 5. Swarm health summary (security-relevant)

| Dimension | Score | Security note |
|-----------|-------|---------------|
| ecosystem_posture | 52 | 32 failed PRs include security-grade refresh attempts |
| briefing_health | 69 | `security_cwe_audit` skipped |
| gap_pressure | 60 | 4 security plan_debt rows among 64 open |
| swarm_execution | 65 | `runs_sampled: 0` — observer blind |

**Overall:** 62.6 grade **D**, `unattended_safe: false`.

---

## 6. Conclusions and handoffs

1. **Merge lic#904** before next gap orchestration cycle.
2. **Dispatch `security_auditor`** for CWE catalog backfill (19 rows) and sec-r1/2/3 backlog todos.
3. **Enable `security_cwe_audit`** on supervisor tick when `missing_in_catalog > 0`.
4. **Close sec-r0** registry row on successful ingest (snapshot already complete).
5. **Human triage** benchmarks PR stack #371–#378 to stop CI noise on grade refresh.

---

## Links

| Artifact | Path |
|----------|------|
| Observer digest | `/app/data/runs/swarm_observer-1780745989625.md` |
| Orchestrator note | `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r5-security-cwe-handoffs.md` |
| Security backlog | `/workspace/lic/docs/ecosystem/security-research-backlog.md` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| CWE feed | `/workspace/benchmarks/data/latest/security-cwe-feed.json` |
| Ecosystem scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |

---

## artifacts.json (staging)

```json
{
  "goal_id": "swarm_coverage",
  "slug": "2026-06-06-security-gap-orchestration",
  "title": "Swarm gap orchestration — security dimension audit",
  "agent": "swarm_observer",
  "run_id": "swarm_observer-1780745989625",
  "generated_at": "2026-06-06T12:20:00Z",
  "domains": ["ecosystem", "ai"],
  "validity_grade": "C",
  "status": "staging",
  "markdown_path": "whitepapers/2026-06/swarm_coverage/2026-06-06-security-gap-orchestration/README.md",
  "dimension": "security",
  "north_star_fit": "Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai"
}
```
