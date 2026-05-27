# Cycle 1 — `inventory_std_tree` (`lic/std/**`)

- **Session:** `00de0db9-7e21-4eb3-9b85-f2d5a80294e6`
- **Goal:** `stdlib_ecosystem`
- **Step:** `inventory_std_tree` → `lic/std/**`
- **Completed:** 2026-05-27
- **north_star_fit:** ecosystem, scientific_computing, hpc — PH-2i (linalg prelude), PH-IO-4/5/7 (ingest/plot), WP0-B/D (collections parity), master plan Phase 2 collections plan

## Tree snapshot

**26 files** under `lic/std/` (25× `.li`, 1× `binary/README.md`). **~1,180** total `.li` lines; **~655** lines are `runtime/seam.li` (trusted net/httpd extern surface).

```
std/
├── algorithms/algorithms.li    (48)   WP0-B compile stubs
├── binary/binary.li + README.md (8)
├── bytes/bytes.li              (117)  real externs → li_rt
├── collections/collections.li  (82)   WP0-B compile stubs
├── csv/csv.li                  (28)
├── execution/decorators.li     (23)
├── heap/heap.li                (53)   WP0-B compile stubs
├── io/io.li                    (40)
├── math/math.li                (6)    tag only
├── math/numerics.li            (10)   policy header
├── physics/*.li                (13×6–9) tag stubs per domain
├── runtime/seam.li             (655)  trusted I/O + httpd
├── scene/scene.li              (6)
└── ui/ui.li                    (29)
```

## Module resolution (`import std.*`)

Compiler maps `std.<segments>` → path via `std_module_to_path` in `compiler/types/import_resolve.cpp:51-85`:

- **Single segment** (e.g. `std.bytes`) → `std/bytes/bytes.li`
- **Multi segment** (e.g. `std.physics.core`) → `std/physics/core.li`

## Inventory by module

| Import path | File | Lines | Surface class | Evidence |
|-------------|------|------:|---------------|----------|
| `std.algorithms` | `algorithms/algorithms.li` | 48 | WP0-B stubs (`*_stub`) | `sort_list_stub`, `bisect_*`, `binary_search_stub` at ```15:43:lic/std/algorithms/algorithms.li``` |
| `std.binary` | `binary/binary.li` | 8 | Tag only | `binary_tag()` ```3:8:lic/std/binary/binary.li``` |
| `std.bytes` | `bytes/bytes.li` | 117 | **Implemented** externs + Reader/Writer | `bytes_len`, `reader_read_chunk`, etc. ```13:112:lic/std/bytes/bytes.li``` |
| `std.collections` | `collections/collections.li` | 82 | WP0-B object shells + stubs | `Deque`, `Counter`, `deque_popleft_stub` ```8:48:lic/std/collections/collections.li``` |
| `std.csv` | `csv/csv.li` | 28 | Stub parse/read | `csv_parse_row_stub`, `csv_read_table_stub` ```15:23:lic/std/csv/csv.li``` |
| `std.execution.decorators` | `execution/decorators.li` | 23 | Doc + seal hook | `__execution_decorators_doc` ```18:23:lic/std/execution/decorators.li``` |
| `std.heap` | `heap/heap.li` | 53 | WP0-B `PriorityQueue` stubs | `heappush_stub`, `heapify_stub` ```8:48:lic/std/heap/heap.li``` |
| `std.io` | `io/io.li` | 40 | Partial facade | `file_open_read` shell; `file_read_all_stub` ```15:34:lic/std/io/io.li``` |
| `std.math` | `math/math.li` | 6 | Tag only | `math_std_tag()` ```1:6:lic/std/math/math.li``` |
| `std.math.numerics` | `math/numerics.li` | 10 | Policy doc + tag | Goldens note ```1:10:lic/std/math/numerics.li``` |
| `std.physics.*` | `physics/*.li` | 6–9 each | Domain tag stubs (12 modules) | e.g. `physics_core_std_tag` ```4:9:lic/std/physics/core.li``` |
| `std.runtime.seam` | `runtime/seam.li` | 655 | **Trusted** net/httpd/runtime | `tcp_listen`, `httpd_epoll_serve_i`, … ```49:652:lic/std/runtime/seam.li``` |
| `std.scene` | `scene/scene.li` | 6 | Tag only | `scene_std_tag()` |
| `std.ui` | `std/ui/ui.li` | 29 | Minimal types | `Color`, `Rect`, `color_white()` ```1:20:lic/std/ui/ui.li``` |

**Prelude (not under `std/` but std-adjacent):** `sum`, `dot`, `norm`, `axpy`, array ops — sealed in `compiler/types/prelude.cpp:36-37` (math surface is prelude, not `std.math`).

## Stdlib seal registry

`is_std_module_symbol()` in `prelude.cpp:46-64` seals **bytes**, **collections**, **heap**, **algorithms** top-level names. WP0-B modules are importable (`li-tests/stdlib_seal/import_std_collections_ok.li`) but user code cannot shadow exported symbols.

**Gap:** `math_numerics_std_tag`, physics tags, `io_tag`, `csv_tag`, etc. are **not** in the seal list — only the WP0-B + bytes set is protected today.

## Test / CI linkage

| Suite | Manifest | Targets |
|-------|----------|---------|
| `stdlib_seal` | `li-tests/manifest.toml:1144-1177` | Shadow + `import_std_collections_ok` |
| `stdlib_parity` | `manifest.toml:1424-1442` | collections / heap / bisect compile_ok |
| `stdlib_coverage` | `manifest.toml:1137-1142` | **Only** `build_std_decorators.li` enabled; csv/io coverage commented |
| `bytes` | `li-tests/bytes/*` | `import std.bytes` smoke |

Benchmarks registry (WP0-D): `stdlib_binary_search`, `stdlib_heap_push_pop`, `stdlib_deque_rotate`, etc. — align with stub modules above.

## `lic/packages/` facades (in-monorepo, not `li-std-*`)

Packages that **re-export or wrap** `std/` today:

| Package | Imports | Role |
|---------|---------|------|
| `li-bytes` | `std.bytes` | Published bytes facade |
| `li-net`, `li-http`, `li-net-httpd` | `std.runtime.seam` | Net/httpd product code |
| `li-math` | Own `lib.li` (Vec2/3, rt externs) | **Richer** than `std/math/math.li` tag |
| `li-physics-*` (12) | Typically mirror `std.physics.<domain>` pattern | Org-split physics verticals |

Sibling org repos **`li-std-core`**, **`li-std-math`** exist as publish mirrors; audit deferred to step `audit_package`.

## Docs / briefing drift (action for `docs_maintainer`)

1. `docs/language/stdlib.md:53` still claims *“no std/collections, std/heap, or std/algorithms sources yet”* — **false** since WP0-B land (see tree above).
2. `agent-briefing.json` `ecosystem_explorer.std_modules_on_disk` (2026-05-26) omits `std.collections`, `std.heap`, `std.algorithms` — refresh explorer script on next briefing run.

## Referenced but missing on disk

From ecosystem explorer + ingest/dashboard scripts (not under `lic/std/`):

| Planned import | PH | Callers |
|----------------|-----|---------|
| `std.summary` | PH-IO-7 | `scripts/ingest/build_summary.li` |
| `std.plot` | PH-IO-5 | `scripts/dashboard/render_dashboard.li` |

From `docs/language/stdlib.md` planned tree (not implemented): `tensor`, `sparse`, `arena`, `btree`, `graph` under `std/`.

## Cycle 1 partial outputs (incremental)

```yaml
packages_to_build: []  # deferred — audit li-std-* next step
packages_to_improve:
  - li-bytes          # align with std.bytes seal surface
  - li-math           # reconcile vs prelude PH-2i vs std/math tag-only
  - li-net-httpd      # depends on std.runtime.seam visibility
std_modules_to_add:
  - std.summary       # PH-IO-7
  - std.plot          # PH-IO-5
  # later: tensor, sparse, arena (master plan / stdlib.md preview)
connections:
  - lic/std/bytes → runtime/li_rt_net.c (manifest note li-tests/manifest.toml:621)
  - lic/std/runtime/seam → packages/li-net*, li-http, li-net-httpd
  - WP0-B std/{collections,heap,algorithms} → benchmarks stdlib_* rows
  - prelude sum/dot/norm/axpy → PH-2i (not std.math files)
```

## Handoff

- **package_architect:** placement for `std.summary` / `std.plot`; whether `li-std-core` subsumes collections runtime vs in-tree `std/`.
- **code_implementer:** WP1 runtime for collections/heap/algorithms; refresh `stdlib.md`; extend `stdlib_coverage` to new modules; sync `prelude.cpp` seal if physics/io tags become public API.
