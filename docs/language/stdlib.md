# Standard library and prelude

The Li **prelude** is the set of builtin types and functions the compiler knows without an import (`int`, `list`, `dict`, `echo`, …).

## Sealed names (security)

You **cannot** define your own `def` or `type` with a name reserved for the prelude or for symbols exported from `std/`. Attempting to do so fails at compile time with `stdlib_symbol_shadow`.

Execution decorator names (`@parallel`, `@cpu`, …) are also reserved; see [Decorators](decorators.md).

## Shipped std/

Today the repository ships minimal std under `std/` (e.g. `std/execution/decorators.li`). As the std tree grows, names exported from those modules are added to the compiler seal list.

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

**Shipped today:** `std/execution/decorators.li` and other non-ADT modules only; no `std/collections`, `std/heap`, or `std/algorithms` sources yet.
