# Phase 7: Native HPC (SIMD + parallel for)

> **Depends on:** Phases 3–5b (MIR/LLVM, benchmarks harness)  
> **Blocks:** Pure-Li Tier 2 perf tables, OpenMP scaling columns

**Goal:** Built-in `simd[T, N]` and proved `parallel for` without user-level parallel/math libraries. Toolchain links LLVM + libomp only.

## 7a — SIMD vertical slice

| Task | Exit |
|------|------|
| `simd[T,N]` in typechecker (`TyKind::Simd`) | `li-tests/simd/` pass |
| MIR: splat, binop, horizontal sum | LLVM `<N x double>` |
| `simd_dot` benchmark pure Li | `li_pure=True` in harness |

## 7b — `parallel for` + OpenMP

| Task | Exit |
|------|------|
| `Stmt::ParallelFor` AST + parser | Parses exploit fixtures |
| Outlined par body + `li_omp_parallel_for` in `runtime/li_rt.c` | `-fopenmp` link |
| Replace `policy.cpp` string hacks with structured overlap check (keep fixtures) | `race_shared_memory` green |
| `lic build --threads=N` / `LI_OMP_THREADS` | CSV threads column |

## 7c — Benchmark truthfulness

| Task | Exit |
|------|------|
| `md_lennard_jones` pure Li driver | No `LI_EXTRA_C` for li label |
| Tier 2 verify checksum | `bench.py` smoke |

## CI (parallel track)

- Windows: build + `run_all.sh --ci` + security
- Fuzz: daily `fuzz.yml`, `merge_fuzz_corpus.sh`, corpus artifact + optional bot PR
- `scripts/ci.sh`: log `race_shared_memory` explicitly
- TSan nightly (post-7b): optional `memory.yml` job

## Exit gate (phase complete)

- [ ] `./li-tests/run_all.sh simd race_shared_memory`
- [ ] `bench.py --tier 1` simd_dot li_pure; `--tier 2` md_lennard_jones li_pure smoke
- [ ] Daily fuzz workflow green; corpus merge script documented
