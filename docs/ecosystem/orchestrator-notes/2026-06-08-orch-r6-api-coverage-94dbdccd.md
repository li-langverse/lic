# Orchestrator note — `orch-r6-api-coverage`

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Worker:** `94dbdccd`  
**Research goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Work item:** Audit MCP + filesystem API surface for gap registry orchestration; remediate ingest syntax blocker

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (grade **D**, 65.3; `unattended_safe: false`) |
| Gap registry | **62 open** rows; apply artifact stale (2026-05-31) |
| Ingest script | SyntaxError L229 **fixed locally**; PyYAML still blocks live run |
| MCP handoffs | **0** pending |
| `orch-r3` / `orch-r4` | Still **open** in registry |

---

## API-coverage findings

### MCP tools present (`li-ecosystem-context`)

- `get_briefing_snapshot`, `list_pending_handoffs`, `describe_package`, `search_repo_tree`
- `load_research_session`, `advance_research_session`, `record_placement_decision`, `list_org_repos`

### Gaps for unattended `swarm_coverage`

| Capability | Status |
|------------|--------|
| `read_gap_registry` | **Missing** — agents must read `LIC_ROOT/data/swarm-gap-registry/registry.yaml` |
| `read_ecosystem_quality_report` | **Missing** — shell script or direct file read |
| `read_swarm_gap_actions` | **Missing** |
| `read_control_plane_state` | **Missing** — `state.json` / `latest-report.json` not written |
| Briefing via MCP in research Job | **Broken** — falls back to `/app/fixtures/e2e-benchmarks/...` without `BENCHMARKS_ROOT` |

### Script dependency API

- `swarm-gap-ingest.py` / `swarm-gap-apply-actions.py` require **PyYAML** — not in org-research worker image.

---

## Scripts attempted

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
# → overall_score=65.3 grade=D unattended_safe=False

cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
# → SyntaxError L229 (fixed: Path(...)/ "verticals.toml")
# → PyYAML required (blocked)

python3 scripts/swarm-gap-apply-actions.py
# → PyYAML required (blocked)
```

---

## Gap reconcile (read-only)

| `gap_kind` | Open | Handoff |
|------------|-----:|---------|
| `plan_debt` | 31 | `plan_verifier`, runner backlogs |
| `competitor_feature` | 30 | `numerics_researcher`, `bench_improver` |
| `missing_package` | 3 | `issue_planner` |

**Sim hot paths:** `sim-p2-qm-dft-scf` ↔ lic#1172/#1156 (CI fail); registry row `gap-plan-pending-sim-sim-p2-qm-dft-scf`.

**Orchestrator rows:**

- `gap-plan-pending-swarm-observer-orch-r3-missing-package-sweep` → open → `issue_planner` after live apply
- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` → open → `gui_ux_tester` / studio-ui-ux UX-16/17

---

## Handoffs (no new registry ids)

| Target agent | Reason | north_star_fit |
|--------------|--------|----------------|
| `issue_planner` | `missing_package` ×3 after PyYAML unblock | ecosystem · PH-IO |
| `plan_verifier` | 31 `plan_debt` rows + stale snapshot | provability · master plan |
| `gap_explorer` | `verticals.toml` on benchmarks main | ecosystem · competitive honesty |
| `ci_maintainer` | 12 repos missing CI | platform · secure |
| `pr_merger` | lip#52 merge-approved | platform deps |

---

## Evidence paths

- Report: `/app/data/runs/swarm_observer-1780876447048.md`
- Quality: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Registry: `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- Actions: `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- Briefing: `/workspace/benchmarks/data/latest/agent-briefing.json`
- Whitepaper staging: `docs/research/swarm_coverage/api-coverage/2026-06-08-whitepaper-94dbdccd.md`

---

## Recommended merges (human)

1. **lic** — ingest Path fix + orchestrator note
2. **li-cursor-agents** — MCP read tools + observer persistence + worker env
3. **benchmarks** — refreshed grade artifact

No PRs merged by `swarm_observer`.
