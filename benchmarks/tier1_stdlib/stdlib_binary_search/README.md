# stdlib_binary_search (tier-1 stdlib oracle)

Sorted `int64` array (implicit order), **200_000** binary searches; checksum sums found values (-1 on miss).

WP0 C++ oracle; Li driver in WP1.

```bash
cc -O3 -march=native cpp/main.c common/search_core.c -o /tmp/stdlib_binary_search
/tmp/stdlib_binary_search --verify
python3 reference.py --verify-cpp
```
