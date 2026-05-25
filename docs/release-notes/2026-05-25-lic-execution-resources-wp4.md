# Execution resource controls (WP4)

## Summary

`lic build` gains `--cores=N` and `--threads-per-core=M` to size the native parallel runtime team, documents jobs vs cores vs threads vs SIMD lanes, and adds `li-tests/execution_resources/` smoke tests.

## Agent continuation

1. Read `compiler/common/include/li/resource_options.hpp`, `docs/language/decorators.md` resource table.
2. Run `./scripts/build.sh` and `./li-tests/run_all.sh execution_resources`.
3. Stack PR on `feat/lic-native-parallel` (#208); merge #208 before this branch when landing.
4. Blocked on: none for local dev; CI needs LLVM 22 + built `lic`.

## Changed

- `compiler/common/resource_options.{hpp,cpp}` — `--cores`, `--threads-per-core`, `effective_runtime_team_size()`, `--threads` precedence warning
- `compiler/lic/main.cpp` — usage table; `runtime_team_size` from flags (no `LI_OMP_THREADS` setenv)
- `compiler/codegen/emit.cpp` — `li_parallel_for_i64` team constant; vectorized SIMD comments
- `compiler/mir/include/li/mir.hpp`, `compiler/mir/lower.cpp` — `MirDecorator.vectorized`
- `runtime/li_rt.c` — document build-time team_size preference
- `std/execution/decorators.li`, `docs/language/decorators.md`, `docs/compiler/build-pipeline.md`
- `li-tests/execution_resources/`, `li-tests/run_all.sh` (`script_ok`), `li-tests/manifest.toml`

## Not changed

- OpenMP removal / pthread pool implementation (parent #208)
- `--jobs` compile parallelism semantics
- `@parallel(disjoint=)` proof obligations (G-par still open)

## Breaking

N/A — additive flags; `LI_OMP_THREADS` remains deprecated fallback when build omits team flags.

## Security

N/A — no new trusted surface; `LI_MAX_THREADS` cap unchanged.

## Performance

N/A — bench row not required; team size is user-configurable up to 64 threads.

## Downstream

- `li-cursor-agents` agent prompts may reference `--cores` after merge
- Benchmarks CSV may add cores×tpc columns in a follow-up
