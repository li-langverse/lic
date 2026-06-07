# Release notes: 2026-05-27 — bench-adaptive-timing-runs

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (branch `cursor/bench-adaptive-timing-runs-ce9b`)  
**PH / REQ:** PH-5b, PH-7e  

---

## Summary

Tier-1 harness scales timed repetitions to at least 20 samples (or ~1s aggregate) for sub-millisecond micro-benches so medians and spread are statistically usable.

## Agent continuation

1. Read: `docs/ecosystem/bench-timing-runs.md`, `benchmarks/results/README.md`.
2. Run: `BENCH_TIMING_VERBOSE=1 BENCH_MIN_RUNS=20 python3 benchmarks/harness/bench.py --tier 1 --only horner_pure_li` (after `./scripts/build.sh`).
3. Then: Re-ingest benchmarks dashboard; fix ULP validity on `horner_pure_li` / `reduce_sum` if still red.
4. Blocked on: none for harness; merge requires human review.

## Changed

| Area | What | Evidence |
|------|------|----------|
| Harness | `resolve_timing_runs`, adaptive `time_command` | `benchmarks/harness/bench.py` |
| Docs | Env table for `BENCH_MIN_RUNS` | `docs/ecosystem/bench-timing-runs.md` |

## Not changed

- LLVM codegen / horner kernel math — not in this PR  
- Dashboard `summary.json` — refresh in benchmarks follow-up  
- CI `ci-bench.sh` still uses `--runs 1`

## Breaking changes

None.

## Security

N/A — timing harness only.

## Performance

N/A for merge claims — full-suite wall time increases when `BENCH_MIN_RUNS=20`; CI fast path unchanged.

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | Export `BENCH_MIN_RUNS` already in `run-full-benchmark-suite.sh` |

## CHANGELOG entry

### Changed

- **Bench timing:** adaptive repetitions (`BENCH_MIN_RUNS` default 20 in org full suite) — `docs/release-notes/2026-05-27-bench-adaptive-timing-runs.md`.
