# Release notes: 2026-05-28 — benchmark mean ± σ timing

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `cursor/bench-mean-std-runs-5599`  

---

## Summary

Tier harness reports **arithmetic mean** and **sample stddev** in `latest.csv` (`value`, `stddev`, `sample_runs`), with ≥6 runs default and ≥20 for sub-second wall times.

## Agent continuation

1. Run: `BENCH_RUNS=6 python3 benchmarks/harness/bench.py --tier 1 --only horner_pure_li --skip-verify`
2. Confirm CSV: `horner_pure_li,li,...,wall_time,0.0006,0.000164,200,s,...`
3. Merge benchmarks dashboard PR after ingest refresh.

## Changed

| Path | What |
|------|------|
| `benchmarks/harness/timing_stats.py` | mean, adaptive runs, min 6 / subsec 20 |
| `benchmarks/harness/bench.py` | CSV columns `stddev`, `sample_runs` |
| `benchmarks/harness/bench_ecosystem.py` | same timing module; parallel compile when `BENCH_JOBS>1` |
| `benchmarks/harness/bench_http.py` | wrk/TTFB mean ± σ; `measured_runs` default 6 |
| `benchmarks/harness/bench_toolchain.py` | mean ± σ on `wall_s` |
| `benchmarks/harness/execution_resource_sweep.py` | mean ± σ on `wall_s` |
| `benchmarks/tier5_http/defaults.toml` | `measured_runs = 6` |

## Not changed

- Tier-5 multi-oracle vendor harness (`vendor/lis-tier5`) — separate ingest path.
- Tier 0 / exploits — not timed with `timing_stats.py`.

## Performance

Evidence: `horner_pure_li` sub-second → `n=200` capped by `BENCH_MAX_RUNS` (≥20 satisfied).

## CHANGELOG

### Changed

- Harness timing uses **mean ± sample stddev** with `stddev` / `sample_runs` CSV columns; default ≥6 runs, ≥20 when mean wall &lt; 1s — [2026-05-28-bench-mean-std-timing.md](docs/release-notes/2026-05-28-bench-mean-std-timing.md).
