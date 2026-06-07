# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-07  
**Agent:** `swarm_observer` (worker `0127d1e6`)  
**Research goal:** `swarm_coverage` · dimension **ux**  
**Work item:** Link UI/UX gap signals to studio-ui-ux plan todos and benchmarks dashboard a11y debt

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 60.9; `unattended_safe: false`) |
| `orch-r4` | **In progress** — UX signals documented; registry rows remain open pending snapshot refresh |
| `ui_ux` gaps | 2 open studio-ui-ux plan todos + 8+ duplicate benchmarks PRs on GPU chip picker ARIA |
| Gap pipeline | **Blocked** — `swarm-gap-ingest.py:229` syntax fixed locally; PyYAML still missing in worker image |
| Unattended? | **No** — human must consolidate benchmarks PR stack and bake `python3-yaml` |

---

## UX gap reconciliation (Mode B)

### Open `ui_ux` / studio-ui-ux plan_debt rows

| Registry id | Plan todo | Status | Handoff |
|-------------|-----------|--------|---------|
| `gap-plan-pending-studio-ui-ux-studio-ux-16-palette-search-latency` | `studio-ux-16-palette-search-latency` | open | `gui_ux_tester` via `ui_ux_quality` goal |
| `gap-plan-pending-studio-ui-ux-studio-ux-17-gpu-fail-recovery` | `studio-ux-17-gpu-fail-recovery` | open | `gui_ux_tester` + studio-ui-ux plan loop |

**Closed studio-ui-ux rows (snapshot drift):** `studio-ux-04` through `studio-ux-15` show `completed_ids` in snapshot but registry still lists closed — no action.

### Benchmarks dashboard UX debt (not in registry)

| Symptom | Evidence | Severity |
|---------|----------|----------|
| GPU chip picker ARIA tabs + keyboard roving (#147) | 8+ open failing PRs (#400–409, duplicates) | **high** |
| Failed CI blocks ecosystem grade refresh PRs | `agent-briefing.json` → `ecosystem_audit.failed_prs` | **high** |
| Redundant PR pairs | `merge_plan.summary.redundant_pairs: 197` | **medium** |

**Orchestrator action:** Route to `gui_ux_tester` / human to pick **one** canonical PR from the stack; close duplicates. Do **not** spawn new lic systemd loops — use agents control plane (`docs/ecosystem/swarm-architecture.md`).

### `orch-r4` completion criteria

1. Document UX signal taxonomy in whitepaper (this cycle).
2. Enqueue handoff: `gui_ux_tester` → consolidate benchmarks#147 stack.
3. Link open studio-ui-ux todos in `config/research-goals.yaml` (`ui_ux_quality` goal already exists).
4. Close registry row `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` when ingest runs live post-PyYAML.

---

## Programmatic prep status

| Script | Result |
|--------|--------|
| `lic/scripts/swarm-gap-ingest.py` | **SyntaxError L229 fixed** (local); still exits: PyYAML required |
| `lic/scripts/swarm-gap-apply-actions.py` | Not run — PyYAML required |
| `benchmarks/scripts/ecosystem-quality-grade.py` | **OK** — refreshed 2026-06-07T01:23:20Z, grade D |

---

## Handoffs (north_star_fit: ecosystem, ai)

| To | Reason |
|----|--------|
| `gui_ux_tester` | Consolidate GPU chip picker ARIA PR stack; axe/Playwright on org-supervisor-dashboard |
| `gap_explorer` | After PyYAML: re-ingest verticals.toml stubs |
| `plan_verifier` | Refresh goal-directed snapshot (stale 2026-05-30); close drifted studio-ui-ux rows |
| `ci_maintainer` | 14 repos missing CI; org_ci_audit rate-limited |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780794605537.md`
