# Benchmark timing repetitions

Micro-benchmarks with sub-millisecond wall time need many timed samples before medians and spread are trustworthy.

## Defaults (full org suite)

`benchmarks/scripts/run-full-benchmark-suite.sh` exports:

| Variable | Default | Meaning |
|----------|---------|---------|
| `BENCH_RUNS` | `3` | CLI `--runs` floor passed to `bench.py` |
| `BENCH_MIN_RUNS` | `20` | Minimum timed repetitions after warmup |
| `BENCH_TARGET_SAMPLE_SEC` | `1.0` | Target aggregate sample time per command |
| `BENCH_MAX_RUNS` | `200` | Cap for very fast kernels |
| `BENCH_ADAPTIVE_RUNS` | `1` | Probe then scale (set `0` to disable) |

`benchmarks/harness/bench.py` discards one warmup, probes three samples, then runs until `resolve_timing_runs()` is satisfied.

## CI / quick paths

`scripts/ci-bench.sh` keeps `--runs 1` and does not set `BENCH_MIN_RUNS`.

## Debugging spread

```bash
BENCH_TIMING_VERBOSE=1 BENCH_MIN_RUNS=30 python3 benchmarks/harness/bench.py --tier 1 --only horner_pure_li
```
