# Release notes: 2026-05-25 — bench-fill-wp3-pde-robo-am

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `feat/bench-fill-wp3-pde`  
**PH / REQ:** PH-5b  
**Author:** agent

---

## Summary (one sentence)

Adds smoke-scale tier-2 harness trees (`li/main.li`, `params.toml`, C kernels) for catalog families `pde_*`, `robo_*`, `drug_*`, `bio_*`, `am_*`, and refreshes `euler_fluid_2d` so benchmarks path sync can clear `path = unknown`.

## Agent continuation (required)

1. Read: `benchmarks/docs/dashboard/fill-all-benchmarks-plan.md` (WP3/WP5); `scripts/gen_wp3_tier2_harnesses.py`; sibling `benchmarks/scripts/catalog/wire-registry-paths.py`.
2. Run: `python3 scripts/gen_wp3_tier2_harnesses.py` (idempotent); `LIC=$(./scripts/resolve-lic.sh)` and `LI_EXTRA_C=benchmarks/tier2_physics/pde_cfl_timestep/common/pde_cfl_timestep_core.c "$LIC" build benchmarks/tier2_physics/pde_cfl_timestep/li/main.li -o /tmp/smoke --release`; in **benchmarks** repo: `python3 scripts/catalog/wire-registry-paths.py ../lic`.
3. Then: WP7 full bench run / ingest; optionally register WP3 ids in `benchmarks/harness/bench.py` `TIER2_BENCHES` for native timing (not only family-template aliases).
4. Blocked on: **benchmarks** PR to run `wire-registry-paths.py` and refresh dashboard (lic paths alone do not update `catalog.toml` on main until WP5).

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Generator | `scripts/gen_wp3_tier2_harnesses.py` — 26 ids + `euler_fluid_2d` patch | `python3 scripts/gen_wp3_tier2_harnesses.py` |
| Harness dirs | `benchmarks/tier2_physics/{pde_*,robo_*,drug_*,bio_*,am_*}/` with `li/main.li`, `cpp/main.c`, `common/*_core.c`, `params.toml` | dirs exist under `benchmarks/tier2_physics/` |
| Fluid | `euler_fluid_2d` — `params.toml`, header, `main.li` contract + checksum sink | `LI_EXTRA_C=.../euler_fluid_core.c` build smoke |

### Catalog ids covered (27)

`pde_cfl_timestep`, `pde_heat_implicit_jacobi`, `robo_multibody_step`, `robo_ik_jacobian`, `robo_plan_rrt`, `robo_plan_prm`, `robo_traj_opt`, `drug_litl_stages`, `drug_docking_score_vina`, `drug_docking_diffusion`, `drug_ml_retrain_loop`, `drug_fep_alchemical`, `bio_rosetta_energy`, `bio_rotamer_packing`, `bio_proteinmpnn`, `bio_rfdiffusion`, `am_plane_mesh_intersect`, `am_polygon_clip`, `am_slice_layers`, `am_offset_perimeters`, `am_infill_grid_lines`, `am_infill_gyroid`, `am_support_tree`, `am_toolpath_arcs`, `am_thermal_warp`, `am_export_gcode_3mf`, `euler_fluid_2d` (fluid family).

## Not changed (scope fence)

- **benchmarks** `catalog.toml` paths — updated by WP5 `wire-registry-paths.py`, not in this lic PR.
- **qm_*, auto_*, ml_*, viz_*** — WP4 scope; no new kernels here.
- **bench.py** `TIER2_BENCHES` — WP3 dirs are ingest/audit-ready; native bench tuple registration deferred.
- **Physics correctness / proofs** — smoke loops only; not production CFD/docking/AM.

## Breaking changes

None.

## Security

N/A — benchmark harness stubs only; no trusted surface or network.

## Performance

N/A — no threshold or dashboard claims; WP7 bench run pending.

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | Run `wire-registry-paths.py` after merge; ingest WP7 |
| lip / lit / lis | N/A |

## CHANGELOG entry (paste into Unreleased)

- **Bench fill WP3:** tier-2 harnesses for `pde_*`, `robo_*`, `drug_*`, `bio_*`, `am_*`, `euler_fluid_2d` — [2026-05-25-bench-fill-wp3-pde-robo-am.md](docs/release-notes/2026-05-25-bench-fill-wp3-pde-robo-am.md).
