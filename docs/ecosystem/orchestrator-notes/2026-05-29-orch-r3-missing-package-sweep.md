# Orchestrator note — `orch-r3-missing-package-sweep`

**Date:** 2026-05-29  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (`li-cursor-agents/config/research-goals.yaml`)  
**Branch:** `feat/world-studio-wave3-agentic` (lic working tree)  
**north_star_fit:** ecosystem + ai — missing std modules and package seeds routed to `issue_planner` without lic product code

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Critical / degraded** — ecosystem grade **F** (59.0 after refresh), `unattended_safe: false` |
| Open `missing_package` gaps | **3** (`gap-line-profiler-001`, `gap-missing-std-std-summary`, `gap-missing-std-std-plot`) |
| Package backlog | All five todos **`pending`** in `ecosystem-package-backlog.md` (including `pkg-std-io`, `pkg-std-csv` with registry **closed**) |
| Apply pipeline | Confirmed — ingest + apply re-ran 2026-05-29T10:11:37Z |
| Unattended? | **No** — 548 DB rows `unregistered_running_reconciled` inflate error metrics; 35 failing PRs |

`orch-r3` verified programmatic gap apply for open missing-package rows and documented handoffs to `issue_planner` / `package_architect`.

---

## Scripts executed

```bash
cd lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
cd ../benchmarks
python3 scripts/ecosystem-quality-grade.py
```

**Ingest:** `registry gaps: 79` — `open_gaps: 54` (`missing_package` 3, `plan_debt` 21, `competitor_feature` 30)  
**Apply patches (package):**

| Gap id | Backlog todo | Patch |
|--------|--------------|-------|
| `gap-line-profiler-001` | `pkg-line-profiler` | pending in `ecosystem-package-backlog.md` |
| `gap-missing-std-std-summary` | `pkg-std-summary` | pending |
| `gap-missing-std-std-plot` | `pkg-std-plot` | pending |

**Evidence:** `benchmarks/data/latest/swarm-gap-actions.json`, `lic/data/swarm-gap-registry/registry.yaml`

---

## Registry vs backlog reconciliation

| Gap id | Registry status | Backlog todo | Action |
|--------|-----------------|--------------|--------|
| `gap-missing-std-std-io` | **closed** (present 2026-05-26) | `pkg-std-io` pending | **Human/issue_planner:** mark todo completed or re-open gap |
| `gap-missing-std-std-csv` | **closed** | `pkg-std-csv` pending | same |
| `gap-line-profiler-001` | open | `pkg-line-profiler` pending | handoff `issue_planner` — seed WP-B |
| `gap-missing-std-std-summary` | open | `pkg-std-summary` pending | `issue_planner`, `package_architect` |
| `gap-missing-std-std-plot` | open | `pkg-std-plot` pending | PH-IO-5 viz/dashboard |

No new systemd plan loops. Swarm goals only.

---

## Swarm routing

| Work | Route |
|------|-------|
| Package issues from backlog | `issue_planner` (research goal handoff on `swarm_coverage`) |
| Placement / new `li-*` repos | `package_architect` |
| Line profiler seed | `issue_planner` — gap `gap-line-profiler-001` priority 8 |

**Deferred (other orch todos):** `orch-r4-ui-ux-signals`, competitor stubs (`orch-r2` note).

---

## Control-plane signal (orchestration, not package code)

- Top error string in `agent_runs`: **`unregistered_running_reconciled`** (548 rows) — supervisor lane restart marks in-flight SDK runs error; not leaf-agent logic failures.
- Recommend: `li-cursor-agents/src/observer/` exclude reconcile errors from `error_rate`; persist `error_reason` in `meta` for dashboards.

---

## Agent deliverable

- [x] Gap ingest + apply confirmed
- [x] `ecosystem-package-backlog.md` todos pending for open gaps
- [x] Orchestrator note (this file)
- [ ] Registry/backlog drift (`pkg-std-io`, `pkg-std-csv`) — `issue_planner`
- [ ] No product code in lic
