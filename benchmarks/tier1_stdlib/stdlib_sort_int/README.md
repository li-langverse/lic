# stdlib_sort_int (tier-1 stdlib oracle)

Sort **N = 1_000_000** deterministic `int64` values (`qsort` in C; same in `reference.py`), checksum = sum of sorted elements as `float64`.

**WP0:** C++ oracle only; Li driver lands in WP1.

## Build / verify (standalone)

```bash
cd benchmarks/tier1_stdlib/stdlib_sort_int
cc -O3 -march=native cpp/main.c common/sort_core.c -o /tmp/stdlib_sort_int
/tmp/stdlib_sort_int --verify
python3 reference.py --verify-cpp
```

## Harness (native-only until WP1)

```bash
python3 benchmarks/harness/bench.py --tier 4 --verify-results --only stdlib_sort_int
python3 benchmarks/harness/bench.py --tier 4 --only stdlib_sort_int --skip-verify
```

Honesty: `benchmarks/competitive/stdlib_registry.toml` — `kernel_honesty = reference_native`; Python `reference_only`.
