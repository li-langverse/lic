# Swarm observer orchestration backlog

**Status:** Active  
**Agent:** `swarm_observer`  
**Goal:** `swarm_coverage` (research-goals.yaml)  
**Branch:** `cursor/swarm-observer-plan-loop`  
**Registry:** `data/swarm-gap-registry/registry.yaml`

---

todos:

- id: orch-r0-ingest-snapshot
  content: "Run swarm-gap-ingest.py; reconcile registry with snapshot + audits; confirm apply-actions dry-run"
  status: completed

- id: orch-r1-plan-debt-sync
  content: "Map goal-directed snapshot plan_pending per runner → registry plan_debt; patch loop backlogs where stale"
  status: completed

- id: orch-r2-competitor-stubs
  content: "Ingest verticals.toml stubs + ecosystem explorer catalog gaps as competitor_feature rows"
  status: completed

- id: orch-r3-missing-package-sweep
  content: "Sweep missing_std_modules + seed line_profiler; ensure ecosystem-package-backlog todos pending"
  status: pending

- id: orch-r4-ui-ux-signals
  content: "Surface studio-ui-ux / gui_ux_tester signals as ui_ux gaps; link studio backlog if needed"
  status: pending

---

## Agent instructions

- One todo per loop iteration (`swarm-observer-plan-loop.py`).
- Before agent: `swarm-gap-ingest.py` then `swarm-gap-apply-actions.py` (programmatic backlog patch).
- Agent: `swarm_observer` — orchestration only; no product code in lic.
- Gates: `./scripts/swarm-observer-plan-gates.sh`
- Output: gap registry updates, `benchmarks/data/latest/swarm-gap-actions.json`, backlog patches.
- Push branch `cursor/swarm-observer-plan-loop` each iteration.

### Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `LI_LANGVERSE_ROOT` | `lic` repo parent (`ROOT.parent`) | Sibling repo resolution |
| `BENCHMARKS_ROOT` | `$LI_LANGVERSE_ROOT/benchmarks` | Read `data/latest/ecosystem-explorer.json`, `plan-completion-audit.json` |
| `BENCHMARKS_COMPETITIVE` | `$BENCHMARKS_ROOT/workloads/competitive` or `$BENCHMARKS_ROOT/competitive` | `verticals.toml` stub ingest |
| `--registry` CLI | `data/swarm-gap-registry/registry.yaml` | Override registry path |

**Minimal checkout (lic only):**

```bash
export LI_LANGVERSE_ROOT=/path/to/langverse   # parent of lic + benchmarks
export BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-$LI_LANGVERSE_ROOT/benchmarks}"
python3 scripts/swarm-gap-ingest.py --dry-run
python3 scripts/swarm-gap-apply-actions.py --dry-run
```

`plan_verifier` step 6 runs ingest after audit; `swarm_observer` runs ingest then apply-actions before each loop iteration.
