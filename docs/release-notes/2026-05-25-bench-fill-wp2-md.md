# Release notes: 2026-05-25 — bench-fill-wp2-md

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (feat/bench-fill-wp2-md)  
**PH / REQ:** PH-5b  
**Author:** agent

---

## Summary (one sentence)

WP2 fills all 14 `benchmarks/catalog.toml` `md_*` rows with runnable `tier2_physics` harness dirs (LJ oracle template) and registers them in `bench.py`, plus contract/`--verify` fixes for five existing tier-2 kernels.

## Agent continuation (required)

1. Read: `benchmarks/harness/bench.py` `TIER2_BENCHES`, `benchmarks/tier2_physics/md_*/README.md`, `../benchmarks/catalog.toml` `md_*` paths.
2. Run: `python3 benchmarks/harness/bench.py --tier 2 --only md_integrator_verlet,three_body_pure,orbit_two_body --runs 1 --skip-verify`
3. Then: replace LJ-alias stubs with algorithm-specific C cores per `md_*` id (verlet, PME, shake, …) and add `benchmarks` catalog `path =` updates when kernels diverge.
4. Blocked on: human merge; benchmarks dashboard ingest after catalog path PR in `benchmarks` repo.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| tier2_physics | 13 `md_*` dirs gained `common/md_core.c`, `cpp/md_main.c`, `li/main.li`, `README.md` (alias `md_lennard_jones` oracle) | `scripts/scaffold_md_catalog_benches.py`; dirs under `benchmarks/tier2_physics/md_*` |
| harness | 14 `BenchSpec` rows for catalog `md_*` ids in `TIER2_BENCHES` | `benchmarks/harness/bench.py` |
| runnable fixes | `three_body_pure`, `schrodinger_1d_barrier`, `ragdoll_chain`, `orbit_two_body`, `fdtd_waveguide_2d` Li contracts + `--verify` cpp drivers + `params.toml` | `bench.py --tier 2 --only …` exit 0 locally |

## Not changed (scope fence)

- `benchmarks/catalog.toml` path fields (`unknown` → concrete paths) — **benchmarks** repo ingest follow-up.
- `md_lennard_jones` stress/trace/julia/rust full matrix — **not** duplicated per alias stub.
- Pure-Li `three_body_pure` integrator body — reverted to shared C oracle for `lic` contract compliance.
- LLVM/OpenMP codegen, `trusted.lean`, studio viewport — **not** in this PR.

## Breaking changes

None.

## Security

N/A — harness-only; shared existing `md_core.c` / tier-2 C kernels; no new trusted surface.

## Performance

N/A for merge gate — alias `md_*` rows time the same LJ oracle as `md_lennard_jones` until per-algorithm kernels land. Reproduce: `python3 benchmarks/harness/bench.py --tier 2 --only md_energy_drift --runs 3`.

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | Update `catalog.toml` `path =` for 13 `md_*` rows from `unknown` to `benchmarks/tier2_physics/<id>` after lic merge |
| lip / lit | N/A |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **WP2 md_* tier2 fill:** 13 catalog `md_*` harness stubs (LJ oracle template), `bench.py` registration, five tier-2 kernel runnable fixes — PH-5b ([#PR](URL))
```
