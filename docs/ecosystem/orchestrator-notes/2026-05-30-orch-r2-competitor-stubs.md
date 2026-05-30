# Orchestrator note — `orch-r2-competitor-stubs`

**Date:** 2026-05-30  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**Work item:** Ingest `verticals.toml` stubs + ecosystem explorer catalog gaps as `competitor_feature` rows

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 68.8; `unattended_safe: false`) |
| `orch-r2` | **Completed** — registry merge conflicts resolved; ingest + apply confirmed |
| `competitor_feature` | **30 open** rows (12 `verticals.toml` stubs + tier-1 red + HPC catalog) |
| `verticals.toml` | Present on lic branch `benchmarks/competitive/verticals.toml` (12 `workload_class = "stub"`) |
| Unattended? | **No** — registry was blocked by merge conflicts until this pass |

Programmatic prep: `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py` (dry-run + live). Closed `gap-plan-pending-swarm-observer-orch-r2-competitor-stubs` in registry.

---

## Gap counts by `gap_kind` (post-ingest)

| `gap_kind` | Open | Total in registry | Discoverer |
|------------|-----:|------------------:|------------|
| `competitor_feature` | 30 | 30 | `gap_explorer`, verticals ingest |
| `plan_debt` | 32 | 57 | `plan_verifier`, snapshot |
| `missing_package` | 3 | 5 | `gap_explorer` |
| **Total** | **65** | **92** | |

**Ingest delta this cycle:** `verticals_stubs: 0` (already present), `competitor_catalog: 0` — idempotent reconcile after conflict resolution.

---

## Verticals.toml stubs ingested

Source: `lic/benchmarks/competitive/verticals.toml` (12 rows with `workload_class = "stub"`):

| Vertical id | Incumbent class |
|-------------|-----------------|
| `md_lennard_jones` | LAMMPS / GROMACS |
| `pde_heat_2d` | OpenFOAM / PETSc |
| `fea_linear_elasticity` | CalculiX / ANSYS |
| `cfd_lid_driven_cavity` | OpenFOAM / COMSOL |
| `drug_litl` | Roche LiTL |
| `bio_litl` | Benchling / Rosetta |
| `scientific_viz` | VTK / ParaView class |
| `cinematic_encode` | FFmpeg class |
| `cinematic_color_grade` | DaVinci class |
| `cinematic_audio_sync` | DAW class |
| `mmo_shard` | game server class |
| `qm_dft` | VASP / Quantum ESPRESSO |

Registry rows: `gap-vertical-stub-*` + tier-1 red (`gap-benchmark-red-*`) + HPC library gaps (`gap-hpc-*`).

---

## Scripts executed

```bash
# Resolved UU merge conflicts in data/swarm-gap-registry/registry.yaml first
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py --dry-run
python3 scripts/swarm-gap-apply-actions.py
```

Apply output: `benchmarks/data/latest/swarm-gap-actions.json` — 9 vertical stub rows patched to `sim-md-research-backlog.md`; tier-1/HPC competitor rows logged (no runner backlog mapping).

---

## Backlog patches (live apply)

| Target | Patches |
|--------|---------|
| `docs/ecosystem/sim-md-research-backlog.md` | 9 × vertical stub competitor rows |
| `docs/ecosystem/sim-algorithm-backlog.md` | sim P1/P2 plan_debt (prior cycle) |
| `docs/ecosystem/ecosystem-package-backlog.md` | 3 × missing_package |

### Deferred (competitor_feature without backlog mapping)

Tier-1 red + HPC catalog rows route via swarm goals:

- `bench_improver` / `numerics_researcher` — `gap-benchmark-red-matmul-naive-tier1`, `num_gmres`, etc.
- `gap_explorer` — `gap-infra-verticals-toml-missing-benchmarks-main` (merge `verticals.toml` to benchmarks main)

---

## Self-heal / control-plane actions

| Layer | Action |
|-------|--------|
| **This cycle** | Fixed `registry.yaml` git merge conflicts (blocked ingest YAML parse) |
| **Registry** | Closed `orch-r2-competitor-stubs`; evidence note path added |
| **apply-actions** | Re-ran live; refreshed `swarm-gap-actions.json` |
| **Next (`orch-r3`)** | `missing_package` sweep — std.summary, std.plot, line_profiler |
| **Next (`orch-r4`)** | `ui_ux` signals from studio-ui-ux pending todos |

No new systemd plan loops. Route via `li-cursor-agents` research/implement goals per `docs/ecosystem/swarm-architecture.md`.

---

## Recommended control-plane fixes

| Priority | Path | Change |
|----------|------|--------|
| P0 | `lic/data/swarm-gap-registry/registry.yaml` | **Done:** resolve merge conflicts before ingest (pre-commit or sweeper) |
| P1 | `lic/scripts/swarm-gap-ingest.py` | Re-ingest when `benchmarks/competitive/verticals.toml` lands on benchmarks main |
| P1 | `li-cursor-agents/src/observer/` | Terminalize `running` > TTL; historical error relabeling |
| P2 | `benchmarks/scripts/ecosystem-quality-grade.py` | Weight `registry.yaml` parse health in briefing_health |
| P2 | `li-cursor-agents/config/research-goals.yaml` | Handoff `swarm_coverage` → `gap_explorer` for verticals main PR |

---

## Human-only blockers

- **Governance / provability PRs** — no auto-merge on `trusted.lean` or roadmap
- **`verticals.toml` on benchmarks main** — requires human PR from lic/benchmarks branch
- **6 red tier-1 benchmarks** — product codegen (`bench_improver` / `numerics_researcher`), not orchestration

---

## Agent deliverable checklist

- [x] `swarm-gap-ingest.py` ran after conflict resolution
- [x] `swarm-gap-apply-actions.py` dry-run + live apply
- [x] 30 `competitor_feature` rows documented; 12 vertical stubs enumerated
- [x] Registry `orch-r2` closed
- [x] Orchestrator note (this file)
- [x] Swarm observer digest under `benchmarks/data/runs/`

**Report:** `benchmarks/data/runs/swarm_observer-1780133166367.md`
