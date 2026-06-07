# stdlib_abuse — ADT security / abuse matrix (WP0-E)

Pre-runtime abuse cases for prelude and future `std/collections` / `std/heap` surfaces.
Wired for future `security_stdlib_*` rows in `benchmarks/harness/bench_ecosystem.py`.

| File | Intent | Expected (pre-runtime) |
|------|--------|-------------------------|
| `hash_flood_design.li` | Adversarial `dict` key patterns (hash-flood class) | **compile_ok** — design doc; runtime must bound probe chains (WP1) |
| `array_index_oob.li` | Constant index past `array` bound | **compile_fail** (`out of range`) |
| `array_negative_index.li` | Negative constant index | **compile_fail** (`out of range`) |
| `array_dyn_index.li` | Dynamic index without proof | **compile_fail** (`array index must be constant` or `out of range`) |

## Post-WP1 expectations (document only)

| Class | WP1+ behavior |
|-------|----------------|
| Hash flood | `dict` insert/lookup stays within documented max chain; `stdlib_hash_flood` bench fails closed on regression |
| OOB index | Rejected at compile time for fixed arrays; dynamic indices require refinement |
| Iterator misuse | Added when `std/collections` deque iterators land (WP2) |

Run: `./li-tests/run_all.sh stdlib_abuse` (manifest) or full `./li-tests/run_all.sh`.
