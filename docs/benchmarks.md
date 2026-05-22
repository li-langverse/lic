# Benchmarks

Li ships a reproducible cross-language benchmark harness under `benchmarks/`.
Every tier-2 physics simulation uses **one shared C kernel** per benchmark;
`cpp`, `rust`, and `julia` labels run identical machine code, while `li` links
the same `.c` file through `lic` (`LI_EXTRA_C`).

## Tiers

| Tier | Scope | CI gate |
|------|-------|---------|
| 0 | `li-tests` + verify + MD stability (strict) | `./scripts/ci.sh` |
| 1 | Micro kernels (`simd_dot`, matmul, horner) | `./scripts/ci-bench.sh` |
| 2 | Physics sims (MD, N-body, wave, heat, pendulum) | manual / weekly workflow |
| 3 | HTTP / li-httpd vs nginx, apache, node, … | `benchmarks/scripts/run-full-benchmark-suite.sh` |
| 4 | HTTP exploit grid (CVE-style harness) | same suite (`SKIP_EXPLOITS=1` to skip) |
| 5 | Ecosystem: compile time, lip/lit smoke, security timing | **deferred** — `RUN_TIER5_ECOSYSTEM=1` |

## Stability vs speed

- **Throughput** rows use low-density lattice params (`params.toml` `[perf]`).
- **Conservation** rows use `md_stress.c` at liquid density ρ=0.75.
- Strict gates: harmonic oscillator (Swope) + momentum invariant.
- Advisory gates: Allen–Tildesley energy MSD + timestep halving (not CI-blocking).

```bash
python3 benchmarks/harness/stability.py
python3 benchmarks/harness/bench.py --tier 12 --runs 3 --skip-verify
# Optional when ecosystem benches are ready:
# RUN_TIER5_ECOSYSTEM=1 python3 benchmarks/harness/bench_ecosystem.py --runs 3
./scripts/plot_shareables.sh
```

## Dashboard ([li-langverse/benchmarks](https://github.com/li-langverse/benchmarks))

CI on `lic` `dev`/`main` uploads `benchmarks/results/latest.csv` (+ `stability.csv`, `security.csv`) and dispatches ingest.
Add new benchmark ids to the org **`catalog.toml`** — see [benchmarks-catalog-additions.toml](ecosystem/benchmarks-catalog-additions.toml) for tier-3 rows (async, effects, security).

Published site: [li-langverse.github.io/benchmarks](https://li-langverse.github.io/benchmarks/).

See the [benchmarks implementation plan](superpowers/plans/2026-05-14-benchmarks-and-simulations.md)
for the full matrix and publication workflow.
