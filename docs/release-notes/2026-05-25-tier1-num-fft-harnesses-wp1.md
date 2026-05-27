# Release notes: 2026-05-25 — tier1-num-fft-harnesses-wp1

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (feat/bench-fill-wp1-num)  
**PH / REQ:** PH-5b, PH-7e  
**Author:** agent

---

## Summary (one sentence)

Adds tier-1 micro harness directories for all catalog `num_*` benchmarks plus `fft_1d_fixed`, each with `params.toml`, shared-C oracle, Li driver, and `bench.py` registration.

## Agent continuation (required)

1. Read: `benchmarks/tier1_micro/<id>/`, `benchmarks/harness/bench.py` (`_WP1_NUM_IDS`), `../benchmarks/catalog.toml` num rows.
2. Run: `python3 benchmarks/harness/bench.py --tier 1 --verify-results --only num_cg` (or full WP1 list); merge after CI green.
3. Then: benchmarks WP5 `sync-paths-from-lic-tree.py` to set catalog `path` fields; WP7 full bench run.
4. Blocked on: none

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Harness dirs | 17 new `benchmarks/tier1_micro/<id>/` (16× `num_*` + `fft_1d_fixed`) | `scripts/gen_wp1_tier1_num_harnesses.py` |
| Harness | `TIER1_BENCHES` extended via `_wp1_num_bench_specs()` | `bench.py --verify-results` 17/17 ok |
| Registry | `implemented_smoke: true` for catalog `num_*` in algo_registry | `benchmarks/competitive/algo_registry.json` |

## Not changed (scope fence)

- Tier-2 physics / CFD / FEA / QM harnesses (WP2–WP4) — **not** in this PR
- `benchmarks` catalog `path` column sync — **WP5** in benchmarks repo
- Full `latest.csv` measurement sweep — **WP7**
- Pure-Li numerics implementations (smoke uses shared C oracle via `LI_EXTRA_C`)

## Breaking changes

None

## Security

N/A — smoke microbench kernels only; no trusted surface change.

## Performance

N/A — harness scaffolding; ratios documented after WP7 ingest (dashboard).

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | WP5 path sync + WP7 ingest after lic merge |
| lip / lit / lis | N/A |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- Tier-1 micro harnesses for catalog `num_*` + `fft_1d_fixed` (PH-5b) — `benchmarks/tier1_micro/`, `bench.py` registration
```
