# stdlib_parity — Python collections / heapq / bisect design corpus

Compile-only gates for Li stdlib ADT parity (WP0-D). Each `.li` file maps one Python
stdlib micro-module to future `std/collections`, `std/heap`, or `std/algorithms` APIs.

| File | Python module | Future Li module | Benchmark id (WP0-C) |
|------|---------------|------------------|----------------------|
| `collections_parity.li` | `collections` (deque, OrderedDict, Counter, defaultdict) | `std/collections/*` | `stdlib_deque_rotate`, `stdlib_ordered_dict_iter` |
| `heapq_parity.li` | `heapq` | `std/heap/heap.li` | `stdlib_heap_push_pop` |
| `bisect_parity.li` | `bisect` | `std/algorithms/search.li` | `stdlib_binary_search` |

## Runtime parity

**Not in scope for WP0-D.** Execution and checksum parity against `reference.py` wait for:

- **WP-WA** — strict Wave A exit (`G-lean`, `G-vc`, `G-par`, `G-math` Done)
- **WP1** — prelude `list` / `dict` / `set` runtime
- **WP2** — `std/collections`, `std/heap`, `std/algorithms` implementations

Until then, `li-tests/run_all.sh stdlib_parity` runs **compile_ok** only (types + contracts sketch).
