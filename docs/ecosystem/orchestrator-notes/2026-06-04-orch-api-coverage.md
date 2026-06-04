# Orchestrator note — `orch-api-coverage` (swarm_coverage dimension)

**Date:** 2026-06-04  
**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Agent:** `swarm_observer`  
**Run:** `li-cursor-agents` `1780584401691`  
**north_star_fit:** Agent/orchestration API contract coverage — `lic` JSON diagnostics, briefing/gap JSON, control-plane persist (ecosystem, ai)

---

## Summary

Gap orchestration **cannot refresh** in this environment: `swarm-gap-ingest.py` fails with a **syntax error** on the `verticals.toml` path fallback (line 229), and `swarm-gap-apply-actions.py` requires **PyYAML**. Until ingest runs, registry rows and `swarm-gap-actions.json` remain at the **2026-05-31** snapshot (64 open gaps).

**api-coverage** findings: the highest-leverage API gap for agent loops is **Vision-LLM partial** (`lic check --format=json`, `lic diagnose`) — registry id `gap-plan-debt-lic-master-plan-vision-llm-llm-first-agent-json-`. Secondary: **vertical ingest API** blocked by ingest script + `gap-infra-verticals-toml-missing-benchmarks-main`.

---

## Programmatic prep (this run)

| Step | Command | Result |
|------|---------|--------|
| Ingest | `python3 scripts/swarm-gap-ingest.py` | **FAIL** — `SyntaxError` line 229 |
| Apply | `python3 scripts/swarm-gap-apply-actions.py` | **FAIL** — PyYAML required |
| Grade | `ecosystem-quality-grade.py` | OK — score **73.6 C** with `LI_CURSOR_AGENTS_ROOT=/app` |

---

## Registry reconciliation (open, api-relevant)

| gap_id | kind | Action |
|--------|------|--------|
| `gap-plan-debt-lic-master-plan-vision-llm-llm-first-agent-json-` | plan_debt | Handoff `plan_verifier`, `issue_planner` — JSON diagnostic API spec |
| `gap-infra-verticals-toml-missing-benchmarks-main` | competitor_feature | Handoff `gap_explorer`, `docs_maintainer` — unblock vertical ingest |
| `gap-line-profiler-001` | missing_package | Handoff `issue_planner` — backlog `pkg-line-profiler` (apply pending ingest) |
| `gap-plan-pending-swarm-observer-orch-r3-missing-package-sweep` | plan_debt | **Complete** after ingest+apply + note evidence (this file + 2026-05-31 note) |
| `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` | plan_debt | Link studio-ui-ux pending → `gui_ux_tester` / `ui_ux_quality` goal |

---

## Handoffs (no new agent ids)

```yaml
# Suggested enqueue via research/implement goals — not registry edits in this pass
- goal: swarm_coverage → gap_explorer  # verticals.toml + ingest fix verification
- goal: ui_ux_quality → gui_ux_tester   # studio-ux-16, studio-ux-17
- goal: provability_holes → plan_verifier  # Vision-LLM JSON gate linkage (PH-2e/2f)
- implement: coord_platform → ci_maintainer  # org CI audit incomplete repos
```

---

## Control-plane (li-cursor-agents)

1. Set `LI_CURSOR_AGENTS_ROOT=/app` (or package root) in benchmarks preflight env.
2. Merge **lic#828** — fixes ingest Path API for `BENCHMARKS_COMPETITIVE/verticals.toml`.
3. Ensure `LIC_ROOT=/workspace/lic` in async-swarm so observer + ingest share roots.

---

## Evidence paths

- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/app/data/runs/swarm_observer-1780584401691.md`

---

## Next orch todos

| id | Status | Next action |
|----|--------|-------------|
| `orch-r3-missing-package-sweep` | pending | Close after successful ingest+apply + `gap-line-profiler-001` backlog patch |
| `orch-r4-ui-ux-signals` | pending | Ingest studio-ui snapshot todos → `ui_ux` registry rows |
