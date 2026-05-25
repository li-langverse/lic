# Release notes: 2026-05-25 — tier2-studio-scientific-oracle

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Branch:** `feat/tier2-studio-scientific-oracle` → PR into `main`  
**PH / REQ:** PH-SCI, PH-SIM SIM-1 — tier-2 MD oracle in scientific viewport  
**Author:** agent

---

## Summary (one sentence)

`studio_sim_step_hook` on `sim_scientific` gates the viewport MD tier via `studio_md_particle_tier_select_ok`, links `tier2_bench_row_md_lennard_jones` to `benchmarks/tier2_physics/md_lennard_jones/`, and steps through `sim_scientific_tier2_tick` (stub smoke until `tier2_md_oracle_built` is 1).

## Agent continuation (required)

1. Read: `packages/li-sim-scientific/src/lib.li` (`tier2_bench_row_*`, `tier2_md_oracle_built`, `sim_scientific_tier2_tick`), `packages/li-studio/src/lib.li` (`studio_scientific_viewport_tier_id`, `studio_sim_step_hook` scientific branch).
2. Run: `lic check --workspace`; `lic check packages/li-studio/li-tests/smoke/studio_scientific_tier2_hook.li`; `lic check li-tests/composable/import_studio_scientific_tier2_hook.li`.
3. Then: flip `tier2_md_oracle_built` when `benchmarks/harness/md_external_oracle.py` + LAMMPS/GROMACS drivers pass verify; wire native viewport to `benchmarks/results/md_lennard_jones/` checksum rows.
4. Blocked on: external oracle binaries on CI runners — **not** required for this stub-link PR.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `packages/li-sim-scientific` | `tier2_bench_row_md_lennard_jones`, path tags 101/201, `sim_scientific_tier2_tick` | `studio_scientific_tier2_hook.li` |
| `packages/li-studio` | `studio_scientific_viewport_tier_id`; scientific branch calls tier gate + tier2 tick | `studio_sim_step_hook` |
| `packages/li-studio/li-tests` | `smoke/studio_scientific_tier2_hook.li` | package manifest |
| `li-tests/composable` | `import_studio_scientific_tier2_hook.li` | monorepo manifest |
| `docs/release-notes/2026-05-25-tier2-studio-scientific-oracle.md` | this file | agent continuation |

## Not changed (scope fence)

- `benchmarks/tier2_physics/md_lennard_jones/common/md_core.c` — **not** modified (read-only harness link via row id/tags).
- `tier2_md_oracle_built` — returns **0** (external LAMMPS/GROMACS column still stub).
- `SimWorld` / replay buffers (SIM-2) — **not** implemented.
- `physics_sync_from_scene` / scene entity mutation — **not** wired.
- LLVM / httpd / tier5 — **not** touched.

## Breaking / Security / Performance / Downstream

- **Breaking:** None — `studio_sim_step_hook` still returns `sim_status_*`; scientific path adds tier gate before tick.
- **Security:** N/A — no new I/O; bench row tags are compile-time constants.
- **Performance:** N/A — same O(1) `run_md_lj_smoke` stub per frame until oracle built.
- **Downstream:** Studio native timeline on `sim_scientific` inherits tier-2 row pointer; benchmarks dashboard rows unchanged.
