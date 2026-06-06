# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` @ **ux** dimension (worker `e70fed9c`)  
**north_star_fit:** ecosystem, ai — swarm gap orchestration UX signals

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (62.6); `unattended_safe: false` |
| `orch-r4` | **In progress** — UX signals documented; studio backlog apply blocked |
| Gap pipeline | Ingest + apply **recovered** after ingest script fix + PyYAML install |
| Open gaps | **62** (down from 64) |
| UX audit scope | **lic-docs only** — studio/GUI/TUI not covered |
| Unattended? | **No** — studio-ui mount + CP persistence required |

---

## UX gap taxonomy reconciliation

| `gap_kind` | Count | UX-relevant rows | Action |
|------------|------:|------------------|--------|
| `plan_debt` | 31 | 17 `studio-ui-ux` + `orch-r4` | Route via `gui_ux_tester` / studio plan when backlog mounted |
| `competitor_feature` | 30 | `scientific-viz`, cinematic stubs | Handoff `numerics_researcher` + `gap_explorer` |
| `missing_package` | 1 | `std.plot`/`std.summary` (UX-adjacent viz) | `issue_planner` |
| `ui_ux` (registry) | 0 explicit | Viz unknowns treated as UX catalog debt | Register honest stubs in benchmarks |

### Studio-ui-ux plan_debt (blocked)

Registry lists **17+** pending todos (`studio-ux-04` … `studio-ux-24`). Apply output:

```text
skip missing backlog /workspace/lic-studio-ui/docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md
```

**Routing (no new systemd loops):**

- Enable `ui_ux_quality` research goal → `gui_ux_tester` (cadence 48h, priority 5).
- When `lic-studio-ui` is mounted, re-run `swarm-gap-apply-actions.py` to patch plan loop markdown.
- Link completed studio todos to `implement-goals.yaml` handoffs — not lic product code from this agent.

### Viz benchmark unknowns (UX catalog)

From briefing `ecosystem_audit.benchmarks.unknown`:

- `viz_colormap`, `viz_decimate`, `viz_inspector_panels`, `viz_linked_views`
- `viz_marching_cubes`, `viz_pipeline_graph`, `viz_resample`

**Handoff:** `gui_ux_tester` + benchmarks maintainer — register stub-honest oracle rows so dashboard charts are not permanently `unknown`.

### orch-r4 registry row

- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — apply: `deferred (no runner backlog mapping)`
- **Close on next ingest** after: (1) this note committed, (2) `gui_ux_tester` dispatched once, (3) viz stub registration issue filed.

---

## Scripts executed

```bash
apt-get install -y python3-yaml   # worker image should bake this
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py    # registry 92 rows; added=0 after fix
python3 scripts/swarm-gap-apply-actions.py
# wrote /workspace/benchmarks/data/latest/swarm-gap-actions.json (open_gaps=62)
cd /workspace/benchmarks
python3 scripts/ecosystem-quality-grade.py  # grade D 62.6
```

Ingest fix: `scripts/swarm-gap-ingest.py` — `BENCHMARKS_COMPETITIVE` env fallback + syntax repair L227–232.

---

## Swarm routing

| Next agent | Reason |
|------------|--------|
| `gui_ux_tester` | `ui_ux_quality` goal; expand beyond lic-docs to GUI/TUI when surfaces available |
| `gap_explorer` | 62 open gaps; competitor_feature + plan_debt pressure |
| `ci_maintainer` | Briefing P0 — 6 repos missing CI |
| `pr_merger` | lip#52 gate-ready |
| `issue_planner` | File viz catalog + studio-ui backlog mount issues |

Research goals unchanged in `li-cursor-agents/config/research-goals.yaml` — no new registry ids.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/benchmarks/data/latest/ux-audit.json`
- `/workspace/benchmarks/data/latest/ui-audit.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780751391363.md`
- `/workspace/lic/docs/research/swarm_coverage/ux/2026-06-06-whitepaper.md`
