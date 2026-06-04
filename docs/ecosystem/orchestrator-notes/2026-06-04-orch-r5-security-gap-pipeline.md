# Orchestrator note — `orch-r5-security-gap-pipeline`

**Date:** 2026-06-04  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `security` (worker `5fde573d`)  
**Work item:** Reconcile security plan_debt gaps; unblock gap ingest; route `security_auditor` without lic systemd loops

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (critical infra)** — grade **D** (69.8); `unattended_safe: false` |
| Gap ingest | **Blocked** — `swarm-gap-ingest.py:229` SyntaxError |
| Gap apply | **Blocked** — PyYAML missing in org-research Job image |
| Open gaps | **64** (31 plan_debt, 30 competitor_feature, 3 missing_package) |
| Security backlog | sec-r1/2/3 **pending** in `security-research-backlog.md`; runner off ([lic#521](https://github.com/li-langverse/lic/issues/521)) |
| CWE catalog | **19/25** Top25 missing from `cve-catalog.json` |
| Unattended? | **No** — gap pipeline + control plane DB must be restored first |

Programmatic prep **not confirmed** this cycle (ingest/apply failed). Last good apply: `2026-05-31T01:45:58Z`.

---

## Security `plan_debt` reconciliation

| Registry id | Backlog todo | Status | Handoff (swarm, not systemd) |
|-------------|--------------|--------|------------------------------|
| `gap-plan-pending-security-research-sec-r0-cwe-delta` | `sec-r0-cwe-delta` | closed in registry | — |
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `sec-r1-httpd-fuzz-smoke` | pending | `security_auditor` → `offensive_security` goal |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `sec-r2-tier5-gap-exploit` | pending | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `sec-r3-runtime-surface` | pending | `security_auditor` |

Evidence:

- `/workspace/lic/docs/ecosystem/security-research-backlog.md` (sec-r0 completed; r1–r3 pending)
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (patches @ 2026-05-31)
- `/workspace/benchmarks/data/latest/security-cwe-feed.json` (`top25_missing_in_catalog: 19`)

**Do not** recommend `install-goal-plan-loop-systemd.sh` for `security-research`. Route via async swarm research lane + `config/research-goals.yaml` goal `offensive_security` (`security_auditor`, priority 9).

---

## Ingest blocker (P0)

```python
# lic/scripts/swarm-gap-ingest.py:229 — broken fallback Path
vert = Path(os.environ.get("BENCHMARKS_COMPETITIVE", str(LANGVERSE / "benchmarks/workloads/competitive"))/verticals.toml"
# Fix: close Path() before / "verticals.toml"
```

Until merged, registry rows drift vs goal-directed snapshot (`generated_at: 2026-05-30`).

---

## Swarm routing

| Next agent | Reason |
|------------|--------|
| `security_auditor` | Briefing P0: 19 Top25 CWE gaps; sec-r1 fuzz, sec-r2 tier5 exploit, sec-r3 runtime surface |
| `gap_explorer` | 64 open gaps; refresh after ingest fix |
| `plan_verifier` | Stale snapshot; close completed sec-r0 in registry |
| `ci_maintainer` | 1 repo missing CI; GH rate-limit on org audit |
| `issue_planner` | lic#521 runner resume; cve-catalog expansion issues |

---

## Human-only

- lic#436 registry merge (if conflict persists on main)
- Merge wave / CI-red PRs (8 failing)
- Supabase / control-plane DB restore
- `trusted.lean` / provability governance

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780531239283.md`
