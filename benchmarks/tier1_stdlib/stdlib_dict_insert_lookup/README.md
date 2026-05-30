# stdlib_dict_insert_lookup (tier-1 stdlib oracle)

Open-addressing hash table: **500_000** insert + lookup rounds, linear probing, checksum = sum of looked-up values.

**WP0:** C++ oracle only; Li `dict` runtime in WP1.

## Build / verify (standalone)

```bash
cd benchmarks/tier1_stdlib/stdlib_dict_insert_lookup
cc -O3 -march=native cpp/main.c common/dict_core.c -o /tmp/stdlib_dict_insert_lookup
/tmp/stdlib_dict_insert_lookup --verify
python3 reference.py --verify-cpp
```

## Harness

```bash
python3 benchmarks/harness/bench.py --tier 4 --verify-results --only stdlib_dict_insert_lookup
```
