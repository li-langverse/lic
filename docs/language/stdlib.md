# Standard library and prelude

The Li **prelude** is the set of builtin types and functions the compiler knows without an import (`int`, `list`, `dict`, `echo`, …).

## Sealed names (security)

You **cannot** define your own `def` or `type` with a name reserved for the prelude or for symbols exported from `std/`. Attempting to do so fails at compile time with `stdlib_symbol_shadow`.

Execution decorator names (`@parallel`, `@cpu`, …) are also reserved; see [Decorators](decorators.md).

## Shipped std/

Today the repository ships **27 `.li` modules** under `std/` (compile harnesses + trusted seams). Names exported from those modules are added to the compiler seal list.

| Import | Path | Maturity |
|--------|------|----------|
| `import std.runtime.seam` | `std/runtime/seam.li` | Trusted extern seam (httpd/net/async) |
| `import std.bytes` | `std/bytes/bytes.li` | Reader/Writer over buffer externs |
| `import std.collections` | `std/collections/collections.li` | WP0-B compile-only stub |
| `import std.heap` | `std/heap/heap.li` | WP0-B compile-only stub |
| `import std.algorithms` | `std/algorithms/algorithms.li` | WP0-B compile-only stub |
| `import std.io` | `std/io/io.li` | PH-IO-4 stub (`io_tag`, file read stub) |
| `import std.csv` | `std/csv/csv.li` | PH-IO-4 stub (CSV row/parse stubs) |
| `import std.summary` | `std/summary/summary.li` | PH-IO-7 stub (summary JSON build stub) |
| `import std.plot` | `std/plot/plot.li` | PH-IO-5 stub (static dashboard stub) |
| `import std.execution.decorators` | `std/execution/decorators.li` | Reserved decorator names |
| `import std.ui` | `std/ui/ui.li` | Color/Rect stub |
| `import std.math` | `std/math/math.li` | Tag facade |
| `import std.physics.*` | `std/physics/*.li` | Tag facades (13 subdomains) |
| `import std.scene` | `std/scene/scene.li` | Tag facade |
| `import std.binary` | `std/binary/binary.li` | Tag facade |

**CI harnesses:** `li-tests/stdlib_seal/` (import without shadow errors) and `li-tests/stdlib_coverage/` (instrumented build). See `scripts/check-stdlib-coverage.sh`.

## Imports (preview)

`import std_math as m` will bind only the module’s public API; you cannot replace `m` or redefine sealed symbols. Full module resolution is Phase **8a**.

## Planned `std/` tree (preview — not implemented)

The [stdlib collections & algorithms plan](../ecosystem/stdlib-collections-algorithms-plan.md) defines Python-parity modules on top of prelude types. **Runtime and exports are WP1+**; blocked until [Wave A exit](../ecosystem/stdlib-collections-algorithms-plan.md#hard-rule--wp1-blocked-until-wp-wa) (**G-lean**, **G-vc**, **G-par**, **G-math** → **Done** in [provability-gaps](../verification/provability-gaps.md)).

```text
std/
├── collections/          # Phase 2 — collections.deque, OrderedDict, Counter, defaultdict
│   ├── deque.li
│   ├── ordered_dict.li
│   ├── counter.li
│   └── defaultdict.li
├── heap/                 # Phase 2 — heapq, PriorityQueue[T]
│   └── heap.li
├── algorithms/           # Phase 2 — sort, bisect, iter subset
│   ├── sort.li
│   ├── search.li
│   └── iter.li
├── tensor.li             # Phase 3 — tensor[Shape, T], tensorview (preview)
├── sparse.li             # Phase 3 — CSR/CSC
├── arena.li              # Phase 3 — ringbuffer, arena/pool
├── btree.li              # Phase 4 — BTreeMap, BTreeSet
└── graph.li              # Phase 4 — static Graph[N, E]
```

**Import paths (target):**

| Import | Role |
|--------|------|
| `import std.collections` | Deque, ordered map, counter, defaultdict |
| `import std.heap` | Binary heap / priority queue on `list` |
| `import std.algorithms` | Sort, binary search, iterator helpers |

**Prelude (Phase 1)** — not under `std/`: `list`, `dict`, `set`, `frozenset`, `str`, `bytes`. See [Data structures roadmap](../superpowers/specs/2026-05-14-li-language-design.md#data-structures-roadmap).

**Shipped today (WP0-B compile-only):** `std/collections`, `std/heap`, and `std/algorithms` — types + no-op stubs; runtime deferred until WP-WA + WP1. **PH-IO ingest:** `std/io`, `std/csv`, `std/summary`, `std/plot` compile harnesses for benchmarks/proof-db without Python/Node.
