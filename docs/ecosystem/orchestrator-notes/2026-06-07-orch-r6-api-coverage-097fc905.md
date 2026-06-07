# Orchestrator note — `orch-r6-api-coverage`

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Worker:** `097fc905`  
**Research goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (grade **C**, 74.6; `unattended_safe: false`) |
| Gap registry | **64 open** (31 plan_debt, 30 competitor_feature, 3 missing_package) |
| Gap prep | **Blocked** — `swarm-gap-ingest.py:229` SyntaxError **remediated** this pass; **PyYAML missing** in worker |
| `orch-r3` / `orch-r4` | Still **open** in registry (missing-package sweep, ui-ux signals) |
| API coverage | MCP exposes briefing snapshot only; gap registry + quality report **not** MCP-readable |
| Unattended? | **No** — preflight failures, stale snapshot, gap apply pipeline blocked |

---

## Programmatic prep status

| Step | Command | Result |
|------|---------|--------|
| Ingest | `lic/scripts/swarm-gap-ingest.py` | SyntaxError line 229 → **fixed** (Path fallback); then `PyYAML required` |
| Apply | `lic/scripts/swarm-gap-apply-actions.py` | **Not run** — PyYAML unavailable (`pip`/`apt` absent) |
| Last apply artifact | `benchmarks/data/latest/swarm-gap-actions.json` | Stale (`2026-05-31T01:45:58Z`) |

---

## API-coverage audit (orchestration surfaces)

| Surface | Path / tool | Agent-readable? | Gap |
|---------|-------------|-----------------|-----|
| Gap registry | `lic/data/swarm-gap-registry/registry.yaml` | Read tool only | No MCP `read_gap_registry` |
| Gap apply actions | `benchmarks/data/latest/swarm-gap-actions.json` | Read tool only | No MCP reader; stale when ingest blocked |
| Quality scorecard | `benchmarks/data/latest/ecosystem-quality-report.json` | Read tool only | Grader default `runs_dir` wrong without `LI_CURSOR_AGENTS_ROOT=/app` |
| Briefing | `benchmarks/data/latest/agent-briefing.json` | MCP `get_briefing_snapshot` | Partial keys only (`ecosystem_explorer: null` this pass) |
| Control plane | `data/control-plane/state.json`, `latest-report.json` | **Absent** until observer bootstrap | Observer tick does not persist in org-research worker |
| Run history | `li-cursor-agents/data/runs/*.json` | Sampled when `LI_CURSOR_AGENTS_ROOT=/app` | Default sibling path empty in container |

**Recommendation:** Add MCP tools `read_gap_registry` + `read_ecosystem_quality_report` on `li-ecosystem-context`; bake `python3-yaml` + `LI_CURSOR_AGENTS_ROOT=/app` in org-research Job image; persist observer outputs each supervisor tick.

---

## Open gap reconciliation (api-coverage lens)

| Priority | Gap id / todo | `gap_kind` | Route |
|----------|---------------|------------|-------|
| P0 | `gap-infra-verticals-toml-missing-benchmarks-main` | competitor_feature | `gap_explorer` + ship `verticals.toml` on benchmarks main |
| P1 | `orch-r3-missing-package-sweep` | plan_debt | Close after `pkg-line-profiler` handoff → `issue_planner` |
| P1 | `orch-r4-ui-ux-signals` | plan_debt | Link `studio-ux-16/17` → `gui_ux_tester` via implement lane |
| P2 | ph-db `wp-*` (9 rows) | plan_debt | Add ph-db backlog mapping in `swarm-gap-apply-actions.py` |
| P2 | `sim-p2-qm-dft-scf` | plan_debt | `sim-algorithm-backlog.md` → numerics_researcher (aligns lic#478 PR wave) |

Handoffs cite **north_star_fit:** ecosystem, ai — proof-before-perf; no new agent registry ids.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (regenerated `2026-06-07T22:20:32Z`, `LI_CURSOR_AGENTS_ROOT=/app`)
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/data/goal-directed-agents/snapshot.json` (stale `2026-05-30`)
- `/app/data/runs/swarm_observer-1780869247273.md`
- `/workspace/lic/docs/research/swarm_coverage/api-coverage/2026-06-07-whitepaper-097fc905.md`
