# Swarm gap orchestration — UX dimension

**Goal:** `swarm_coverage`  
**Dimension:** `ux`  
**Worker:** `d00ba62b`  
**Date:** 2026-06-08  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/ux/`

---

## Abstract

This pass audits the Li agent swarm from a **user-experience** lens: what operators and downstream agents see when gap orchestration runs under `swarm_coverage`. The swarm is **degraded** (ecosystem grade D, 66.3; `unattended_safe: false`). UX failures cluster around **missing control-plane mirrors**, **opaque gap-apply status**, and **stale studio-ui plan debt** — not SDK auth (`CURSOR_API_KEY` is set).

---

## Method

1. Regenerated `benchmarks/data/latest/ecosystem-quality-report.json` (2026-06-08).
2. Read `lic/data/swarm-gap-registry/registry.yaml` and `benchmarks/data/latest/swarm-gap-actions.json`.
3. Compared briefing `recommended_agents` vs `data/runs/` and `org-research-audit.jsonl`.
4. Mapped `ui_ux` / `plan_debt` studio-ui rows to research goal `ui_ux_quality` and implement goal `studio_ui_ux`.
5. Attempted programmatic prep (`swarm-gap-ingest.py`, `swarm-gap-apply-actions.py`).

Evidence paths cited inline.

---

## UX scorecard (swarm operator)

| Signal | Score (1–5) | Evidence |
|--------|-------------|----------|
| Health visibility | 2 | Missing `data/control-plane/latest-report.json`, `state.json` |
| Gap apply transparency | 2 | `swarm-gap-actions.json` stale (2026-05-31); no dashboard panel |
| Briefing alignment | 3 | Heap recommends `pr_merger` P10; research lane runs `swarm_coverage` |
| Error clarity | 3 | Recent runs complete; May retry storm was `agent_runs upsert: undefined` |
| Studio product UX debt | 2 | `studio-ux-16`, `studio-ux-17` open in registry + plan loop |

**Composite UX posture:** 2.4 / 5 — operators cannot run unattended without checking raw JSON paths.

---

## Gap taxonomy (UX-relevant open rows)

### `plan_debt` → studio-ui-ux

| id | Title | Handoff |
|----|-------|---------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | Palette fuzzy search + latency gate | `gui_ux_tester` |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | Native GPU fail strip + retry | `gui_ux_tester` |
| `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` | This orchestration pass | `swarm_observer` |

### `competitor_feature` → operator honesty

| id | UX impact |
|----|-----------|
| `gap-infra-verticals-toml-missing-benchmarks-main` | Vertical stub ingest returns 0 — registry appears empty to operators |
| `gap-vertical-stub-scientific-viz` | Studio viz parity messaging incomplete |

### `missing_package` → agent tooling UX

| id | UX impact |
|----|-----------|
| `gap-line-profiler-001` | No line-level profiling for long agent runs |

---

## Recommendations (control-plane UX)

1. **Dashboard panel** — surface `swarm-gap-actions.json` patches (`patched` / `deferred`) and `ecosystem-quality-report.json` grade.
2. **Bootstrap disk mirrors** — write `latest-report.json` + `state.json` each supervisor tick for Job pods without Postgres.
3. **Image deps** — bake `python3-yaml` so gap ingest/apply runs without silent skip.
4. **Goal scaffold** — ensure `swarm_coverage` runs include dimension checklist (ux / security / performance / api-coverage).
5. **Handoff `gui_ux_tester`** — close studio-ux-16/17; link iteration reports under `lic/docs/reports/studio-ui-ux/`.

---

## Conclusion

Gap orchestration UX is **blocked on infrastructure visibility**, not model quality. Closing `orch-r4` requires: (a) control-plane artifacts on disk, (b) live gap apply after PyYAML bake, (c) handoff to `gui_ux_tester` for studio plan todos. Swarm meta-audit should not starve `pr_merger` / `ci_maintainer` heap priorities.

---

## References

- `lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-r4-ui-ux-signals.md`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `docs/ecosystem/research-verticals.md` (`ui_ux_quality`, `swarm_coverage`)
