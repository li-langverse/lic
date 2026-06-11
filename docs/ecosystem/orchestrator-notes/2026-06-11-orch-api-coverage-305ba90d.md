# Orchestrator note — API-coverage gap orchestration (`305ba90d`)

**Date:** 2026-06-11  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Worker:** `305ba90d`  
**Run:** `1781170584684`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (orchestration)** — grade **C** (76.1), `unattended_safe: true` conditional |
| Gap prep | **Ingest blocked** (PyYAML); apply artifact @ `00:05:46Z` |
| Open gaps | **62** (`plan_debt` 31, `competitor_feature` 30, `missing_package` 1) |
| API coverage | REST OK when ops-server runs; MCP missing scorecard/registry readers; CP disk absent in Job |
| Observer self-heal | **None observable** |
| SDK | `CURSOR_API_KEY` set |

---

## API-coverage reconciliation

Org-research Jobs must audit swarm health without homelab-only paths. This pass confirms:

1. **File fallbacks work** when `/workspace/benchmarks` is mounted (`ecosystem-quality-report.json`, `swarm-gap-actions.json`, `registry.yaml`).
2. **MCP `get_briefing_snapshot`** returns compact briefing when `benchmarks_root` is passed.
3. **Gaps:** no MCP tools for scorecard/registry; `swarm-gap-ingest.py` fails without PyYAML; `/app/data/control-plane/{state,latest-report}.json` not hydrated in Job pod.

### Recommended MCP additions (`li-cursor-agents`)

- `read_ecosystem_quality_report` → checklist §1
- `read_swarm_gap_registry` → Mode B §1

### Image dependency

```text
ModuleNotFoundError: No module named 'yaml'
```

Bake `python3-yaml` in org-research worker image.

---

## Gap orchestration (Mode B)

Last apply: `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (19 backlog patches, orch-r3/r4 deferred).

| `gap_kind` | Open | Route |
|------------|------|-------|
| `plan_debt` | 31 | `plan_verifier` + runner backlogs |
| `competitor_feature` | 30 | `gap_explorer` → numerics goals |
| `missing_package` | 1 | `issue_planner` (`li-line-profiler`) |

**Do not** recommend `install-goal-plan-loop-systemd.sh`.

### Rows reconciled

| Gap id | Action |
|--------|--------|
| `orch-r3-missing-package-sweep` | `gap-line-profiler-001` → `issue_planner` |
| `orch-r4-ui-ux-signals` | `ui_ux_quality` → `gui_ux_tester` |
| `gap-infra-verticals-toml-missing-benchmarks-main` | `gap_explorer` + `docs_maintainer` |
| sim/security backlog patches | `numerics_researcher` / `security_auditor` follow-through |

---

## Briefing vs scorecard drift

| Source | Top agents |
|--------|------------|
| Briefing heap | `ci_maintainer`, `security_auditor` |
| Scorecard | + `gap_explorer`, `plan_verifier` |

Fix: `benchmarks/scripts/enrich-briefing-scorecards.py` union.

---

## Handoffs

| To agent | Reason |
|----------|--------|
| `gap_explorer` | 62 open gaps |
| `plan_verifier` | 31 plan_debt |
| `ci_maintainer` | repos missing CI |
| `security_auditor` | CWE catalog gaps |
| `issue_planner` | PyYAML image + line-profiler + MCP tools |

---

## Evidence

- `/app/data/runs/swarm_observer-1781170584684.md`
- `/workspace/lic/docs/research/swarm_coverage/api-coverage/2026-06-11-whitepaper-305ba90d.md`
