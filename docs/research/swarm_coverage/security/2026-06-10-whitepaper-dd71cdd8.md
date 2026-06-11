# Swarm gap orchestration — security dimension

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `dd71cdd8`  
**Agent:** `swarm_observer`  
**Generated:** 2026-06-10T23:22Z  
**north_star_fit:** ecosystem, ai (orchestration); security lens: secure pillar  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/` (staged; repo not mounted)

---

## Abstract

This pass audits whether the Li agent **swarm** can orchestrate security-related gap closure without human intervention. Execution health is good (zero error runs sampled, `CURSOR_API_KEY` present) but **gap ingest remains blocked** (PyYAML), **CWE catalog coverage is incomplete** (19/25 MITRE Top-25 missing), and **`security_auditor` is recommended but not dispatched** despite briefing P0. Security plan_debt rows (`sec-r1`–`sec-r3`) are correctly patched to backlogs but require handoff via the `offensive_security` research goal — not retired systemd loops.

---

## Method

1. Scorecard: `ecosystem-quality-grade.py` @ 23:21Z → grade C (75.6), `unattended_safe: true`
2. Briefing: `agent-briefing.json` @ 23:20Z — recommends `ci_maintainer`, `security_auditor`
3. CWE feed: `security-cwe-feed.json` @ 23:17Z vs `lic/security/cve-catalog.json`
4. Gap registry: 62 open rows; security-research plan_debt subset
5. Dry-run: `swarm-gap-ingest.py` / `swarm-gap-apply-actions.py` (PyYAML failure @ 23:21Z)
6. Control plane: `state.json` / `latest-report.json` absent under `/app/data/control-plane/`

---

## Findings

### 1. CWE catalog gap (high)

| Metric | Value |
|--------|-------|
| Top-25 baseline | 25 |
| Catalog rows | 15 |
| Missing in catalog | **19** |

Representative missing: CWE-79 (XSS), CWE-89 (SQLi), CWE-352 (CSRF), CWE-798 (hardcoded credentials).

**Implication:** `security_auditor` cannot close the org security scorecard until catalog backfill is human-approved.

### 2. Security plan_debt routing (medium)

Three `security-research` runner todos remain open. Apply-actions (14:45Z) patched them to `security-research-backlog.md`. Orchestration policy:

- Route via `config/research-goals.yaml` → `offensive_security` → `security_auditor`
- Do **not** spawn `security-research` systemd plan loop

### 3. Goal-orientation drift (medium)

| Source | Recommended agents |
|--------|-------------------|
| Briefing heap | `ci_maintainer` only |
| Briefing recommended_agents | `ci_maintainer`, `security_auditor` |
| Scorecard recommended_agents | `gap_explorer`, `ci_maintainer`, `plan_verifier`, `security_auditor` |
| Recent runs | `swarm_observer` only (this pass) |

### 4. Gap ingest dependency (high)

Without PyYAML, registry cannot refresh from goal-directed snapshots. Security gaps discovered after 14:45Z are invisible to apply-actions.

### 5. Control-plane observability (medium)

Missing CP disk mirrors prevent auditing `observer.retry_counts` and `stopped_agents` across Job pods — a meta-security concern for unattended operation.

---

## Recommendations

1. **Image:** add `python3-yaml` to org-research worker image
2. **Dispatch:** enqueue `security_auditor` for CWE delta + `sec-r1` httpd fuzz via `offensive_security` goal
3. **Governance:** human PR for `cve-catalog.json` Top-25 backfill
4. **Briefing:** merge scorecard recommendations into heap (`swarm-recommendations.ts`)
5. **CP:** persist observer state each supervisor tick

---

## Evidence paths

| Artifact | Path |
|----------|------|
| Scorecard | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| CWE feed | `/workspace/benchmarks/data/latest/security-cwe-feed.json` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| Security backlog | `/workspace/lic/docs/ecosystem/security-research-backlog.md` |
| Full report | `/app/data/runs/swarm_observer-1781130788042.md` |
