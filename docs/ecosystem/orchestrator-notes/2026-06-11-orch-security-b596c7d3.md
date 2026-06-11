# Orchestrator note — security gap orchestration (`b596c7d3`)

**Date:** 2026-06-11  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `security`  
**Worker:** `b596c7d3`  
**Run:** `1781140305274`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (orchestration)** — grade **C** (75.6); execution clean, security leaf undispatched |
| Gap prep | **Apply @ 00:05Z**; **live ingest blocked** (PyYAML) |
| Open gaps | **62** (3 security-research plan_debt + 1 ph-db security bench) |
| Security coverage | CWE catalog **19/25 Top-25 gaps**; `sec-r1`–`sec-r3` pending in backlog |
| Unattended? | **Conditional** — `unattended_safe: true`; gap refresh + security dispatch blocked |

---

## Security reconciliation (swarm_coverage lens)

Swarm gap orchestration routes security work through **research goals**, not retired systemd loops.

### Registry → goal mapping

| Registry gap | Backlog patch (00:05Z) | Swarm route |
|--------------|--------------------------|-------------|
| `sec-r0-cwe-delta` | completed in backlog | `security_auditor` / `offensive_security` |
| `sec-r1-httpd-fuzz-smoke` | `security-research-backlog.md` pending | `security_auditor` — httpd fuzz smoke |
| `sec-r2-tier5-gap-exploit` | pending | `security_auditor` — tier5 exploit parity |
| `sec-r3-runtime-surface` | pending | `security_auditor` — runtime surface |
| `wp-n5-security-bench` (ph-db) | deferred | `goal_researcher` / `database_platform` |

**Do not** recommend `install-goal-plan-loop-systemd.sh` for `security-research` — async swarm per `docs/ecosystem/swarm-architecture.md`.

### CWE feed (01:26Z)

- Source: `security-cwe-feed.json` (mitre_top25_baseline)
- Catalog path: `lic/security/cve-catalog.json` — **15** CWE rows
- Missing Top-25: **19** (e.g. CWE-79, CWE-89, CWE-352, CWE-798)
- `security_cwe_audit` preflight: **skipped** in compact briefing (`--skip-slow`); feed sync ran earlier @ 01:26Z

Handoff: `security_auditor` with `north_star_fit: ecosystem, secure` — human review for catalog JSON merges.

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (BLOCKED this run):
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py      # FAIL: PyYAML required
python3 scripts/swarm-gap-apply-actions.py
```

Last apply artifact: `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (19 backlog patches @ 00:05Z).

| `gap_kind` | Open | Security-relevant route |
|------------|------|-------------------------|
| `plan_debt` | 31 | 3 security-research + 1 ph-db → goals above |
| `competitor_feature` | 30 | tier5/httpd exploit rows → `security_auditor` where applicable |
| `missing_package` | 1 | `issue_planner` (line_profiler — perf, not sec) |

---

## Control-plane security observations

| Gap | Risk | Fix owner |
|-----|------|-----------|
| No CP disk mirrors | Observer state opaque across Job restarts | `li-cursor-agents` supervisor |
| PyYAML absent | Stale gap registry → wrong handoffs | deploy image |
| Briefing heap omits `security_auditor` | P0 security signal not scheduled | `enrich-briefing-scorecards.py` |
| `LI_CURSOR_AGENTS_ENABLED=0` | Agent deliverable gate skipped | env default in briefing build |
| GitHub rate limit | `org_ci_audit` incomplete — CI posture unknown | wait / backoff |

---

## Handoffs (cite north_star_fit)

| To agent | Reason | north_star_fit |
|----------|--------|----------------|
| `security_auditor` | 19 CWE catalog gaps + sec-r1–sec-r3 backlogs | ecosystem, secure |
| `gap_explorer` | 62 open gaps after PyYAML unblock | ecosystem, ai |
| `ci_maintainer` | 38 repos missing CI (ecosystem audit; rate-limited re-verify) | ecosystem |
| `plan_verifier` | 8 preflight scripts skipped | provable |
| `issue_planner` | CWE catalog PR scaffolding + PyYAML image | secure, provable |

---

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/app/data/runs/swarm_observer-1781140305274.md`
