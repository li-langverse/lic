# std/execution decorators → LLVM OpenMP IR / MLIR `omp` lowering map

> **Issue:** [#34](https://github.com/li-langverse/lic/issues/34) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (G-par disjoint witnesses survive lowering), **Fast** (OpenMP-native team sizing after proof), **Easy** (decorator-first surface unchanged)  
> **North star fit:** HPC / scientific computing — portable parallel semantics with measured tier-2 scaling; **PH-7e**, **PH-7d**, **G-par**  
> **Learned from:** [phase 07 native HPC](2026-05-14-phase-07-native-hpc.md), [execution surface spec](../specs/2026-05-25-li-execution-surface.md), [execution decorators spec](../specs/2026-05-16-li-execution-decorators.md), [provability-gaps G-par](../../verification/provability-gaps.md#g-par), [explorer digest 2026-05-17](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-17-explorer.md)

## Goal

Produce a **binding upstream lowering map** from Li `std/execution` decorators (`@parallel`, `@vectorized`, `@cpu`, `@gpu`, …) through MIR to:

1. **LLVM OpenMP IR** via [`OpenMPIRBuilder`](https://llvm.org/doxygen/classllvm_1_1OpenMPIRBuilder.html) for host CPU teams (schedule, reduction hooks, affinity metadata).
2. **MLIR `omp` dialect** ([docs](https://mlir.llvm.org/docs/Dialects/OpenMPDialect/)) for future offload / multi-level parallelism (GPU target regions, device teams) without forking a second decorator story.

This plan **documents and gates** the map first; codegen migration to OpenMPIRBuilder is a **follow-on implementation track** after human **`plan-approved`** on #34. It complements — does not duplicate — [#15](https://github.com/li-langverse/lic/issues/15) (Kokkos-class portable execution model); #34 is the **LLVM/MLIR upstream anchor** for G-par.

## Non-goals

- Replacing proof-first disjoint policy with runtime OpenMP “hope” (`G-par` witnesses must remain compile-time).
- Weakening `threshold_ratio_cpp` or catalog rows in **benchmarks** to green incomplete kernels.
- Implementing Kokkos/RAJA adapters (separate explorer issues #109, #129).
- Editing `trusted.lean` or adding `unsafe` / `Any` escape hatches.
- Landing MLIR as a second user-facing backend in this slice (map + spike only).

## Current state (as of plan draft)

| Li surface | MIR | LLVM / runtime today | OpenMP IR today |
|------------|-----|----------------------|-----------------|
| `parallel for` / `@parallel(disjoint=…)` | `MirOp::OmpParallelFor` + outlined `__li_par_*` | `CreateCall(li_parallel_for_i64)` → **`li_par_pool`** (pthread / WinTP), **not** `#pragma omp` in generated IR | **None** — name is historical; `-fopenmp` links libomp for some bench competitors only |
| `@vectorized(lanes=4)` on `for` | `ArraySimdScope`, `Simd*` ops | `llvm::FixedVectorType <4 x double>` | N/A (SIMD ≠ OpenMP teams) |
| `@cpu` / `@gpu` | proc decorator tags | placement telemetry only (`check-mir-gpu-decorator.sh`) | N/A until offload track |
| Resource knobs (`--cores`, `LI_OMP_THREADS`) | `runtime_team_size` constant | passed to `li_parallel_for_i64(..., team_size)` | env alias only; not OpenMP `num_threads` IR |

**Gap:** Phase **7b** exit gate claims OpenMP link, but host parallel lowering bypasses **OpenMPIRBuilder** and **MLIR `omp`**. G-par closed slice covers AST/policy; **IR-level map** for portable semantics (G-par) is missing.

## Dependencies

| Track | ID | Role |
|-------|-----|------|
| Decorators | **PH-7d** (7d-b…e) | Elaboration `@parallel` → `ParallelFor`; `@vectorized` scope |
| Math lowering | **PH-7e** | Loop matmul / reductions inherit parallel + SIMD map |
| Parallel safety | **G-par** | `parallel_disjoint_proven` bit on `OmpParallelFor`; Lean proofs open |
| Decorator static rules | **G-dec** | Reserved names, exploit suite |
| Portable model | **G-par** + #15 | Kokkos-class policy; #34 supplies LLVM/MLIR target |
| Benches | **benchmarks** tier-2 | OpenMP scaling columns need honest IR path |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A — Inventory** | `docs/language/parallel-lowering-map.md` §1: decorator → MIR table (source: `lower.cpp`, `emit.cpp`, `li_rt.c`) | Reviewed against `li-tests/decorators/` + `check-mir-parallel-decorator.sh` |
| **B — Host OpenMP IR target** | Same doc §2: per-decorator mapping to **OpenMPIRBuilder** ops (`createParallel`, `createLoop`, `createBarrier`, reductions) | Table covers `@parallel`, `parallel for`, team size knobs; notes schedule `static` v1 |
| **C — SIMD orthogonality** | Doc §3: `@vectorized` → LLVM vectorizer / fixed-width SIMD **never** shares `OmpParallelFor` path (already enforced in `emit.cpp`) | Cross-ref execution surface spec; no OpenMP `simd` directive until proof story exists |
| **D — MLIR `omp` sketch** | Doc §4: MIR → `omp.parallel` / `omp.wsloop` / future `omp.target` for `@gpu` offload spike | ADR stub in `docs/superpowers/specs/`; no user-visible syntax change |
| **E — G-par IR witnesses** | Doc §5: which OpenMP IR metadata carries `parallel_disjoint_proven` (e.g. `!li.disjoint` LLVM metadata on loop) | `lic verify` prints witness; `check-mir-parallel-decorator.sh` extended (plan-only in this PR) |
| **F — Master plan cross-link** | Link from [phase 07 §7b](2026-05-14-phase-07-native-hpc.md) + PH tracker row | This plan URL on #34 and in master plan related-plans table |
| **G — Codegen migration gate** | Issue checklist for **post-approval** PR: optional `LI_CODEGEN_OMP_IR=1` flag switching `OmpParallelFor` emit from `li_par_pool` → OpenMPIRBuilder | `race_shared_memory` + tier-2 scaling smoke unchanged or improved |

## Decorator → MIR → target IR (summary)

| `std/execution` / keyword | MIR | OpenMPIRBuilder (target) | MLIR `omp` (target) |
|---------------------------|-----|--------------------------|---------------------|
| `@parallel(disjoint=d)` / `parallel for` | `OmpParallelFor`, `parallel_disjoint_proven` | `OpenMPIRBuilder::createParallel` + `createLoop` static schedule; `num_threads` from `--cores` × `--threads-per-core` | `omp.parallel` → `omp.wsloop` |
| `@vectorized(lanes=4)` | `ArraySimdScope`, `SimdBinOpF64`, … | *none* (LLVM vector IR) | *none* v1 |
| `@no_vectorize` | `fn.no_vectorize` | `llvm.loop.vectorize.disable` metadata | N/A |
| `@cpu` | host placement tag | default device; no `omp.target` | host region only |
| `@gpu` / `@gpu(devices=N)` | MIR telemetry | deferred | `omp.target` + `omp.target_data` (spike) |
| `@async` | (future) | tasking deferred | `omp.task` deferred |

**REQ-map (implementation track G):**

- **REQ-PAR-OMP-IR-1:** Host `@parallel` lowers through OpenMPIRBuilder when flag enabled; fallback `li_par_pool` until parity proven.
- **REQ-PAR-OMP-IR-2:** `lic verify` exports `mir_omp_ir=1` when OpenMPIRBuilder path used.
- **REQ-PAR-OMP-IR-3:** Disjoint witness preserved as LLVM loop metadata consumed by proof corpus scripts.

## Tests / benches

| Suite | Purpose |
|-------|---------|
| `li-tests/race_shared_memory/` | G-par compile_fail + `good_disjoint_parallel.li` |
| `li-tests/decorators/parallel_with_disjoint.li` | MIR `mir_parallel_disjoint=1` |
| `scripts/check-mir-parallel-decorator.sh` | parallel decorator smoke (update symbol expectation post-migration) |
| `li-tests/decorator_exploits/` | G-dec negative cases |
| **benchmarks** tier-2 | OpenMP scaling columns (`threads` CSV) — ingest after codegen migration |
| `bench.py --tier 1` | matmul / MD rows unaffected by doc-only PR |

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-par** | Partial → Partial+ | Add IR map + metadata design; Lean disjoint proofs still open |
| **G-dec** | Partial | Unchanged; decorators remain compile-time only |
| **G-math** | Partial | 7e loops inherit mapped parallel/SIMD paths |
| **G-gpu** | Partial | MLIR §4 defines future `@gpu` lowering only |

## Rollout

1. **This PR (plan only):** land `2026-06-07-std-execution-openmp-mlir-lowering-map.md` + `docs/language/parallel-lowering-map.md` skeleton + phase-07 cross-link.
2. Human adds **`plan-approved`** on #34; remove **`plan-needed`**.
3. Implementation agent: sub-phases **A–E** doc completion PR, then **G** codegen behind flag.
4. Update `provability-gaps.md` when OpenMPIRBuilder path reaches closed slice.
5. Coordinate #15 for Kokkos-class policy tables referencing this map.

## Human-only

- [ ] Label **`plan-approved`** on #34 before codegen migration PRs.
- [ ] Review MLIR offload ADR before enabling `@gpu` OpenMP target lowering.
- [ ] Approve deprecation timeline for `li_omp_parallel_for_i64` alias vs `li_parallel_for_i64`.
- [ ] Merge plan PR (draft → ready) after doc review.

## Related issues

- [#15](https://github.com/li-langverse/lic/issues/15) — Kokkos-class portable parallel lowering (policy + std surface)
- [#27](https://github.com/li-langverse/lic/issues/27) — PH-7e Done criteria
- [#109](https://github.com/li-langverse/lic/issues/109) — RAJA rubric (orthogonal)
- [#129](https://github.com/li-langverse/lic/issues/129) — OpenMP affinity / MPI×threads rubric
