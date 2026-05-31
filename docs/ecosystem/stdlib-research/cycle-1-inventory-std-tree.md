# Stdlib ecosystem — cycle 1 · `inventory_std_tree`

**Session:** `cee09172-b61f-4f7b-84de-aae2d0e5972f` · **Goal:** `stdlib_ecosystem` · **Step:** `inventory_std_tree`  
**Agent:** `stdlib_researcher` · **north_star_fit:** ecosystem, scientific_computing, hpc · **PH:** 2i (partial), IO-4/5/7 (gaps)  
**Audited:** `lic/std/**` on disk 2026-05-28 · **Repo:** `lic` (workflow)

---

## Executive summary

- **25 `.li` modules** under `lic/std/` (~1,180 LOC); layout is `std/<domain>/<domain>.li` for single-segment imports (`std.bytes` → `std/bytes/bytes.li`, per CHANGELOG).
- **One heavyweight module:** `std/runtime/seam.li` (655 lines) — canonical `extern proc` seam for `li_rt.c` / `li_rt_net.c` / httpd; product code must import it (`packages/li-net-httpd`, `li-bytes`, async tests).
- **WP0-B compile-only stubs** ship for Phase 2 collections parity: `collections`, `heap`, `algorithms` — tagged constants + identity/no-op stubs; headers state runtime blocked until WP-WA + WP1 ([stdlib-collections-algorithms-plan.md](../stdlib-collections-algorithms-plan.md)).
- **`std/bytes`** is the only non-seam std module with real algorithmic Li code (Reader/Writer over `extern proc` buffer primitives); used by `li-bytes` and `li-tests/bytes/`.
- **Physics namespace** is 13 tag-only facades (`physics_*_std_tag`); composable packages (`packages/li-physics-*`) are the intended implementation locus per master plan.
- **Docs drift:** [stdlib.md](../../language/stdlib.md) L51–53 still claims collections/heap/algorithms are absent; explorer `std_modules_on_disk` (2026-05-26) omits the three WP0-B modules — refresh both after this inventory.
- **Planned tree not on disk:** `tensor`, `sparse`, `arena`, `btree`, `graph` (stdlib plan); `std/http`, `std/net`, `std/tls` (httpd plan) — defer to `package_architect` / WP-WA gates.
- **Benchmarks ingest gaps unchanged:** `std.summary`, `std.plot` still missing ([ecosystem-explorer.json](../../../../benchmarks/data/latest/ecosystem-explorer.json) PH-IO-7 / PH-IO-5).

---

## Deliverable / findings — `lic/std/**` inventory

### Tree summary

| Domain | Path | Lines | Maturity | Import path |
|--------|------|------:|----------|-------------|
| runtime | `std/runtime/seam.li` | 655 | **Trusted extern seam** (httpd/net/async) | `import std.runtime.seam` |
| bytes | `std/bytes/bytes.li` | 117 | **Implemented** Li wrappers + buffer `extern` | `import std.bytes` |
| collections | `std/collections/collections.li` | 82 | **WP0-B stub** (types + no-op ops) | `import std.collections` |
| heap | `std/heap/heap.li` | 53 | **WP0-B stub** | `import std.heap` |
| algorithms | `std/algorithms/algorithms.li` | 48 | **WP0-B stub** | `import std.algorithms` |
| io | `std/io/io.li` | 40 | **Partial** (types; `file_read_all_stub`) | `import std.io` |
| ui | `std/ui/ui.li` | 29 | **Stub** (`Color`, `Rect`, `color_white`) | `import std.ui` |
| csv | `std/csv/csv.li` | 28 | **Stub** (`CsvRow`, parse/read stubs) | `import std.csv` |
| execution | `std/execution/decorators.li` | 23 | **Doc/seal** (reserved decorator names) | `import std.execution.decorators` |
| math | `std/math/numerics.li` | 10 | **Policy tag** (numerics policy comment) | `import std.math` (facade) |
| math | `std/math/math.li` | 6 | **Tag** `math_std_tag` | via `std.math` |
| physics | `std/physics/*.li` (13 files) | 6–9 each | **Tag facades** per subdomain | `import std.physics.<sub>` |
| scene | `std/scene/scene.li` | 6 | **Tag** | `import std.scene` |
| binary | `std/binary/binary.li` | 8 | **Tag** (+ README for `0b` literals) | `import std.binary` |

**Non-Li:** `std/binary/README.md` — documents `binary` vs `bytes` separation.

### WP0-B stubs (evidence)

All three declare compile-only status and WP2 runtime dependency:

```1:6:lic/std/collections/collections.li
# std.collections — Phase 2 Python collections parity (WP0-B compile-only stubs).
#
# Target: collections.deque, OrderedDict, Counter, defaultdict on prelude list/dict.
# Runtime: not implemented — WP2 after WP-WA + WP1 prelude heap types.
#
# Import: `import std.collections`
```

Exported surface (collections): ADT shells `Deque`, `OrderedDict`, `Counter`, `DefaultDict` with `len` only; `deque_append_stub` / `deque_popleft_stub` are no-ops returning `0` (`collections.li:36-48`). Seal smoke sums tags 20+21+22=63 in `li-tests/stdlib_seal/import_std_collections_ok.li:13`.

Algorithms stubs return identity or sentinel (`sort_list_stub` ensures `result == xs` at `algorithms.li:15-20`; `binary_search_stub` returns `-1` at `algorithms.li:43-48`).

### Implemented / seam modules

**Bytes** — wires Reader/Writer to prelude buffer externs:

```13:27:lic/std/bytes/bytes.li
extern proc bytes_len(b: var bytes) raises Alloc, IO -> int
  requires true
  ensures 0 <= result
  decreases 0

extern proc bytes_slice(b: var bytes, off: int, n: int) raises Alloc, IO -> StringView
  requires 0 <= off
  requires 0 <= n
  ensures stringview_len(result) == n
  decreases 0
```

**Runtime seam** — policy at top; ~90+ `extern proc` symbols through line 655 (`tcp_*`, `httpd_*`, `epoll_*`, proxy, TLS hooks). Consumers: `packages/li-http/src/lib.li:2`, `packages/li-net-httpd/src/lib.li:2`, `li-tests/async/tcp_echo_smoke.li:1`.

**Execution decorators** — not callable decorators; documents reserved names and resource knobs (`decorators.li:6-16`).

### Tag-only / placeholder modules

| Module | Tag fn | Tag value | Notes |
|--------|--------|----------:|-------|
| `math.math` | `math_std_tag` | 2 | No linalg surface in-tree |
| `math.numerics` | `math_numerics_std_tag` | 1 | Policy pointer to bench goldens |
| `physics.core` | `physics_core_std_tag` | 1 | Tier-2 harness comment only |
| `physics.*` (12 more) | `physics_*_std_tag` | 1 | Placeholder for composable imports |
| `scene` | `scene_std_tag` | 1 | Studio/sim placeholder |
| `binary` | `binary_tag` | 1 | Bit-packed type smoke |
| `io` | `io_tag` | 4 | `file_open_read` sets `open=0` stub |

### CI / test wiring

| Harness | Path | Covers |
|---------|------|--------|
| Stdlib seal | `li-tests/stdlib_seal/import_std_collections_ok.li` | `std.collections`, `std.heap`, `std.algorithms` |
| Stdlib coverage | `li-tests/stdlib_coverage/build_std_csv.li` | `std.csv`, `std.io` |
| Stdlib coverage | `li-tests/stdlib_coverage/build_std_decorators.li` | `std.execution.decorators` |
| Bytes smoke | `li-tests/bytes/reader_writer_smoke.li` | `std.bytes` |
| Net trusted | `li-tests/net_trusted/seam_policy_ok.li` | `std.runtime.seam` |

`scripts/check-stdlib-coverage.sh` targets **100%** on `std/**` (master plan 8e).

### Planned modules (not in tree)

From [stdlib.md](../../language/stdlib.md) L23–40 and [httpd plan](../../superpowers/plans/2026-05-16-li-httpd-plan.md):

- Phase 2–4 ADT files: `deque.li`, `sort.li`, … (consolidated into single-file stubs today)
- Phase 3: `tensor.li`, `sparse.li`, `arena.li`
- Phase 4: `btree.li`, `graph.li`
- Httpd: `std/http/*`, `std/net`, `std/tls`, `std/crypto`

### Explorer / doc reconciliation

| Source | Issue |
|--------|-------|
| `benchmarks/data/latest/ecosystem-explorer.json` | Lists 22 modules; **missing** `std.collections`, `std.heap`, `std.algorithms` (added WP0-B after 2026-05-26 scan) |
| `docs/language/stdlib.md` | Refreshed 2026-06-01 — 27 modules shipped incl. WP0-B + PH-IO stubs |
| `missing_std_modules` | `std.io`, `std.csv`, `std.summary`, `std.plot` **present** on `cursor/proof-explorer-program` (PH-IO-4/5/7) |

---

## Incremental outputs (cycle 1, step 1 only)

```yaml
packages_to_build: []          # deferred — audit li-std-* next step
packages_to_improve: []        # deferred
std_modules_to_add:            # from explorer + plans (not implementing this run)
  - std.http.*    # httpd M1+ (router, config, upstream)
  - std.tensor    # Phase 3 / 2i linalg
  - std.sparse
connections:
  - lic/std/runtime/seam.li → runtime/li_rt_net.c (httpd, proxy, TLS hooks)
  - lic/std/bytes → packages/li-bytes
  - WP0-B stubs → prelude list/dict (blocked: provability-gaps G-vc, G-lean, G-par, G-math)
```

---

## Recommended issues/PRs

| Repo | Title | Labels |
|------|-------|--------|
| **lic** | docs: refresh `stdlib.md` shipped tree (collections/heap/algorithms WP0-B) | `documentation`, `stdlib` |
| **benchmarks** | ecosystem-explorer: include WP0-B std modules in `std_modules_on_disk` | `ecosystem`, `agent-kit` |
| **lic** | stdlib_coverage: enable `build_std_collections` harness when WP0-B modules stable | `stdlib`, `PH-2` |
| **lic** | ~~tracking: implement `std.summary` / `std.plot`~~ — **done** on `cursor/proof-explorer-program` | `PH-IO-7`, `PH-IO-5` |
| **lic** | merge `cursor/stdlib-adt-wp0` per ph-db battle plan §6 | `stdlib`, `wave-a` |

---

## Deferred

- `audit_package: li-std-core` — next queue step
- `gap_vs_sota: linear algebra stdlibs` — requires li-std-math / prelude linalg cross-read
- `synthesize_step` — aggregate `packages_to_build` / `packages_to_improve` after package audit
- **research-findings** whitepaper — no `publish_subdir` in goal block; cycle digest stays under `lic/docs/ecosystem/stdlib-research/`
- Product code / runtime implementation — hand off to `package_architect` → `code_implementer`

---

## Handoff

**Next focus:** `audit_package` → `li-std-core` (sample)  
**Implementers:** Do not expand WP0-B stubs to runtime until [wave-a-stdlib-unblock-checklist.md](../wave-a-stdlib-unblock-checklist.md) marks WP-WA **Done**.
