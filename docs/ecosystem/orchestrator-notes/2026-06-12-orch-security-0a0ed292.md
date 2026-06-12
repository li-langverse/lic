# Orchestrator note — security gap orchestration (`0a0ed292`)

**Date:** 2026-06-12  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `security`  
**Worker:** `0a0ed292`  
**Run:** `1781238120906`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (orchestration)** — grade **C** (76.1); execution clean; security leaf undispatched |
| Gap prep | **Apply @ 00:05Z** (~28h stale); **live ingest blocked** (PyYAML) |
| Open gaps | **62** (3 security-research plan_debt + 1 ph-db security bench) |
| Security coverage | CWE catalog **19/25 Top-25 gaps**; `sec-r1`–`sec-r3` pending in backlog |
| Unattended? | **Conditional** — `unattended_safe: true`; gap refresh + security dispatch blocked |

---

## Security reconciliation (swarm_coverage lens)

Swarm gap orchestration routes security work through **research goals**, not retired systemd loops.

### Registry → goal mapping

| Registry gap | Backlog patch (00:05Z) | Swarm route |
|--------------|--------------------------|-------------|
| `sec-r0-cwe-delta` | completed in backlog | `offensive_security` → `security_auditor` |
| `sec-r1-httpd-fuzz-smoke` | `security-research-backlog.md` pending | `security_auditor` — httpd fuzz smoke |
| `sec-r2-tier5-gap-exploit` | pending | `security_auditor` — tier5 exploit parity |
| `sec-r3-runtime-surface` | pending | `security_auditor` — runtime surface |
| `wp-n5-security-bench` (ph-db) | deferred (no backlog mapping) | `database_platform` → `goal_researcher` |

**Do not** recommend `install-goal-plan-loop-systemd.sh` for `security-research` — async swarm per `docs/ecosystem/swarm-architecture.md`.

### CWE feed (04:42Z)

- Source: `security-cwe-feed.json` (mitre_top25_baseline)
- Catalog path: `lic/security/cve-catalog.json` — **15** CWE rows
- Missing Top-25: **19** (e.g. CWE-79, CWE-89, CWE-352, CWE-798)
- `security_cwe_audit` preflight: **skipped** in compact briefing (`--skip-slow`)

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
| Briefing heap omits `security_auditor` | P0 security signal not scheduled | `enrich-briefing-scorecards.sh` |
| `LI_CURSOR_AGENTS_ENABLED=0` | Agent deliverable gate skipped | env default in briefing build |
| `org_ci_audit` exit 1 | CI posture incomplete | wait / backoff / inventory fix |

---

## Handoffs

| To agent | Reason |
|----------|--------|
| `security_auditor` | CWE catalog + sec-r1–sec-r3 via `offensive_security` goal |
| `gap_explorer` | 62 open gaps; verticals.toml ingest blocked |
| `plan_verifier` | 31 plan_debt |
| `ci_maintainer` | 33 repos missing CI |
| `issue_planner` | PyYAML image + line-profiler |

---

## Evidence

- `/app/data/runs/swarm_observer-1781238120906.md`
- `/workspace/lic/docs/research/swarm_coverage/security/2026-06-12-whitepaper-0a0ed292.md`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
