# Orchestrator note — API-coverage gap orchestration (`f51d5d42`)

**Date:** 2026-06-11  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Worker:** `f51d5d42`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (conditional)** — grade **C** (76.1); `unattended_safe: true` |
| API-coverage | **Gaps** — MCP read tools missing; CP disk mirrors absent; gap CLI blocked on PyYAML |
| Gap prep | **Blocked** — ingest/apply cannot run; last apply @ `00:05:46Z` |
| Open gaps | **62** (31 plan_debt, 30 competitor_feature, 1 missing_package) |
| Briefing drift | Scorecard 4 agents vs heap 2 |
| SDK auth | `CURSOR_API_KEY` set |
| Unattended? | **Conditional** — execution clean; orchestration APIs incomplete |

---

## API-coverage reconciliation

Swarm gap orchestration requires **read APIs** that work identically in homelab, K8s org-research Jobs, and CI. This pass confirms prior workers (`48602cda`, `9fc7c786`) with refreshed briefing (`06:23Z`) and unchanged infrastructure blockers.

### Programmatic API blind spots

1. **MCP** — `li-ecosystem-context` has 7 tools; checklist §1 needs `read_ecosystem_quality_report` and Mode B §1 needs `read_swarm_gap_registry`. Meta-agents in Job pods cannot use REST fallback.
2. **Control-plane disk** — Without `state.json` / `latest-report.json`, retry budgets and intervention history are opaque. `swarm_execution` grades 100% while self-heal is unobservable.
3. **Gap CLI** — `swarm-gap-ingest.py` / `swarm-gap-apply-actions.py` require PyYAML; not in container image. Registry drift accumulates while `swarm-gap-actions.json` goes stale.
4. **Briefing heap API** — Scorecard emits `gap_explorer` + `plan_verifier`; briefing `heap_plan` omits them. Orchestration signal loss without a unified surfacing API.

### Preflight read API failures

| Script | Exit | API failure mode |
|--------|------|------------------|
| `org_ci_audit` | 1 | GitHub 404 on 10 repos (clone/workspace gaps) |
| `org_agent_kit_audit` | 1 | `roadmap/agent-kit` path not mounted |

These distort briefing consumers; not agent SDK failures.

---

## Gap orchestration (Mode B)

```bash
# Intended each cycle (BLOCKED this run):
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
# → benchmarks/data/latest/swarm-gap-actions.json
```

**Blocked:** `PyYAML required` — bake `python3-yaml` into org-research worker image.

| `gap_kind` | Open | API-coverage action |
|------------|------|---------------------|
| `plan_debt` | 31 | `orch-r3`, `orch-r4` deferred; handoff `plan_verifier` |
| `competitor_feature` | 30 | sim-md stubs — `gap_explorer` on ingest unblock |
| `missing_package` | 1 | `li-line-profiler` — `issue_planner` |

### Reconciliation actions (this pass)

1. Document MCP read-tool gap as P0 control-plane fix (`li-cursor-agents`).
2. Route `orch-r3-missing-package-sweep` — blocked until PyYAML + successful ingest.
3. Align briefing heap with scorecard on next `benchmarks` pipeline change.
4. No new agent registry ids; no lic systemd plan loops.

---

## Briefing vs scorecard drift

| Source | Top agents |
|--------|------------|
| Briefing heap | `ci_maintainer`, `security_auditor` |
| Scorecard | + `gap_explorer`, `plan_verifier` |

**Handoff chain** (`config/research-goals.yaml`): `swarm_coverage` → `[gap_explorer, plan_verifier, issue_planner]`.

---

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/app/data/runs/swarm_observer-1781156186088.md`

---

## Related

- `docs/ecosystem/swarm-architecture.md`
- `docs/ecosystem/research-verticals.md` — `swarm_coverage` row
- Whitepaper: `lic/docs/research/swarm_coverage/api-coverage/2026-06-11-whitepaper-f51d5d42.md`
