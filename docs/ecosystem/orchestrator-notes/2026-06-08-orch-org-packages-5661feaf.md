# Orchestrator note — `org-packages` (worker `5661feaf`)

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `org-packages` — whole-org package/repo audit  
**Run:** `swarm_observer-1780951393789`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (65.8); `unattended_safe: false` |
| Open `missing_package` | **1** — `gap-line-profiler-001` → `pkg-line-profiler` pending |
| Std modules | **Completed** in backlog (io, csv, summary, plot); registry gaps closed |
| Org CI holes | **12 repos** missing workflow on main |
| Gap pipeline | **Blocked** — PyYAML missing; ingest syntax fixed locally |
| Unattended? | **No** — infra blockers + CI gaps require human or `ci_maintainer` |

---

## `org-packages` reconciliation

### Package backlog vs registry

| Registry id | Backlog todo | Backlog status | Handoff |
|-------------|--------------|----------------|---------|
| `gap-line-profiler-001` | `pkg-line-profiler` | **pending** | `issue_planner`, `package_architect` |
| `gap-missing-std-std-io` | `pkg-std-io` | completed | closed |
| `gap-missing-std-std-csv` | `pkg-std-csv` | completed | closed |
| `gap-missing-std-std-summary` | `pkg-std-summary` | completed | closed |
| `gap-missing-std-std-plot` | `pkg-std-plot` | completed | closed |

Evidence: `lic/docs/ecosystem/ecosystem-package-backlog.md`, `lic/data/swarm-gap-registry/registry.yaml`

### Org repos missing CI (package infra)

From `benchmarks/data/latest/ecosystem-audit.json` → `missing_ci_on_main`:

`li-api-kit`, `li-auth-jwt`, `li-blob-service`, `li-books-gateway`, `li-books-law-ingest`, `li-books-studio`, `li-os`, `li-research-gateway`, `li-research-mcp`, `li-sec-agent`, `lik`, `token-telemetry-service`

**Routing:** briefing P50 → **`ci_maintainer`** (not a swarm-gap-registry row; structural org-packages finding).

### Plan debt — package placement

| Registry id | Runner | Todo | Handoff |
|-------------|--------|------|---------|
| `gap-plan-pending-sim-chem-research-chem-r3-package-placement` | sim-chem-research | `chem-r3-package-placement` | `swarm_observer` → **`package_architect`** via `chem_sim_algorithms` research goal |

---

## Scripts

```bash
# Attempted this run
cd lic && python3 scripts/swarm-gap-ingest.py     # SyntaxError @229 → fixed locally; then PyYAML required
cd lic && python3 scripts/swarm-gap-apply-actions.py  # PyYAML required

cd benchmarks && python3 scripts/ecosystem-quality-grade.py  # OK → 65.8 grade D
```

**Do not** recommend `install-goal-plan-loop-systemd.sh` — use agents control plane (`docs/ecosystem/swarm-architecture.md`).

---

## Swarm routing

| Next agent | Reason |
|------------|--------|
| `issue_planner` | Open issue for `li-line-profiler` seed (`gap-line-profiler-001`) |
| `package_architect` | Placement for line profiler + chem package placement debt |
| `ci_maintainer` | 12 org packages missing CI on main |
| `gap_explorer` | Refresh registry after PyYAML unblocks ingest |

Research goal `swarm_coverage` remains on `swarm_observer` (cadence 6h) in `li-cursor-agents/config/research-goals.yaml`.

---

## Registry plan-debt rows (swarm-observer loop)

- `gap-plan-pending-swarm-observer-orch-r3-missing-package-sweep` — **complete** (backlog reconciled; only line-profiler open)
- `gap-plan-pending-swarm-observer-orch-r4-ui-ux-signals` — defer to UX dimension pass

---

## Human-only

- Creating/scaffolding 12 CI workflows may need org admin tokens beyond rate-limited gh API
- Shipping `li-line-profiler` is product work — no auto-merge on `lic` main
- Merge lip#52 via `pr_merger` only

---

## Evidence paths

- `/app/data/runs/swarm_observer-1780951393789.md`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/docs/research/swarm_coverage/org-packages/2026-06-08-whitepaper-5661feaf.md`
