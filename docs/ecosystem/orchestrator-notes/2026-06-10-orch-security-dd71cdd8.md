# Orchestrator note — security gap orchestration (`dd71cdd8`)

**Date:** 2026-06-10  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `security`  
**Worker:** `dd71cdd8`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **C** (75.6); execution clean, security leaf undispatched |
| Gap prep | **Blocked** — PyYAML missing; last apply @ 14:45Z |
| Open gaps | **62** (3 security-research plan_debt + 1 ph-db security bench) |
| Security coverage | CWE catalog **19/25 Top-25 gaps**; `sec-r1`–`sec-r3` pending in backlog |
| Unattended? | **Conditional** — `unattended_safe: true`; gap refresh + security dispatch blocked |

---

## Security reconciliation (swarm_coverage lens)

Swarm gap orchestration routes security work through **research goals**, not retired systemd loops.

### Registry → goal mapping

| Registry gap | Backlog patch (14:45Z) | Swarm route |
|--------------|--------------------------|-------------|
| `sec-r0-cwe-delta` | completed in backlog | `security_auditor` / `offensive_security` |
| `sec-r1-httpd-fuzz-smoke` | `security-research-backlog.md` pending | `security_auditor` — httpd fuzz smoke |
| `sec-r2-tier5-gap-exploit` | `security-research-backlog.md` pending | `security_auditor` — tier5 exploit parity |
| `sec-r3-runtime-surface` | `security-research-backlog.md` pending | `security_auditor` — runtime surface |
| `wp-n5-security-bench` (ph-db) | deferred | `goal_researcher` / `database_platform` |

**Do not** recommend `install-goal-plan-loop-systemd.sh` for `security-research` — async swarm per `docs/ecosystem/swarm-architecture.md`.

### CWE feed (23:17Z)

- Source: `security-cwe-feed.json` (mitre_top25_baseline)
- Catalog path: `lic/security/cve-catalog.json` — **15** CWE rows
- Missing Top-25: **19** (e.g. CWE-79, CWE-89, CWE-352, CWE-798)
- `security_cwe_audit` preflight: **skipped** (`--skip-slow`)

Handoff: `security_auditor` with `north_star_fit: ecosystem, secure` — human review for catalog JSON merges.

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (blocked @ 23:21Z):
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py      # FAIL: PyYAML required
python3 scripts/swarm-gap-apply-actions.py
```

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
| `LI_CURSOR_AGENTS_ENABLED=0` | Agent deliverable gate skipped | env default in briefing build |
| Briefing heap omits `security_auditor` | P0 security signal not scheduled | `swarm-recommendations.ts` |

---

## Handoffs (cite north_star_fit)

| To agent | Reason | north_star_fit |
|----------|--------|----------------|
| `security_auditor` | 19 CWE catalog gaps + sec-r1–sec-r3 backlogs | ecosystem, secure |
| `ci_maintainer` | 27 repos missing CI; supply-chain posture | ecosystem |
| `gap_explorer` | 62 open gaps after PyYAML unblock | ecosystem, ai |
| `issue_planner` | CWE catalog PR scaffolding | secure, provable |
| `plan_verifier` | 8 preflight scripts skipped | provable |

---

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/app/data/runs/swarm_observer-1781130788042.md`
