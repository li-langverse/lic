# Enforce `extern def` for trusted FFI (`def`-only Li)

## Summary

All Li declarations use **`def`**. Trusted runtime FFI uses **`extern def`** in `std/runtime/seam.li` only. Bare **`proc`** and **`extern proc`** are compile errors.

## Changed

- `compiler/parser/parser.cpp` — accept `extern def`; reject `proc` and `extern proc`.
- `std/runtime/seam.li` — `extern proc` → `extern def`; add OCI `container_*` seam block.
- All in-tree `.li` sources, li-tests, packages, examples.
- `scripts/check-li-def-syntax.sh` — policy gate rejects `extern proc`.
- `scripts/migrate-proc-to-def.py` — migrates both bare `proc` and `extern proc`.
- `li-tests/encapsulation/extern_proc_syntax_rejected.li` (`compile_fail`).

## Breaking

| Before | After |
|--------|--------|
| `extern proc foo()` | **Compile error** — use `extern def foo()` |
| `proc foo()` | **Compile error** — use `def foo()` (since 2026-05-19) |

## Agent continuation

1. Extend `runtime/li_rt_container.c` when wiring librebase licontainer.
2. Run `./li-tests/run_all.sh encapsulation` after parser edits.
3. GitLab is origin; GitHub is read-only mirror.
