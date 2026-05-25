# Execution-resource benchmarks and security exploits

## Summary

Adds cores×threads-per-core competitive sweep CSV, SIMD intrathread labeling, lic resource flags (`--cores`, `--threads-per-core`), and `execution_exploits` CI gates for oversubscribe and memory-bomb caps.

## Agent continuation

1. Read `benchmarks/harness/execution_resource_sweep.py`, `benchmarks/competitive/registry.toml` (`execution_resource_sweep` track).
2. Run `./scripts/build.sh` then `python3 benchmarks/harness/execution_resource_sweep.py --smoke` and `./li-tests/run_all.sh execution_exploits`.
3. Next: stack PR on #206; full sweep on Linux CI (`bench.py --tier 6`).
4. Blocked: none.

## Changed

- `compiler/common/resource_options.{hpp,cpp}` — `--cores`, `--threads-per-core`, cap host cores, `effective_jobs` memory cap
- `compiler/lic/main.cpp` — wire flags on `check`/`build`
- `benchmarks/harness/execution_resource_sweep.py`, `bench.py --tier 6`, `bench_toolchain.py --resource-sweep`
- `benchmarks/runtime_refs/reduce_parallel/` — `li_native`, `cpp_omp`, `cpp_pthread`
- `li-tests/execution_exploits/run.sh`, `scripts/ci-security.sh`, `run_all.sh`
- `benchmarks/competitive/registry.toml` — `execution_resource_sweep` ecosystem

## Not changed

- Tier-0 energy/invariant rows (`bench.py --tier 0` / `stability.py` thresholds)
- Li parallel codegen for reduce (li_native uses serial ref kernel)

## Breaking

N/A — additive harness and CLI flags.

## Security

- `execution_exploits`: `--cores=999999` capped, negative `--threads`/`--cores` rejected, `--jobs` memory bomb capped via `effective_jobs`

## Performance

- `benchmarks/results/execution_resource_sweep.csv` — wall_s, peak_rss_mb, speedup, efficiency = speedup/(cores×tpc)

## Downstream

- `li-langverse/benchmarks` dashboard may ingest `execution_resource_sweep.csv` when published
