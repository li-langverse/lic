# Stdlib collections & algorithms — maintainer plan

**Status:** Active (WP0-A — 2026-05-26)  
**Audience:** `lic` / `benchmarks` maintainers, agents  
**Canonical types:** [Data structures roadmap](../superpowers/specs/2026-05-14-li-language-design.md#data-structures-roadmap) · [Collections and generics](../language/collections-generics.md)  
**Ecosystem scheduling:** [algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md) · **AL-14…AL-18**  
**Proof honesty:** [provability-gaps.md](../verification/provability-gaps.md)

This document is the **stdlib ADT program** companion to the language design spec: Python-parity containers and algorithms in `std/`, built on prelude heap types, with competitive benchmarks and security gates. **WP0** lands spec + harness design only; **WP1+** ships runtime code.

---

## Hard rule — WP1+ blocked until WP-WA

**Do not** implement prelude runtime, `std/collections`, `std/heap`, `std/algorithms`, HPC shapes, or Phase 4 ADTs until **WP-WA** (strict Wave A exit) is complete.

**WP-WA exit** requires these **G-*** rows at **Done** (not Partial) in [provability-gaps.md](../verification/provability-gaps.md), with evidence in the **same PR** that updates the gap register:

| Gate | Gap ID | Master phase |
|------|--------|--------------|
| VC generation / loop proofs | **G-vc** | **2e** |
| Lean in default `lic build` | **G-lean** | **2f** |
| Parallel disjointness (AST-based) | **G-par** | **7b** |
| Math / tier-1 ≤1.2× C++ | **G-math** | **2i**, **7e** |

Also: **8a** workspace import path green; [algorithms-and-libraries-plan §5](algorithms-and-libraries-plan.md) snapshot updated; release note authorizing WP1.

**Current status (2026-05-26):** **Not met** — provability-gaps states no **G-*** row is **Done**. Compiler-studio loop green slices are **progress toward WP-WA**, not substitutes.

**Allowed before WP-WA:** **WP0** only — docs, compile-only module stubs, C++/Rust/Python bench oracles, parity/security test *design* (no runtime parity claims).

---

## WP0 vs WP1+ split

| Package | Scope | When |
|---------|--------|------|
| **WP0-A** | This doc, [stdlib.md](../language/stdlib.md) module tree preview, AL-14…18 | Now |
| **WP0-B** | `std/collections`, `std/heap`, `std/algorithms` compile-only stubs + seal manifest | Now (no runtime) |
| **WP0-C** | `tier1_stdlib` harness, `catalog.toml` `pillar = "stdlib"`, `stdlib_registry.toml` | Now (Li column empty until WP1) |
| **WP0-D/E** | `li-tests/stdlib_parity/`, `li-tests/security/stdlib_abuse/` | Now (compile / expect_fail only) |
| **WP-WA** | Close Wave A checklist above | Parallel with WP0; **blocks WP1** |
| **WP1** | Prelude `list`/`dict`/`set`/`frozenset` runtime + `Hash` + tier-1 benches | After WP-WA |
| **WP2** | `std/collections`, `std/heap`, `std/algorithms` (Phase 2 parity) | After WP1 |
| **WP3** | `tensor`, `sparse`, `arena` / `ringbuffer` (Phase 3) | After WP2 + 2i/7e |
| **WP4** | `BTreeMap`, `Graph`, `RoaringBitmap`, `Channel`, `Arc`/`Rc` (Phase 4) | Benchmark-gated only |

---

## Architecture (do not blur layers)

```text
Prelude (compiler + runtime)     std/ (Li source on prelude)
  list, dict, set, frozenset  →    collections, heap, algorithms
  Hash trait, raises Alloc    →    tensor, sparse, arena (Phase 3)
                                 → btree, graph (Phase 4)
```

- **Prelude** names are sealed ([stdlib seal spec](../superpowers/specs/2026-05-16-li-stdlib-seal.md)); users cannot shadow them.
- **`std/`** modules are ordinary Li source importing prelude types (e.g. `deque` = ring buffer on heap; `heapq` = binary heap on `list`).
- **`packages/*`** numerics (`math`, `linalg`, …) stay separate — see [algorithms-and-libraries-plan §7](algorithms-and-libraries-plan.md).

---

## Python parity map

### Prelude + Phase 1 (language / minimal std)

| Python | Li | Phase | Notes |
|--------|-----|-------|-------|
| `list` | `list[T]` | 1 | Dynamic array; `raises Alloc` |
| `dict` | `dict[K, V]` | 1 | Hash table; `K: Hash` |
| `set`, `frozenset` | `set[T]`, `frozenset[T]` | 1 | Hash set / immutable |
| `str`, `bytes`, buffers | `str`, `bytes`, `memoryview[T]` | 1 | See design spec § Strings |

**Today:** typechecker tests in `li-tests/collections/`; **runtime parity** waits for **WP1**.

### Phase 2 — `std/collections`, `std/heap`, `std/algorithms`

| Python | Li module / path | Notes |
|--------|------------------|-------|
| `collections.deque` | `std/collections/deque.li` | Ring buffer |
| `collections.OrderedDict` | `std/collections/ordered_dict.li` | `dict` + insertion order |
| `collections.Counter` | `std/collections/counter.li` | `dict[T, int]` wrapper |
| `collections.defaultdict` | `std/collections/defaultdict.li` | Default factory |
| `heapq` | `std/heap/heap.li` | `PriorityQueue[T]` on `list` |
| `bisect`, `list.sort` | `std/algorithms/search.li`, `sort.li` | On `list` and `array[N, T]` |
| `itertools` (subset) | `std/algorithms/iter.li` | After iterator protocol |
| `functools` (subset) | `std/functools.li` | After core containers stable |

Deliverable: **AL-16** — port one Python `collections` micro-module with parity tests (WP2).

### Phase 3 — HPC & scientific shapes

| Type | Li | Notes |
|------|-----|-------|
| `tensor` / NumPy-like | `tensor[Shape, T]`, `tensorview` | Compiler **2i/7e** |
| `sparse` CSR/CSC | `std/sparse.li` | Scientific indexing |
| `ringbuffer`, `arena`/`pool` | `std/arena.li` | Fixed FIFO / bump alloc for sim |

Deliverable: **AL-17** — tensor + arena modules + HPC bench rows (WP3).

### Phase 4 — advanced structures

| Type | Li | Notes |
|------|-----|-------|
| `sortedcontainers` / btrees | `BTreeMap`, `BTreeSet` | Range queries vs `dict` |
| `roaringbitmap` | `RoaringBitmap` | Compressed sets |
| Static graph | `Graph[N, E]` | Typed nodes/edges |
| `asyncio.Queue` | `Channel[T]` | With async phase |
| `Arc`/`Rc` | `Arc[T]`, `Rc[T]` | Opt-in shared ownership |

Deliverable: **AL-18** — btree/graph (and peers) only when a benchmark row demands them (WP4).

**Non-goals (design spec):** public linked lists, interior `Cell` in v1, unbounded shared mutability without proof.

---

## Benchmark & security model (summary)

- **Perf:** tier-1 stdlib rows ≤ **1.2× C++** (same policy as [competitive-engines-plan](../benchmarks/competitive-engines-plan.md)).
- **Correctness:** Python `reference.py` scripts — `reference_only` in `kernel_honesty`; not perf oracle.
- **Security:** hash-flood, OOB index (compile fail where possible), `stdlib_symbol_shadow` — see WP0-E / `bench_ecosystem.py` hooks.

Initial catalog ids (stubs until WP1): `stdlib_list_push_pop`, `stdlib_dict_insert_lookup`, `stdlib_set_ops`, `stdlib_sort_int`, `stdlib_binary_search`, `stdlib_heap_push_pop`, `stdlib_deque_rotate`, `stdlib_hash_flood`. Details: **AL-15**, `benchmarks/catalog.toml` `pillar = "stdlib"`.

---

## Related links

- [stdlib.md](../language/stdlib.md) — module tree preview  
- [Data structures roadmap](../superpowers/specs/2026-05-14-li-language-design.md#data-structures-roadmap) — phase gates 1→4  
- [algorithms-and-libraries-plan §5](algorithms-and-libraries-plan.md) — Wave A (ecosystem wording)  
- [Master plan](../superpowers/plans/2026-05-14-li-master-plan.md) — phases 2e/2f/8a  

**Maintainers:** Update **WP-WA** status in this file when moving **G-lean**, **G-vc**, **G-par**, or **G-math** to **Done**. Bump `updated` on quarterly review with AL-7 SOTA ritual.
