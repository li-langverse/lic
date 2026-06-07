# RAJA execution policies → Li `std/execution` decorator matrix (G-par, PH-7e)

> **Issue:** [#109](https://github.com/li-langverse/lic/issues/109) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first (disjoint iteration + no silent serial fallback), **Easy** syntax (decorator-native surface), **Fast** only after proof (portable policy lowering)  
> **north_star_fit:** HPC performance portability · **PH-7d**, **PH-7e**, **PH-7b** · **G-par**, **G-dec**  
> **Learned from:** [ICS 2025 portability study](https://pssg.cs.umd.edu/assets/papers/2025-06-portability-ics.pdf), [plasma physics Kokkos+RAJA comparison](https://arxiv.org/html/2411.05009v1), [Kokkos execution/memory spaces](https://performanceportability.org/perfport/frameworks/kokkos/), [execution surface spec](../specs/2026-05-25-li-execution-surface.md), [parallel design spec](../specs/2026-06-06-li-parallel-design.md)

## Goal

Close the explorer **missing** rubric for **RAJA policy-based loop abstractions** by producing a **normative policy matrix** that:

1. Maps Li reserved decorators (`@parallel`, `@vectorized`, `@serial`, `@cpu`, `@gpu`) and `parallel for` to **RAJA execution policies**, **Kokkos execution policies**, and **OpenMP schedule/construct** equivalents — with explicit **prescriptive vs descriptive** lowering notes.
2. Anchors the matrix on one **tier-1 kernel** (`reduce_sum`) with side-by-side policy documentation (Li source → expected MIR → OpenMP IR shape → RAJA/Kokkos reference pseudocode).
3. Defines **done criteria** for implementation slices: `@parallel` lowering must emit a **documented policy** (OpenMP team + schedule) and **must not silently fall back to serial** when `LI_PARALLEL=1` and disjoint proofs pass.

**No product codegen** in this slice — documentation, normative rubric, gap-registry updates only.

## Non-goals

- Importing RAJA as a runtime dependency or adding a RAJA driver column to tier-1 benches (optional **benchmarks** parity doc row only — see sub-phase F).
- Replacing [lic#34](https://github.com/li-langverse/lic/issues/34) OpenMP IR / MLIR `omp` lowering plan or [lic#15](https://github.com/li-langverse/lic/issues/15) Kokkos-class codegen.
- Duplicating [lic#110](https://github.com/li-langverse/lic/issues/110) Kokkos View / memory-space ABI rubric — cross-link only.
- Weakening `threshold_ratio_cpp` or catalog thresholds to green incomplete kernels.
- Editing `trusted.lean` (human-approved issues only).
- Adding GitHub Actions `schedule:` cron.

## Distinction from sibling explorer issues

| Issue | Abstraction | This plan (#109) |
|-------|-------------|------------------|
| **lic#34** | LLVM OpenMP IR / MLIR `omp` **lowering path** | Policy **matrix + honesty rubric**; informs lowering, does not implement it |
| **lic#15** | Kokkos-class **codegen** (`parallel_for` → backends) | Static policy mapping table; implementation owned by #15 |
| **lic#110** | Kokkos **Views + memory spaces** | Device policy rows cross-link; memory layout stays #110 |
| **lic#113** | Chapel 2.8 **platform portability** checklist | RAJA = **loop execution policy** axis; orthogonal to Chapel launcher rows |
| **lic#463** | Tier-1 perf honesty (G-math ratios) | Policy doc must not claim perf green without measured ratios |

## Policy matrix (summary)

Full normative detail: [RAJA policy portability rubric spec](../specs/2026-06-07-li-raja-policy-portability-rubric.md).

| Li surface | RAJA policy (reference) | Kokkos policy (reference) | OpenMP construct / schedule | Li v1 lowering target |
|------------|-------------------------|---------------------------|------------------------------|------------------------|
| `@serial` / no decorator on serial `for` | `RAJA::seq_exec` | `Kokkos::Serial` + `RangePolicy` | single-thread loop | Serial MIR loop |
| `@parallel(disjoint=…)` on `parallel for` | `RAJA::omp_parallel_for_exec` or `RAJA::loop_exec` + `RAJA::omp_parallel_exec` | `Kokkos::OpenMP` + `RangePolicy` | `#pragma omp parallel for schedule(static)` | `li_parallel_for_*` + static chunk (PH-7b) |
| `@vectorized(lanes=N)` on inner `for` | `RAJA::simd_exec` (host) | `Kokkos::SIMD` / vector width hint | `#pragma omp simd` (descriptive) | LLVM `<N x T>` vectors; **no** extra OS threads |
| `@parallel` + `@vectorized` stack | Nested policies (outer par, inner simd) | TeamVectorRange / nested policies | `parallel for` + inner `simd` | Prescriptive outer + descriptive inner (lic#34) |
| `@gpu` | `RAJA::cuda_exec` / `RAJA::hip_exec` | `Kokkos::Cuda` / `Kokkos::HIP` | `target teams distribute` (watch) | MIR placement stub → **lic#110** |
| `@cpu` | Host policy tag only | Default host execution space | host team | Default when `@gpu` absent |

**ICS 2025 rubric alignment:** Portability is measured by **policy composability across backends** (CUDA/HIP/Kokkos/RAJA/OpenMP/SYCL). Li v1 claims **host OpenMP static** only; GPU/device rows stay **Partial (doc)** until G-gpu proofs advance.

## Tier-1 anchor kernel: `reduce_sum`

Evidence: tier-1 harness row `reduce_sum` / `reduce_sum_parallel`, `execution_resource_sweep` (`reduce_sum_parallel`).

| Framework | Policy on `reduce_sum` loop | Notes |
|-----------|----------------------------|-------|
| Li | `@parallel(disjoint=disjoint_idx)` + `reduce` clause (Phase 1.1) | Requires proved disjoint; `--cores=N` team size |
| RAJA | `ReduceSum<omp_reduce, double>` + `omp_parallel_for_exec` | Reduction object + execution policy |
| Kokkos | `Kokkos::parallel_reduce` + `RangePolicy(0, N)` on `OpenMP` execution space | Team size from Kokkos init |
| OpenMP | `#pragma omp parallel for reduction(+:sum) schedule(static)` | Prescriptive static default |

Side-by-side doc lives in spec § **RP-04**; optional **benchmarks** reference row documents RAJA invocation without changing Li thresholds.

## Done criteria (implementation — post `plan-approved`)

These gates apply to **codegen PRs** tracked under lic#34 / lic#15 — not this planning slice:

1. **`@parallel` honesty:** When `LI_PARALLEL=1` (or `--cores>1`) and disjoint proof passes, codegen emits OpenMP parallel team (or documented equivalent) — **compile-time error** if parallel requested but OpenMP unavailable, **never silent serial**.
2. **Policy telemetry:** `lic verify` reports `mir_parallel_policy=static_chunk` (or successor enum) matching rubric row.
3. **Regression:** `li-tests/race_shared_memory/` + `decorator_exploits/missing_disjoint_at_parallel.li` remain green; new test `parallel_no_silent_serial.li` fails if serial fallback detected when parallel enabled.
4. **Doc sync:** `docs/language/decorators.md` cites rubric row for each shipped decorator lowering.

## Dependencies

| Track | Issue / doc | Role |
|-------|-------------|------|
| Decorator AST | PH-7d, `std/execution/decorators.li` | Reserved names baseline |
| Parallel runtime | PH-7b, `li_rt.c` | `li_parallel_for_*`, static chunk |
| OpenMP lowering | **lic#34** | MLIR/OpenMPIRBuilder path |
| Kokkos codegen | **lic#15** | Backend policy implementation |
| Memory spaces | **lic#110** | `@gpu` device policy rows |
| Tier-1 bench | PH-7e, **lic#463** | Perf claims separate from policy doc |
| Explorer digest | `benchmarks/docs/ecosystem/explorer-digests/2026-05-20-explorer.md` | Discovery evidence |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | Normative rubric spec: Li → RAJA → Kokkos → OpenMP matrix (RP-01…RP-06) | Merged spec; `check-doc-provability-claims.sh` |
| **B** | Tier-1 `reduce_sum` side-by-side policy doc (RP-04) | Kernel id + four-framework pseudocode in spec |
| **C** | Prescriptive vs descriptive lowering notes (OpenMP schedule ownership) | Cross-link lic#34; no codegen |
| **D** | `@parallel` no-silent-serial done criteria + REQ rows | Plan § Done criteria + spec verification |
| **E** | Swarm gap `gap-hpc-raja-execution-policies` evidence bump + `registry.toml` RAJA watch row | Registry YAML + competitive `last_reviewed` |
| **F** | Optional **benchmarks** doc-only row: RAJA reference driver for `reduce_sum` (parity documentation) | benchmarks PR after plan merge; no threshold change |

## Tests / benches

| Gate | Command / artifact | When |
|------|-------------------|------|
| Doc honesty | `./scripts/check-doc-provability-claims.sh` | Every PR |
| HPC competitive | `./scripts/check-hpc-competitive.sh` | After `registry.toml` bump |
| Race rejects | `li-tests/race_shared_memory/` | Before any parallel codegen PR |
| Tier-1 smoke (unchanged) | `python3 benchmarks/harness/bench.py --tier 1 --only reduce_sum` | After implementation slices |
| Execution sweep | `execution_resource_sweep.py --only reduce_sum_parallel` | After policy telemetry lands |

**REQ mapping:**

| REQ | Acceptance |
|-----|------------|
| REQ-raja-policy-matrix | Spec table covers all six Li decorator/keyword rows in issue #109 checklist |
| REQ-reduce-sum-anchor | RP-04 documents `reduce_sum` for Li, RAJA, Kokkos, OpenMP |
| REQ-par-no-silent-serial | Done criteria §1 documented; implementation deferred to lic#34/#15 |
| REQ-7e-policy-doc | PH-7e cross-link without claiming shipped GPU policies |

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-par** | Partial → Partial (honest) | Matrix documents policies; disjoint Lean proofs unchanged |
| **G-dec** | Partial → Partial (honest) | Decorator elaboration rows; no new closed slice |
| **G-gpu** | Partial (doc cross-link) | CUDA/HIP policy rows defer to lic#110 |

## Rollout

1. Merge **this plan PR** (draft → ready) + human **`plan-approved`** on #109.
2. **lic#34** implementer consumes OpenMP lowering rows (C).
3. **lic#15** implementer consumes Kokkos policy rows for codegen.
4. Optional **benchmarks** doc PR (F) — RAJA reference invocation for `reduce_sum` only.
5. Implementation handoff → `code_implementer` only after `plan-approved` + explicit PH-7b/7e scope.

## Human-only

- [ ] Label **`plan-approved`** on #109 before parallel codegen agents run.
- [ ] Decide whether RAJA stays **`watch`** or gains **`bench_tier1`** reference driver (recommend: stay watch / doc-only row until G-par Lean proofs advance).
- [ ] Approve prescriptive static schedule as Li v1 default vs configurable policy enum.
