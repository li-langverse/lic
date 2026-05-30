# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-30  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Work item:** Ingest `verticals.toml` stubs + ecosystem explorer catalog gaps as `competitor_feature` rows.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Recovering** — ecosystem grade **B** (80.0); `unattended_safe: true` after scorecard refresh |
| `competitor_feature` open | **30** (HPC catalog + tier-1 red rows + vertical stubs) |
| Vertical stubs ingested | **14** `workload_class=stub` rows in `lic/benchmarks/competitive/verticals.toml` |
| Backlog patches | **9** rows appended to `sim-md-research-backlog.md` (8 vertical + md_lennard_jones) |
| `orch-r2` status | **Completed** — registry + apply pipeline; hand off red benchmarks to `bench_improver` |

---

## Evidence paths

| Artifact | Path |
|----------|------|
| Vertical registry | `lic/benchmarks/competitive/verticals.toml` (on `perf/bench-improver-matmul-at-op-20260530`) |
| Gap registry | `lic/data/swarm-gap-registry/registry.yaml` |
| Apply manifest | `benchmarks/data/latest/swarm-gap-actions.json` |
| Explorer catalog | `benchmarks/data/latest/ecosystem-explorer.json` (`catalog_gaps`, `missing_std_modules`) |
| Sim research backlog | `lic/docs/ecosystem/sim-md-research-backlog.md` |

---

## Scripts executed

```bash
cd lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
```

**Ingest delta (2026-05-30T09:59Z):** `verticals_stubs: 0`, `competitor_catalog: 0` (idempotent — rows already present). Registry total **90** gaps, **65** open (`30` competitor_feature, `32` plan_debt, `3` missing_package).

**Apply patches (competitor verticals):**

- `gap-vertical-stub-md-lennard-jones` → `sim-md-research-backlog.md`
- `gap-vertical-stub-drug-litl`, `bio-litl`, `scientific-viz`, `cinematic-*`, `mmo-shard`, `qm-dft` → same backlog

Deferred apply (no backlog mapping): master-plan `plan_debt` rows, `orch-r2` orchestrator todo row until this note landed.

---

## Gap taxonomy (`competitor_feature`)

| Source | Count | Handoff |
|--------|------:|---------|
| `verticals.toml` `workload_class=stub` | 14 | `sim-md-research`, `gap_explorer` |
| Explorer `catalog_gaps` / tier-1 red | ~16 | `bench_improver`, `numerics_researcher`, `issue_planner` |
| Infra: `verticals.toml` on benchmarks `main` | 1 | `code_implementer` (merge lic branch) |

Do **not** install new systemd plan loops — route via `li-cursor-agents` research/implement goals per `docs/ecosystem/swarm-architecture.md`.

---

## Recommended handoffs (swarm goals)

| Agent | Reason |
|-------|--------|
| `bench_improver` | Tier-1 yellow `matmul_blocked`, `matmul_naive` (briefing @ 09:46Z) |
| `gap_explorer` | Reconcile remaining catalog gaps after vertical ingest |
| `sim` plan loop / `code_implementer` | `sim-p1-*` backlog rows patched pending |
| `issue_planner` | Package backlog `pkg-std-summary`, `pkg-std-plot` |

---

## Human-only blockers

- **`verticals.toml` on benchmarks `main`** — file lives on lic perf branch; needs human merge PR (not auto-merge).
- **GitHub GraphQL rate limit** — blocked `workspace_sweeper` PR creation @ 09:58Z (user ID 207167228).
- **Governance / provability** — no change to `trusted.lean` via gap apply.

---

## Next orchestration todo

- **`orch-r3-missing-package-sweep`** — partially done in prior pass; confirm `ecosystem-package-backlog.md` pending rows.
- **`orch-r4-ui-ux-signals`** — studio-ux-16/17 patched to plan loop doc this cycle (incidental apply).
