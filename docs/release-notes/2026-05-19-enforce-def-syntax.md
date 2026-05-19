# Enforce `def` for Li procedures

## Summary

User-facing Li functions must be declared with `def`; bare `proc` is rejected except after `extern` for C ABI.

## Agent continuation

1. Read `docs/language/control-flow-and-functions.md` and `docs/language/overview.md` for the canonical declaration shape.
2. Run `./li-tests/run_all.sh encapsulation` and `lic build` on any touched `.li` after edits.
3. Next: migrate external snippets or course material that still use `proc`; keep `extern proc` and callable `proc(...)` types in annotations per design spec.
4. Blocked: none — parser error is `use 'def' for Li procedures; 'proc' is only allowed after 'extern'`.

## Changed

- `compiler/parser/parser.cpp` — reject top-level / `async` / decorated `proc`; require `def`.
- `scripts/migrate-proc-to-def.py` — one-shot source migrator (181 `.li` files).
- `li-tests/encapsulation/proc_syntax_rejected.li` + manifest row (`compile_fail`).
- Handbook and examples under `docs/`, `examples/`, `packages/`, `benchmarks/`, `std/`, `li-tests/`.

## Not changed

- `extern proc` for FFI (still required after `extern`).
- Callable type spelling `proc(a: T) -> U` in type positions (design spec).
- Future `gpu proc` keyword (spec only; not parsed as user `def` today).
- `decorator def` for execution-decorator macros.

## Breaking

| Before | After |
|--------|--------|
| `proc foo() -> int` | **Compile error** — use `def foo() -> int` |
| `async proc worker()` | `async def worker()` |
| `extern def foo()` | **Compile error** — use `extern proc foo()` |

## Security

N/A — syntax-only; no trusted surface change.

## Performance

N/A — no codegen change.

## Downstream

- Regenerate or hand-fix any out-of-tree `.li` that still uses `proc` for definitions.
- Benchmarks ingest (`benchmarks` repo) picks up Li sources from `lic` on sync; no separate action if tracking `lic` main.
