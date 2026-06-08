# HPX async futures tier-2 physics — implementation slice (lic#112)

**Date:** 2026-06-08  
**Issue:** [lic#112](https://github.com/li-langverse/lic/issues/112)  
**Plan:** [2026-06-07 HPX futures tier-2 plan](../superpowers/plans/2026-06-07-li-hpx-futures-tier2-physics-scheduling.md)

## Summary

First implementation slice after `plan-approved`: `@executor(pool=…)` decorator validation + MIR telemetry, `then` continuation borrow gate, and `std/execution/futures.li` doc stub.

## Changes

| Area | Detail |
|------|--------|
| `@executor` | Closed pool table (`physics`, `io`, `default`); `mir_executor_def` / `mir_executor_physics_def` telemetry |
| `then` | Rejects concurrent continuation callees sharing the same `var` binding (2× `compile_fail`) |
| Docs | Plan/spec merged; `provability-gaps.md` **G-async** row updated |
| std | `std/execution/futures.li` — `Future[T]` surface documentation |

## Gates

```bash
cmake -S . -B build -G Ninja -DLLVM_DIR=/usr/lib/llvm-22/lib/cmake/llvm
cmake --build build -j --target lic
./build/compiler/lic/lic verify li-tests/decorators/executor_physics_ok.li
LI_REPO_ROOT=$PWD LI_LIC=./build/compiler/lic/lic ./li-tests/run_all.sh decorators
LI_REPO_ROOT=$PWD LI_LIC=./build/compiler/lic/lic ./li-tests/run_all.sh effects
./scripts/check-doc-provability-claims.sh
```

## Deferred

- `Future[T]` / `async expr` parser + MIR codegen
- benchmarks `hpx_*` reference driver column
- `trusted.lean` changes
- Distributed HPX locales (**G-par-dist**)
