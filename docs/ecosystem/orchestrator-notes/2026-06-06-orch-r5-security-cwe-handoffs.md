# Orchestrator note — `orch-r5-security-cwe-handoffs`

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Research dimension:** `security` (worker `8329f0a1`)  
**Work item:** Reconcile security-research plan_debt + CWE Top 25 catalog gaps; route via swarm goals (no systemd loop)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (critical path)** — grade **D** (62.6); `unattended_safe: false` |
| Gap prep | **Blocked** — `swarm-gap-ingest.py` SyntaxError L229; apply needs PyYAML |
| CWE delta | **19/25** Top 25 CWEs missing from `cve-catalog.json` |
| Security runner | **Stopped** — `sec-r1`/`sec-r2`/`sec-r3` pending in backlog |
| Unattended? | **No** — merge **lic#904** + PyYAML + dispatch `security_auditor` before security gaps close |

Programmatic prep attempted @ 2026-06-06T12:20Z — **ingest/apply failed** (see error block below).

---

## Security `plan_debt` reconciliation

| Registry id | Backlog todo | Snapshot status | Handoff |
|-------------|--------------|-----------------|---------|
| `gap-plan-pending-security-research-sec-r0-cwe-delta` | `sec-r0-cwe-delta` | **completed** | Close registry row on next ingest |
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `sec-r1-httpd-fuzz-smoke` | pending | `security_auditor` (`offensive_security`) |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `sec-r2-tier5-gap-exploit` | pending | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `sec-r3-runtime-surface` | pending | `security_auditor` |
| `gap-plan-pending-ph-db-wp-n5-security-bench` | `wp-n5-security-bench` | pending (ph-db) | `issue_planner` |

Backlog evidence: `docs/ecosystem/security-research-backlog.md` (sec-r1/2/3 `status: pending`).

Prior apply patches (2026-05-31, stale until ingest re-runs):

- `sec-r1-httpd-fuzz-smoke` → pending in `security-research-backlog.md`
- `sec-r2-tier5-gap-exploit` → pending
- `sec-r3-runtime-surface` → pending

---

## CWE catalog gap orchestration

**Signal:** `agent-briefing.cwe_feed_delta` @ 2026-06-06T12:19Z

- Feed sync: `top25=25`, `new_cwes=[]`
- **Missing in catalog:** CWE-79, CWE-89, CWE-20, CWE-22, CWE-352, CWE-434, CWE-862, CWE-476, CWE-287, CWE-502, CWE-77, CWE-119, CWE-798, CWE-918, CWE-306, CWE-269, CWE-94, CWE-863, CWE-276

**Routing (swarm goals, not lic systemd):**

| Agent | Goal | Action |
|-------|------|--------|
| `security_auditor` | `offensive_security` | Study: map each missing CWE → catalog row + `li-tests/security/*` |
| `issue_planner` | — | Issues for catalog gaps that need human PH approval |
| `swarm_observer` | `swarm_coverage` | Re-audit after lic#904 merge + ingest refresh |

**Preflight gap:** `security_cwe_audit` skipped (`--skip-slow`) while briefing P0 recommends `security_auditor` — supervisor should not skip when `missing_in_catalog.length > 0`.

---

## Scripts attempted

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
# OK: grade D 62.6

cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
# FAIL: SyntaxError line 229

cd /workspace/lic && python3 scripts/swarm-gap-apply-actions.py
# FAIL: PyYAML required
```

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `pr_merger` | Merge **lic#904** — unblocks gap ingest |
| `security_auditor` | Briefing P0: 19 CWE catalog gaps; sec-r1/2/3 backlog |
| `ci_maintainer` | 6 repos missing CI; 32 failed PRs |
| `plan_verifier` | Refresh plan audit (skipped preflight) |

Research goals (no registry id changes):

- `swarm_coverage` → `swarm_observer` (this note)
- `offensive_security` → `security_auditor` (sec-r* implementation)

---

## Human-only

- Merge **lic#904** on `lic` main — syntax fix is governance-reviewed
- CWE catalog edits touching exploit expectations — human review
- Retire `security-research` systemd loop references in issues; swarm lane only
- Ghost org repos (404) in CI audit — create or delist

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json` → `cwe_feed_delta`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/data/goal-directed-agents/snapshot.json` → runner `security-research`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/app/data/runs/swarm_observer-1780745989625.md`
