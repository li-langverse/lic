# Orchestrator note — `orch-r5-security-gap-orchestration`

**Date:** 2026-06-03  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage@security` (north_star_fit: ecosystem, ai)  
**Worker:** `e6e580ac`  
**Run:** `swarm_observer-1780528657722`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — scorecard **70.3 / C**, `unattended_safe: false` |
| Security lane | **Starved** — briefing P0 `security_auditor` not in heap; `sec-r1/2/3` pending |
| Gap pipeline | **Partially blocked** — ingest syntax fixed; apply blocked (PyYAML) |
| CWE catalog | **19 / 25 Top25 missing** in `cve-catalog.json` |
| Unattended? | **No** — CP DB down, gap apply fail-open, security heap drift |

---

## Security plan_debt reconciliation

| Registry id | Backlog todo | Apply patch (2026-05-31) | Handoff |
|-------------|--------------|--------------------------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `sec-r1-httpd-fuzz-smoke` | pending in `security-research-backlog.md` | `security_auditor` via `offensive_security` goal |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `sec-r2-tier5-gap-exploit` | pending | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `sec-r3-runtime-surface` | pending | `security_auditor` |

**Do not** spawn `security-research` systemd plan loop — route via `li-cursor-agents` research lane (`offensive_security` → `security_auditor`).

Evidence:

- `lic/data/swarm-gap-registry/registry.yaml` — 3 open security plan_debt rows
- `lic/docs/ecosystem/security-research-backlog.md` — todos `sec-r1/2/3` status `pending`
- `benchmarks/data/latest/swarm-gap-actions.json` — patches @ 2026-05-31 (stale; re-apply blocked)

---

## Scripts status

```bash
cd lic
python3 scripts/swarm-gap-ingest.py    # BLOCKED: PyYAML required (syntax L229 fixed 2026-06-03)
python3 scripts/swarm-gap-apply-actions.py  # BLOCKED: PyYAML required
```

**Fix applied this cycle:** `lic/scripts/swarm-gap-ingest.py` L229 — unterminated string in `Path(...)/verticals.toml` fallback.

**Remaining infra:** install `python3-yaml` in org-research Job image (`li-cursor-agents`).

---

## Swarm routing (security lens)

| Next agent | Reason |
|------------|--------|
| `security_auditor` | 19 Top25 CWE catalog gaps; execute `sec-r1/2/3` research backlog |
| `ci_maintainer` | `li-sec-agent` repo 404; 1 org repo missing CI |
| `gap_explorer` | 64 open registry rows; `gap_pressure` dimension 60 |
| `plan_verifier` | Master-plan security-adjacent plan_debt; refresh plan audit preflight |

---

## Related issues

- lic#575 — studio-ui-ux (ui_ux gap_kind; separate from security)
- `li-httpd#30` — failing CI on edge/TLS (blocks sec-r1 context)
- benchmarks#307–309 — scorecard refresh PRs failing CI

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json` → `cwe_feed_delta`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/app/data/runs/swarm_observer-1780528657722.md`
