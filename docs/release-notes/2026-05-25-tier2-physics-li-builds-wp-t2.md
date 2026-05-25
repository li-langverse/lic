# Release notes: 2026-05-25 — tier2-physics-li-builds-wp-t2

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** feat/fix-tier2-li-builds  
**PH / REQ:** Phase 5b benchmarks (WP-T2 tier-2 physics Li harness)  
**Author:** agent

---

## Summary (one sentence)

Tier-2 physics Li wrappers for `cloth_swing`, `combustion_passive`, `euler_fluid_2d`, `rigid_body_stack`, and `wind_field_bc` now satisfy extern contract + `raises IO` gates and emit checksums via `li_rt_volatile_sink_f64` so `bench.py --tier 2` produces CSV rows instead of compile failures.

## Agent continuation (required)

1. Read: `benchmarks/tier2_physics/*/li/main.li` (five kernels above); `benchmarks/harness/bench.py` `build_li` / `verify_benchmark_results`.
2. Run: `./scripts/build.sh` then `python3 benchmarks/harness/bench.py --tier 2 --only cloth_swing,combustion_passive,euler_fluid_2d,rigid_body_stack,wind_field_bc --runs 3`.
3. Then: ingest `benchmarks/results/latest.csv` to benchmarks dashboard if publishing perf rows; extend same pattern to remaining tier-2 stubs (`orbit_two_body`, etc.) if CI still reports `unknown`.
4. Blocked on: human merge; no self-merge.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Harness | `extern proc` `requires`/`ensures`, `main raises IO`, checksum sink | `bench.py --tier 2 --only` five ids → `verify ok` + `updated latest.csv` |
| Paths | `benchmarks/tier2_physics/{cloth_swing,combustion_passive,euler_fluid_2d,rigid_body_stack,wind_field_bc}/li/main.li` | local run 2026-05-25 |

## Not changed (scope fence)

- Shared C oracles (`common/*_core.c`), `bench.py` spec table, compiler contract policy, `li-tests` corpus, Lean/`trusted.lean`, tier-0/1 benches, dashboard ingest scripts.

## Breaking / Security / Performance

| Category | Status |
|----------|--------|
| Breaking | N/A — benchmark wrapper-only |
| Security | N/A — no trusted surface |
| Performance | N/A — harness timing only; no codegen change |

## Downstream

N/A — benchmarks repo ingest optional after merge.
