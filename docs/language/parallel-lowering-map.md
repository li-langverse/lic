# Parallel lowering map (Li → MIR → LLVM / MLIR)

> **Status:** Normative handbook map — sub-phases **A–E** complete ([#34](https://github.com/li-langverse/lic/issues/34))  
> **Plan:** [2026-06-07-std-execution-openmp-mlir-lowering-map.md](../superpowers/plans/2026-06-07-std-execution-openmp-mlir-lowering-map.md)  
> **Related:** [decorators](decorators.md) · [SIMD and parallel](simd-parallel.md) · [execution surface](../superpowers/specs/2026-05-25-li-execution-surface.md)

This page is the **handbook-facing** lowering map for `std/execution` decorators and `parallel for`. Compiler agents maintain the tables; users read this for mental model only (decorators remain compile-time).

---

## §1 — Current lowering (inventory)

### Source → MIR

| Source surface | Parser / policy | MIR elaboration (`lower.cpp`) | Notes |
|----------------|-----------------|-------------------------------|-------|
| `parallel for i in a..<b` | `disjoint_*` contract required | Outlined `__li_par_<proc>_<n>` + `MirOp::OmpParallelFor` | `parallel_disjoint_proven` from `parallel_for_disjoint_witness()` |
| `@parallel(disjoint=d)` on `def` | inherits to nested `parallel for` | `MirDecorator.parallel` + `disjoint_proven` on proc | `lic verify` → `mir_parallel_disjoint=` counts proc decorators |
| `@vectorized(lanes=4)` on `for` | scope push/pop | `ArraySimdScope` + `Simd*` ops inside scope | lanes stored on `MirInsn::simd_lanes` |
| `@vectorized` on `def` | proc tag | `MirFn.enable_array_simd` / decorator lanes | never emits `OmpParallelFor` |
| `@no_vectorize` on `def` | proc flag | `MirFn.no_vectorize = true` | scalar `ArrayDotF64` / `ArrayBinOpF64` |
| `@cpu` / `@gpu(devices=N)` | placement policy | `MirDecorator.gpu`, `note_offload_decorators()` | telemetry only; no LKIR yet |
| `reduce(+: acc)` on `parallel for` | float accumulator | `par_reduce_kind` on `OmpParallelFor` | `needs_rt_par_reduce` |
| `--cores` / `--threads-per-core` | CLI (`lic build`) | `runtime_team_size` baked into emit | `min(cores × threads_per_core, 64)` |

### MIR → LLVM / runtime (today)

| MIR op | Codegen (`emit.cpp`) | Runtime symbol | Actual backend |
|--------|----------------------|----------------|----------------|
| `OmpParallelFor` (plain) | `CreateCall(li_parallel_for_i64, start, end, fn, team)` | `runtime/li_par_pool.c` | pthread / Windows thread pool — **not** OpenMPIRBuilder |
| `OmpParallelFor` + reduce | `li_parallel_for_reduce_{add,min,max}_f64` | same pool + atomics | same |
| `ArraySimdScope` / `Simd*` | `<4 x double>` `llvm::FixedVectorType` | none | LLVM vector IR in one thread |
| `DParFor` | `li_distributed_for_i64` | `li_dpar_*` | distributed partition (G-par-dist slice) |

**Historical name:** `MirOp::OmpParallelFor` and `li_omp_parallel_for_i64` predate the native pool. Generated user binaries call `li_parallel_for_i64` (team-aware); `li_omp_parallel_for_i64` is a deprecated alias that forwards with `team_size=0`.

**Source files:** `compiler/mir/lower.cpp` (`Stmt::ParallelFor`), `compiler/codegen/emit.cpp` (`OmpParallelFor`, `Simd*`), `runtime/li_par_pool.c`, `runtime/li_parallel.h`.

### Verify telemetry

`lic verify` prints proc-level decorator witnesses:

```
mir_parallel_disjoint=<n>   # @parallel(disjoint=…) on def with proven disjoint policy
mir_vectorized_proc=<n>     # @vectorized on def
mir_gpu_def=<n>             # @gpu placement tags
```

Loop-level `OmpParallelFor::parallel_disjoint_proven` is set in MIR but not yet exported as separate verify key (see §5).

---

## §2 — Target: OpenMPIRBuilder (host CPU)

**Status:** Design complete; codegen behind `LI_CODEGEN_OMP_IR=1` (sub-phase **G**, post-approval).

When enabled, `emit.cpp` replaces the `li_parallel_for_i64` call with LLVM OpenMP IR via [`OpenMPIRBuilder`](https://llvm.org/doxygen/classllvm_1_1OpenMPIRBuilder.html):

| Li / MIR | OpenMPIRBuilder API (LLVM 18+) | OpenMP semantic |
|----------|--------------------------------|-----------------|
| `OmpParallelFor` region entry | `createParallel(InsertPointTy, BodyGenCallbackTy, …)` | `#pragma omp parallel` |
| Static chunk loop `i in [start, end)` | `createLoop(LoopBodyTy, Start, End, Step, IsDynamic=false)` | `#pragma omp for schedule(static)` v1 |
| Team size from CLI | `setNumThreads(runtime_team_size)` on builder config | `num_threads` clause |
| `reduce(+: acc)` | `createReduction(…, ReductionGenTy)` | `#pragma omp reduction` |
| Region exit / join | implicit in `createParallel` finalization | barrier at end of parallel |

**Schedule policy v1:** static chunks matching `li_par_pool` default (`LI_PAR_SCHED_STATIC`). Dynamic / guided deferred until tier-2 scaling proves parity.

**Fallback:** When `LI_CODEGEN_OMP_IR` is unset or libomp unavailable, keep `li_par_pool` path (REQ-PAR-OMP-IR-1).

**Link line:** `-fopenmp` when OpenMPIRBuilder path active; existing `compile.cpp` skip logic when `omp.h` absent still applies for serial fallback.

---

## §3 — SIMD orthogonality

`@vectorized` and `parallel for` are **orthogonal** execution dimensions:

| Dimension | Mechanism | OS threads | LLVM form |
|-----------|-----------|------------|-----------|
| SIMD (`@vectorized`) | `ArraySimdScope` | **0** extra | `<N x T>` vector ops in current thread |
| Parallel (`parallel for`) | `OmpParallelFor` | `runtime_team_size` | outlined callback + pool (today) or OpenMP teams (target) |

`emit.cpp` enforces separation explicitly:

```cpp
// Vectorized codegen: LLVM <4 x double> lanes only — no li_parallel_for_i64.
case MirOp::OmpParallelFor: {
  // `@parallel` / `parallel for` only — never emitted for `@vectorized`
```

**v1 rule:** No OpenMP `simd` / `declare simd` directives until G-math proof story covers auto-vectorization vs explicit lanes. `@no_vectorize` lowers to `llvm.loop.vectorize.disable` metadata on scalar loops.

Nested pattern (standard Li HPC): outer `parallel for` + inner `@vectorized(lanes=4)` — team parallelism outside, lane parallelism inside one worker.

---

## §4 — Target: MLIR `omp` dialect (offload sketch)

**Status:** ADR stub only — no MLIR pipeline in `lic build` v1.

Future multi-level lowering (host + device) uses one decorator story:

```
Li source (@cpu / @gpu)
  → MIR (placement tags + OmpParallelFor / Simd*)
  → MLIR module with `omp` dialect ops
  → LLVM IR (OpenMPIRBuilder for host regions)
  → object / device fat binary
```

| MIR / decorator | MLIR `omp` op (target) | Role |
|---------------|------------------------|------|
| Host `OmpParallelFor` | `omp.parallel` → `omp.wsloop` | worksharing loop on CPU |
| `@gpu` region | `omp.target` + `omp.teams` | offload entry |
| Device buffers | `omp.target_data` / `omp.map` | pointer / array mapping |
| `@async` (future) | `omp.task` / `omp.taskgroup` | deferred |

**ADR:** [2026-06-08-mlir-omp-offload-adr.md](../superpowers/specs/2026-06-08-mlir-omp-offload-adr.md) — spike criteria and G-gpu gates.

**Non-goal:** Kokkos / RAJA policy tables live in [#15](https://github.com/li-langverse/lic/issues/15) and [#109](https://github.com/li-langverse/lic/issues/109); this section only names LLVM/MLIR **targets**.

---

## §5 — G-par IR witnesses

**G-par** requires that compile-time disjoint proofs survive through lowering and remain auditable.

### Today (MIR)

| Witness | Where set | Consumed by |
|---------|-----------|-------------|
| `MirInsn::parallel_disjoint_proven` | `lower.cpp` on each `OmpParallelFor` | policy gate; not yet in LLVM IR |
| `MirDecorator::disjoint_proven` on `@parallel` def | `mir_decorator_disjoint_proven()` | `lic verify` → `mir_parallel_disjoint=` |
| Lean `Li.Discharge.*_spec` | AutoVC discharge | `race_shared_memory/`, proofs gate |

### Target (LLVM metadata — sub-phase G)

When OpenMPIRBuilder path lands, attach LLVM loop metadata on the outlined parallel loop:

```llvm
!li.disjoint = !{!"proven", i1 true}   ; mirrors MirInsn::parallel_disjoint_proven
```

**REQ-PAR-OMP-IR-3:** Proof corpus scripts (`check-mir-parallel-decorator.sh`, `race_shared_memory`) must pass unchanged; optional `llvm-dis` audit step when `mir_omp_ir=1`.

**REQ-PAR-OMP-IR-2:** `lic verify` adds `mir_omp_ir=1` when OpenMPIRBuilder emit is active (distinct from `mir_parallel_disjoint=` which counts proc decorators).

### What OpenMP IR must **not** do

- Infer disjointness from absence of `atomic` — Li rejects loops without `disjoint_*` at compile time.
- Weaken to “descriptive” OpenMP 5.x only — prescriptive map requires proof bit on IR (see [OSTI prescriptive vs descriptive rubric](https://www.osti.gov/servlets/purl/2224192)).

---

## Maintenance

Compiler agents: when changing `lower.cpp` / `emit.cpp` / `li_par_pool.c`, update §1 tables in the same PR. Sub-phase **G** implementers: update §2 and §5 when `LI_CODEGEN_OMP_IR=1` lands.

**CI:** `scripts/check-parallel-lowering-map-gate.sh` · `scripts/check-mir-parallel-decorator.sh`
