# Orchestrator note — `swarm_coverage@security`

**Date:** 2026-06-04  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**Supervisor dimension:** `security` (worker `9b2781d3`)  
**Work item:** Security gap orchestration — registry, backlog apply, handoffs

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (grade **D** 66.3, `unattended_safe: false`) |
| Security gaps (registry) | 3 open `plan_debt` rows on `security-research` runner |
| CWE catalog | 19 / 25 Top25 missing in `cve-catalog.json` |
| Gap ingest | **Fixed** — `swarm-gap-ingest.py` L229 syntax; apply re-patched `sec-r1`–`sec-r3` |
| Unattended? | **No** — heap ignores `security_auditor`; `security-research` supervisor off |

---

## Security registry rows (open)

| Gap id | Plan todo | Backlog patch | Handoff |
|--------|-----------|---------------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | sec-r1 | `security-research-backlog.md` | `security_auditor`, swarm goals |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | sec-r2 | same | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | sec-r3 | same | `security_auditor` |

Snapshot (`lic/data/goal-directed-agents/snapshot.json`): `security-research` **not running**, last activity 2026-05-25 on `sec-r1-httpd-fuzz-smoke` (agent_exit 1, gates_ok true).

---

## CWE / catalog evidence

- Feed: `benchmarks/data/latest/security-cwe-feed.json` (`top25_missing_in_catalog`: 19).
- Catalog: `lic/security/cve-catalog.json` (15 CWE classes represented).
- Briefing: recommends `security_auditor` — not reflected in `heap_plan.flat_tasks` (only `ci_maintainer`).

**Human-only:** bulk catalog rows require security review before merge (no agent auto-merge).

---

## Control-plane actions (no lic product code)

1. Route `offensive_security` goal → `security_auditor` for `sec-r1` study + CWE mapping issue draft.
2. `li-cursor-agents`: heap enqueue when `security_cwe_audit` signals `missing_in_catalog > 0`.
3. Job image: bake `python3-yaml` so ingest/apply are not ad hoc.
4. Do **not** install new lic systemd plan loops — use agents control plane per `docs/ecosystem/swarm-architecture.md`.

---

## Related PRs (not merged)

- `lic`: ingest fix branch (push after commit)
- `benchmarks`: refreshed `ecosystem-quality-report.json`, `swarm-gap-actions.json`

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/app/data/runs/swarm_observer-1780567295917.md`
