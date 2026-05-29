# md_neighbor_cell_list — cell-shell neighbor smoke (algo_id=105)

**Todo:** `sim-p1-md-neighbor-cell`  
**Package:** `li-physics-particles` (`import physics.particles`)  
**Registry algo:** `md_neighbor_cell_list` (id=105)  
**Status:** `implemented_smoke: true` (composable + `run_algo` dispatch)

## Slice (2026-05-29)

1. **`packages/li-physics-particles/src/lib.li`** — Added `md_mic`, `md_cell_index_1d`, `md_cells_neighbor`, `md_neighbor_cell_list_force_sum`, and `md_neighbor_cell_list_smoke_checksum()` (8-particle lattice, box=4.0, rc=2.5; 3×3×3 cell shell).
2. **`li-tests/composable/import_physics_particles_neighbor_cell.li`** — Composable smoke gate for package-scoped benches.
3. **`packages/li-sim-scientific/src/lib.li`** — Wired `run_md_neighbor_cell_smoke` into `run_algo` for algo_id=105.
4. **`packages/li-sim/src/lib.li`** — Added `algo_md_neighbor_cell_list()` constant (105).
5. **`benchmarks/manifest.toml`** — Composable mapping for `li-physics-particles`.

## Validity

| Check | Result |
|-------|--------|
| Composable `import_physics_particles_neighbor_cell.li` | **ok** |
| `SIM_PLAN_PACKAGE=li-physics-particles ./scripts/sim-plan-gates.sh` | **ok** (2026-05-29) |
| Registry `implemented_smoke` | **true** (id=105) |

```bash
export LIC_ROOT=$PWD
export SIM_PLAN_PACKAGE=li-physics-particles
./scripts/sim-plan-gates.sh
```

## Follow-ups

- Full half-shell linked cell list in `md_core.c` with parity gate vs brute force @ N=256.
- Tier-2 harness row `benchmarks/tier2_physics/md_neighbor_cell_list/` when C kernel diverges from shared LJ oracle.
