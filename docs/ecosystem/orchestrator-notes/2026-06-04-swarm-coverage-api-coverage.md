# Orchestrator note — `swarm_coverage@api-coverage`

**Date:** 2026-06-04  
**Agent:** `swarm_observer` (worker `0b13c866`)  
**Research goal:** `swarm_coverage` — north_star_fit: ecosystem, ai  
**Dimension:** `api-coverage`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — scorecard **D** (68.3); `unattended_safe: false` |
| Gap pipeline | **Blocked** — ingest L229 syntax error (fixed this pass, unmerged); apply needs PyYAML |
| MCP api-coverage | **Partial** — ecosystem-context 8 tools; control-plane-db unreachable (`ECONNREFUSED :54322`) |
| Open registry gaps | **64** (3 `missing_package`, 31 `plan_debt`, 30 `competitor_feature`) |
| Briefing alignment | **Drift** — heap recommends `ci_maintainer` only; scorecard recommends `swarm_observer`, `gap_explorer`, `ecosystem_grader` |

---

## api-coverage audit (Mode B)

### Control-plane / MCP surface

| Surface | Expected | Actual | Gap |
|---------|----------|--------|-----|
| `li-control-plane-db` | SQL on `agent_runs`, reports, state | `ECONNREFUSED 127.0.0.1:54322` | No run-history API in pod |
| `li-ecosystem-context` | Briefing, packages, handoffs | 8 tools live | Missing `read_ecosystem_quality_report`, `read_swarm_gap_registry` |
| Disk CP cache | `data/control-plane/latest-report.json`, `state.json` | **ENOENT** in org-research pod | Observer runs blind |
| Gap ingest API | `lic/scripts/swarm-gap-ingest.py` | SyntaxError L229 until fix | Blocks vertical stub ingest |
| Gap apply API | `lic/scripts/swarm-gap-apply-actions.py` | `PyYAML required` | Blocks backlog patch refresh |

### Open `missing_package` gaps (API surface)

| Registry id | Title | Handoff |
|-------------|-------|---------|
| `gap-line-profiler-001` | `li-line-profiler` seed | `issue_planner` |

Closed in registry (present): `std.io`, `std.csv`, `std.summary`, `std.plot`.  
Apply artifact still lists 3 package patches from 2026-05-31 — refresh after PyYAML + ingest merge.

### Plan-debt API signals (relevant to api-coverage)

| Gap id | API implication |
|--------|-----------------|
| `gap-plan-debt-lic-master-plan-vision-llm-llm-first-agent-json-` | Partial: `lic check --format=json`, `lic diagnose` — agent JSON diagnostics incomplete |
| `gap-plan-debt-lic-master-plan-phase-2e-contracts-refinements-p` | Contract/refinement surface for verified APIs |
| `gap-plan-pending-swarm-observer-orch-r3-missing-package-sweep` | Orchestrator todo — route via `issue_planner`, not systemd loop |

### Reconcile actions (no product code)

1. **Merge** ingest fix on `lic` (branch `cursor/swarm-gap-ingest-path-fix` or local commit this pass).
2. **Bake** `python3-yaml` in org-research Job image (`li-cursor-agents` deploy).
3. **Re-run** ingest + apply; refresh `benchmarks/data/latest/swarm-gap-actions.json`.
4. **Handoff** `gap-line-profiler-001` → `issue_planner` via existing `config/research-goals.yaml` handoff_to.
5. **Handoff** Vision-LLM JSON gap → `plan_verifier` + `issue_planner` (PH agent diagnostics).
6. **Do not** recommend `install-goal-plan-loop-systemd.sh` — use agents control plane per `docs/ecosystem/swarm-architecture.md`.

---

## Swarm routing

| Agent | Reason |
|-------|--------|
| `gap_explorer` | 64 open gaps; refresh registry after ingest green |
| `plan_verifier` | `plan_audit` skipped; 31 plan_debt rows |
| `ci_maintainer` | Briefing P0 — CI audit incomplete (GH rate limit) |
| `security_auditor` | 19 Top25 CWEs missing from catalog |
| `issue_planner` | `pkg-line-profiler-001` + Vision-LLM JSON API issues |

Evidence: `benchmarks/data/latest/ecosystem-quality-report.json`, `benchmarks/data/latest/swarm-gap-actions.json`, `lic/data/swarm-gap-registry/registry.yaml`.
