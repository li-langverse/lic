# Benchmark results

## Columns (read `latest.csv` and tier reports)

| Column | Meaning |
|--------|---------|
| **shared_c_kernel** | Li driver links the same C/C++ kernel as `cpp`/`rust`/`julia` via `LI_EXTRA_C` (wall time ≈ native reference). |
| **pure_li** | Logic compiled from `.li` only (`horner_pure_li`, `simd_dot` via `a @ b`, `matmul_naive` / `matmul_blocked` math loops). Often slower until **7e** codegen matures. |

Do not compare `main.li` MD stub wall time to full `md_main.c` without reading [tier2_physics/md_lennard_jones/PERF.md](../tier2_physics/md_lennard_jones/PERF.md).

## Competitive columns policy

Tracked ecosystems live in `benchmarks/competitive/registry.toml` (`cpp`, `rust`, `julia`, `li` in `latest.csv` today). **Watch-only** competitors (Chapel, Kokkos, SYCL, Zig) have no CSV column until a harness driver exists.

- Before publishing cross-language numbers: run `./scripts/check-hpc-competitive.sh` and skill `hpc-competitive-review`.
- **shared_c_kernel** rows compare wall time with the same C core; **pure_li** rows are not parity-gated against `cpp`.
- No performance claims without a reproduced CSV row on documented flags/hardware.
- See `docs/benchmarks/competitive-landscape.md`.

## Policy

- **Tier 0 (stability):** strict invariants must pass for all backends.
- **Tier 2 (physics):** shared-kernel target **≤ 1.2×** C++ on reference hardware (advisory MSD rows until harness fixed).
- **Tier 1 (micro):** pure-Li rows tracked separately; not gated at parity until **2i/7e** complete.

## Tier-1 Li vs C++ gate (7e / G-math)

| Mode | CSV | Command |
|------|-----|---------|
| **Smoke** (CI / fresh clone) | `li-tests/fixtures/tier1_math_perf_smoke.csv` | `./li-tests/tooling/tier1_li_vs_cpp.sh` when `latest.csv` is absent |
| **Advisory** (default) | `benchmarks/results/latest.csv` | `./scripts/check-tier1-li-vs-cpp.sh` — reports GAP rows, exit 0 |
| **Strict** | same | `LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh` — fail if Li > 1.2× C++ |

Pure-Li math benches checked: `simd_dot`, `matmul_naive`, `matmul_blocked`, `horner_pure_li`.

## Regenerate

```bash
python3 benchmarks/harness/bench.py --tier 0
python3 benchmarks/harness/bench.py --tier 1
python3 benchmarks/harness/bench.py --tier 12 --runs 5
```
