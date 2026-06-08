# PH-7e / G-par: decorators → portable parallel lowering (Kokkos-class)

> **Issue:** [#15](https://github.com/li-langverse/lic/issues/15) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (G-par disjoint witnesses on decorator paths), **Easy** (decorator-first `@parallel` / `@cpu` / `@gpu`), **Fast** (OpenMP-native teams **after** proof — via [#34](https://github.com/li-langverse/lic/issues/34) lowering map)  
> **North star fit:** HPC / scientific computing — Kokkos-class **portable execution + memory-space policy** without importing Kokkos; **PH-7d**, **PH-7e**, **G-par**, **G-dec**, **G-hetero**  
> **Learned from:** [phase 07 native HPC](2026-05-14-phase-07-native-hpc.md), [OpenMP IR lowering map (#34)](2026-06-07-std-execution-openmp-mlir-lowering-map.md), [execution decorators spec](../specs/2026-05-16-li-execution-decorators.md), [provability-gaps G-par](../../verification/provability-gaps.md#g-par), [explorer digest 2026-05-17](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-17-explorer.md)

## Goal

Close the **Kokkos=missing** HPC rubric gap by defining and gating a **proof-first portable parallel lowering** path:

1. **`std/execution` decorators** (`@parallel`, `@cpu`, `@gpu`, `@vectorized`) **elaborate** to the same proved MIR cores as keywords (`parallel for`, SIMD scope) — completing **7d-b/c** partial work.
2. **`parallel_for` runtime surface** — a portable host API (`li_parallel_for_*`) with explicit **execution-space** and **memory-space** policy hooks (Kokkos-class semantics, Li-native types).
3. **Tier-2 catalog honesty** — migration plan for **9/25** `shared_c_kernel` rows toward **`pure_li`** variants once lowering + copy semantics are specified (coordination with **benchmarks** ingest only).

This plan is **policy + elaboration + catalog migration gates**. Host **OpenMPIRBuilder** codegen migration is owned by [#34](https://github.com/li-langverse/lic/issues/34); **OpenMPTarget offload rubric** by [#116](https://github.com/li-langverse/lic/issues/116); **Kokkos View ABI** by [#110](https://github.com/li-langverse/lic/issues/110). **#15** is the **Kokkos-class portable model** that ties them together.

## Non-goals

- Shipping a Kokkos C++ adapter or vendoring Kokkos in **lic** (benchmark competitors may still use Kokkos; Li surface stays decorator-native).
- **Distributed multi-GPU** views / MPI-aware partitions in this slice (**G-par-dist** remains separate; see `packages/li-parallel/src/parallel/distributed.li`).
- Weakening `threshold_ratio_cpp` or relabeling `shared_c_kernel` rows as `pure_li` without codegen proof (**benchmarks** honesty violation).
- Runtime decorator dispatch, Python-style registries, or `unsafe` / `Any` escape hatches.
- Editing `trusted.lean` (human-approved issues only).
- Claiming **G-par Done** from documentation without `race_shared_memory` + decorator elaboration smokes green.

## Current state (preflight 2026-06-08)

| Area | Status | Blocker |
|------|--------|---------|
| `@parallel` / `@vectorized` parse + policy | **Partial** — 7d-a/e done | **7d-b:** no full elaboration → `ParallelFor` MIR for `@parallel` on `for` |
| `parallel for` keyword | **Partial** — 7b | Lowers via `li_par_pool`, not OpenMPIRBuilder ([#34](https://github.com/li-langverse/lic/issues/34)) |
| `@cpu` / `@gpu` | **Partial** — MIR telemetry only | No memory-space policy or copy semantics |
| HPC rubric **Kokkos** | **missing** | No portable execution-space + memory-space story |
| Tier-2 catalog | **1/25** `pure_li` (local explorer) | **9/25** `shared_c_kernel`; OpenMP column partial |
| OpenMP pragma surface | **Partial** | No first-class Li `@` → OpenMP IR path (blocked on #34 `plan-approved`) |
| G-par closed slice | **Partial** | Keyword `parallel for` + disjoint lemmas; decorator path not in closed slice |
| G-dec | **Partial** | Exploit suite; elaboration incomplete |

## Dependencies

| Track | ID | Role |
|-------|-----|------|
| Decorator elaboration | **PH-7d** (7d-b, 7d-c) | `@parallel` → `ParallelFor`; `@vectorized` scope |
| Math / loop kernels | **PH-7e** | Tier-1/2 physics loops inherit portable lowering |
| Host OpenMP IR | **#34** / [lowering map](2026-06-07-std-execution-openmp-mlir-lowering-map.md) | OpenMPIRBuilder target **after** `plan-approved` on #34 |
| View / buffer ABI | **#110** | Kokkos View analog; #15 references minimal space enums only |
| Offload rubric | **#116** | OpenMPTarget checklist; hard-gates on #34 |
| Parallel safety | **G-par** | Disjoint witnesses on decorator-elaborated loops |
| Static decorator rules | **G-dec** | Reserved names, exploit suite |
| Hetero orchestration | **G-hetero** | `@cpu`/`@gpu` placement via `li-parallel` runtime seams |
| Distributed | **G-par-dist** | **Deferred** — block partition only; not in #15 exit gate |
| Catalog / ingest | **benchmarks** [#41](https://github.com/li-langverse/benchmarks/issues/41) | Tier-2 row migration tracking |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A — Portable model spec** | [spec: portable execution + memory spaces](../specs/2026-06-08-li-portable-execution-memory-spaces.md): `ExecutionSpace` (`HostSerial`, `HostParallel`, `Device`), `MemorySpace` (`Host`, `Device`, `Unified`), copy policy table | Reviewed; cross-links #110 View ABI without duplicating it |
| **B — Decorator elaboration (7d-b)** | Compiler: `@parallel(disjoint=d)` on `for`/`while`/`def` → `Stmt::ParallelFor` / `MirOp::OmpParallelFor` with `parallel_disjoint_proven` | `li-tests/decorators/parallel_with_disjoint.li` + `check-mir-parallel-decorator.sh` green |
| **C — Stack semantics (7d-c)** | `@cpu` + `@parallel` + `@vectorized(lanes=N)` stacks elaborate orthogonally (teams vs SIMD — same rule as phase 07 §7d) | `vectorized_for_scope_ok.li` + new `parallel_decorator_stack_ok.li` |
| **D — Portable `parallel_for` API** | `packages/li-parallel/src/parallel/kernels.li`: typed `parallel_for_range` wrapper over `li_parallel_for_i64` with execution-space tag; **no hidden Kokkos** | `li-tests/tooling/li_parallel_for_portable_smoke.sh` |
| **E — Memory-space policy hooks** | `@gpu` / `@cpu` set MIR proc tags consumed by `hetero.li`; document **explicit copy** points (no silent host↔device) | `li-tests/tooling/li_hetero_gate_smoke.sh` extended (plan-only metadata) |
| **F — Tier-2 migration matrix** | `docs/benchmarks/tier2-pure-li-parallel-migration.md`: 9 `shared_c_kernel` rows → prerequisites → target `pure_li` label | Linked from **benchmarks** tooling-catalog; no catalog PR until row meets gate |
| **G — G-par / G-dec corpus** | Extend `race_shared_memory` + `decorator_exploits` for elaborated `@parallel`; update `provability-gaps.md` row when B–C land | `./li-tests/run_all.sh race_shared_memory decorators decorator_exploits` |
| **H — Codegen handoff (#34)** | Checklist item: when #34 **`plan-approved`**, enable OpenMPIRBuilder path for elaborated `@parallel` without changing user syntax | `LI_CODEGEN_OMP_IR=1` spike per #34 sub-phase G |

## Decorator → portable lowering (summary)

| User surface | Elaboration (7d-b/c) | Portable runtime (D) | IR target (#34) |
|--------------|----------------------|----------------------|-----------------|
| `@parallel(disjoint=d)` on `for` | `ParallelFor` + disjoint witness | `parallel_for_range(..., HostParallel)` | OpenMPIRBuilder `createParallel` + `createLoop` |
| `@cpu` `@parallel` on `def` | inherit disjoint on body loops | `HostParallel` default | host teams only |
| `@gpu` on `def` | device placement tag | `Device` execution space; **explicit** buffer policy (E) | MLIR `omp.target` spike (#34 §D) |
| `@vectorized(lanes=4)` | `ArraySimdScope` | **never** calls `parallel_for` | LLVM vector IR |
| `parallel for` keyword | same MIR as `@parallel` | same runtime | same IR |

**REQ-map (implementation track, post-approval):**

- **REQ-PAR-PORT-1:** `@parallel` and `parallel for` share one MIR op and one portable runtime entry point.
- **REQ-PAR-PORT-2:** Execution-space tag is visible in `lic verify` telemetry (`mir_execution_space=HostParallel|Device`).
- **REQ-PAR-PORT-3:** No tier-2 row may flip to `pure_li` until REQ-PAR-PORT-1 holds for that kernel's decorator stack.
- **REQ-PAR-PORT-4:** Memory-space copies require explicit API (`copy_to_device`, etc.) — no silent Kokkos-style deep copy in v1.

## Tests / benches

| Suite | Purpose |
|-------|---------|
| `li-tests/decorators/` | Positive elaboration: `@parallel`, stacks |
| `li-tests/decorator_exploits/` | G-dec: reserved names, missing `disjoint=` |
| `li-tests/race_shared_memory/` | G-par compile_fail + `good_disjoint_parallel.li` |
| `scripts/check-mir-parallel-decorator.sh` | MIR witness smoke |
| `li-tests/tooling/li_parallel_for_portable_smoke.sh` | **New** — portable API smoke |
| `li-tests/tooling/li_hetero_gate_smoke.sh` | G-hetero placement probes |
| **benchmarks** tier-2 | OpenMP scaling + `pure_li` column — ingest **after** F row gates |
| `bench.py --tier 1` | matmul / MD unaffected by doc-only PR |

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-par** | Partial → Partial+ | Add decorator elaboration to closed slice when B–C land; Lean disjoint proofs still open |
| **G-dec** | Partial → Partial+ | Elaboration completes static-only story |
| **G-hetero** | Partial | E adds explicit copy policy; address-space proofs open |
| **G-math** | Partial | 7e loop nests use same portable path; no new math axioms |
| **G-par-dist** | Partial (unchanged) | Explicitly out of #15 exit gate |
| **G-gpu** | Partial | Placement metadata only until #116 + #34 codegen |

## Rollout

1. **This PR (plan only):** land this doc + portable execution spec stub + tier-2 migration matrix + phase-07 cross-link.
2. Human adds **`plan-approved`** on #15; remove **`plan-needed`**.
3. Implementation agent: **B → C → D → G** in **lic** (compiler + `li-parallel` + tests).
4. **E** metadata PR can land with B–C if hetero smokes pass.
5. **F** coordination PR on **benchmarks** (catalog labels only) after first row meets REQ-PAR-PORT-3.
6. Hand off **H** to #34 implementation track when that issue is `plan-approved`.
7. Update `provability-gaps.md` when G-par decorator path reaches closed slice.

## Human-only

- [ ] Label **`plan-approved`** on #15 before compiler/codegen PRs.
- [ ] Confirm **#110** View ABI does not conflict with memory-space enums in spec §A.
- [ ] Approve first tier-2 row migration (recommend `heat_equation_2d` per #110 checklist).
- [ ] Merge plan PR (draft → ready) after doc review.
- [ ] Do **not** enable OpenMPIRBuilder migration until #34 is also `plan-approved`.

## Related issues / plans

- [#34](https://github.com/li-langverse/lic/issues/34) — LLVM OpenMP IR / MLIR `omp` lowering map (host IR anchor)
- [#110](https://github.com/li-langverse/lic/issues/110) — Kokkos View + execution-space semantics
- [#116](https://github.com/li-langverse/lic/issues/116) — OpenMPTarget offload rubric
- [#11](https://github.com/li-langverse/lic/issues/11) — PH-7e / G-math Horner codegen (orthogonal math slice)
- [#28](https://github.com/li-langverse/lic/issues/28) — PETSc–Kokkos exascale memory model
- [PR #1069](https://github.com/li-langverse/lic/pull/1069) — draft plan for #34 (complements this plan)
