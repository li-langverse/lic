# Release notes: 2026-05-25 — bench-fill-wp4-qm-auto-ml-viz

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `feat/bench-fill-wp4-qm`  
**PH / REQ:** PH-5b, fill-all-benchmarks WP4  

---

## Summary (one sentence)

Adds compile-only catalog smokes for all 45 `qm_*`, `auto_*`, `ml_*`, and `viz_*` registry rows under `benchmarks/tier{1,2}_*/<id>/li/main.li`, wired through `verify.py --catalog-smoke-only` (family templates; honest red vs cpp deferred to WP7 timing).

## Agent continuation (required)

1. Read: `benchmarks/harness/catalog_smoke.py`, `scripts/generate-wp4-catalog-smokes.py`, `benchmarks/competitive/algo_registry.json`.
2. Run: `./scripts/build.sh` then `python3 benchmarks/harness/verify.py --catalog-smoke-only` (expect 45× PASS).
3. Then: benchmarks repo WP5 — `scripts/catalog/sync-paths-from-lic-tree.py` to set `catalog.toml` `path` from `benchmarks/tier1_micro|tier2_physics/<id>`; WP7 full `bench.py` timing (expect red vs cpp).
4. Blocked on: none for compile smokes; dedicated QM/auto/ml/viz kernels remain future work.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Harness dirs | 45× `harness.toml` + `params.toml` + `li/main.li` (10 new tier1 `ml_*`/`viz_*` dirs; qm/auto dirs gained `li/main.li`) | `python3 scripts/generate-wp4-catalog-smokes.py` |
| Verify | `catalog_smoke.py`, `verify.py --catalog-smoke-only`, contract test `test_wp4_catalog_smoke_compiles` | 45× PASS catalog-smoke |
| Registry | `implemented_smoke: true` for qm/auto/ml/viz families | `scripts/build_algo_registry.py` |
| Family timing | `bench_registry.py` / `generate-registry-harnesses.py` templates for `ml`→`matmul_naive`, `viz`→`horner_pure_li` | tier-7 alias timing unchanged semantics |

## Not changed (scope fence)

- `benchmarks/catalog.toml` path fields (`unknown`) — **benchmarks** WP5 sync, not this PR.
- Native/cpp parity checksums for qm/auto/ml/viz ids — template kernels only; no new `BenchSpec` rows in `bench.py`.
- `li-math` / `lig` package implementations — catalog still lists those packages; smokes live in **lic** tree for dashboard path honesty.

## Breaking changes

None.

## Security

N/A — compile-only smokes; no new trusted surface.

## Performance

N/A for merge gate — WP7 `bench.py --tier 7` family aliases may report red vs cpp until dedicated kernels land; documented honest deferral.

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | WP5 sync `path` + ingest after WP7 CSV |
| li-math / lig | optional future move of tier1 smokes into package repos |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **Bench fill WP4:** compile smokes for `qm_*`, `auto_*`, `ml_*`, `viz_*` catalog rows (`catalog_smoke.py`, 45× `li/main.li`) — [2026-05-25-bench-fill-wp4-qm-auto-ml-viz.md](docs/release-notes/2026-05-25-bench-fill-wp4-qm-auto-ml-viz.md).
```
