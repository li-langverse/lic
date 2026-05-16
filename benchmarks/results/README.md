# Benchmark results

## Columns (read `latest.csv` and tier reports)

| Column | Meaning |
|--------|---------|
| **shared_c_kernel** | Li driver links the same C/C++ kernel as `cpp`/`rust`/`julia` via `LI_EXTRA_C` (wall time ≈ native reference). |
| **pure_li** | Logic compiled from `.li` only (`horner_pure_li`, `simd_dot`, future matmul). Often slower until **7e** codegen matures. |

Do not compare `main.li` MD stub wall time to full `md_main.c` without reading [tier2_physics/md_lennard_jones/PERF.md](../tier2_physics/md_lennard_jones/PERF.md).

## Policy

- **Tier 0 (stability):** strict invariants must pass for all backends.
- **Tier 2 (physics):** shared-kernel target **≤ 1.2×** C++ on reference hardware (advisory MSD rows until harness fixed).
- **Tier 1 (micro):** pure-Li rows tracked separately; not gated at parity until **2i/7e** complete.

## Regenerate

```bash
python3 benchmarks/harness/bench.py --tier 0
python3 benchmarks/harness/bench.py --tier 12 --runs 5
```
