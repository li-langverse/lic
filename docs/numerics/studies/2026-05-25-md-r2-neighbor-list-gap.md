# MD neighbor cell-list gap (`md-r2-neighbor-list-gap`)

**Goal:** `md_neighbor_cell_list` (algo **105**) · **North star:** PH-5b (force parity before PH-7e perf)  
**Agent:** `code_implementer` · **Todo:** `sim-p1-md-neighbor-cell`  
**Bench id:** `md_lennard_jones` (brute reference until cell parity @ N=256)

---

## Problem

Registry algo **105** (`md_neighbor_cell_list`) had `implemented_smoke: true` but Li tier-2 `li_md_compute_forces` remained O(N²) brute MIC; composable dispatch returned checksum **1.001** (stub).

## Phase A — composable smoke (completed)

1. **`packages/li-physics-particles/src/lib.li`** — `md_mic`, `md_cell_index_1d`, `md_cells_neighbor`, `md_neighbor_cell_list_force_sum`, `md_neighbor_cell_list_smoke_checksum` (8-particle lattice, box=4.0, rc=2.5; 3×3×3 cell shell).
2. **`packages/li-sim-scientific/src/lib.li`** — `run_md_neighbor_cell_smoke` wired into `run_algo(105)`.
3. **`li-tests/composable/import_physics_particles_neighbor_cell.li`** — package-scoped composable gate.

## Phase B — brute/cell parity @ N=256 (deferred)

- Half-shell linked cell list in `md_core.c`; gate **max |F_cell − F_brute|** @ N=256.
- Tier-2 harness `benchmarks/tier2_physics/md_neighbor_cell_list/` when C kernel diverges from shared LJ oracle.

## Gates

```bash
export LIC_ROOT=$PWD
./scripts/lit li-tests/composable/import_physics_particles_neighbor_cell.li
./scripts/lit packages/li-physics-particles/li-tests/smoke/md_neighbor_cell_list_smoke.li
./scripts/lit packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li
```

## Evidence

| Type | Path |
|------|------|
| Study | `docs/numerics/studies/2026-05-25-md-r2-neighbor-list-gap.md` |
| Survey | `docs/numerics/studies/2026-05-27-md-r0-sota-survey.md` |
| Package | `packages/li-physics-particles` |
| Dispatch | `packages/li-sim-scientific` `run_algo(105)` |
