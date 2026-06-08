---
name: PH-7e OpenMP prescriptive vs descriptive divergent-branch rubric (#124)
workflow_repo: lic
ph_ids: [PH-7e, PH-7d, PH-7b]
gaps: [G-par, G-dec]
tracker: docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md
master_plan: docs/superpowers/plans/2026-05-14-li-master-plan.md
issues: [li-langverse/lic#124]
related_issues: [li-langverse/lic#15, li-langverse/lic#34, li-langverse/lic#116, li-langverse/lic#110, li-langverse/lic#129]
north_star_fit: "HPC/scientific computing (PH-7e, G-par) — proof-before-perf; portable codegen must document when prescriptive OpenMP directives vs descriptive compiler discovery win, and when divergent backend branches are required"
status: phase-0-1-landed
---

# PH-7e / G-par: OpenMP prescriptive vs descriptive divergent-branch rubric (#124)

**Date:** 2026-06-07  
**Kind:** Explorer-finding → normative lowering rubric + divergent-branch checklist (planning only)  
**Parent:** [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) §7d–7e  
**Companion specs:** [2026-05-25-li-execution-surface.md](../specs/2026-05-25-li-execution-surface.md), [2026-05-25-li-execution-resources.md](../specs/2026-05-25-li-execution-resources.md)  
**Related (not duplicate):** [#129](https://github.com/li-langverse/lic/issues/129) affinity + MPI occupancy; [#34](https://github.com/li-langverse/lic/issues/34) LLVM OpenMP IR map; [#15](https://github.com/li-langverse/lic/issues/15) Kokkos-class execution spaces

## Problem

Gap explorer **2026-05-20** ([digest](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-20-explorer.md)) surfaced that **portable parallel code still needs divergent, platform-specific branches** to stay competitive with vendor-tuned implementations. Comparative Kokkos vs OpenMP literature distinguishes:

| Variant | Who decides parallelism | Typical codegen | Competitive when |
|---------|-------------------------|-----------------|------------------|
| **Prescriptive** | User / compiler emits explicit directives | `#pragma omp target teams distribute parallel for simd`, structured `schedule(static)` | Vendor OpenMP offload tuned; known trip counts; SIMD inner loops |
| **Descriptive** | Compiler discovers parallelism from loop structure | `#pragma omp parallel for` (auto schedule), auto-vectorization | Host CPU with mature LLVM loop opts; irregular control flow |
| **Divergent branch** | Runtime / build-time backend fork | Kokkos execution-space dispatch; separate CUDA/HIP/SYCL vs OpenMP host TU | Heterogeneous clusters; Frontier/Aurora-class GPU nodes |

**Li gap today:** `std/execution/decorators.li` documents reserved decorator names and resource knobs but has **no policy** for:

1. When `@parallel` / `parallel for` lowers to **prescriptive** OpenMP (explicit teams/target/SIMD) vs **descriptive** (compiler-discovered parallel loops).
2. When codegen must emit **divergent backend branches** (CUDA/HIP/SYCL vs OpenMP host) vs a single portable path.
3. How Li decorators map to Kokkos-style **execution spaces** (`Serial`, `OpenMP`, `Cuda`, `HIP`, `SYCL`, `OpenMPTarget`) without weakening **G-par** disjoint proofs.

**Current lowering:** `parallel for` → `li_parallel_for_i64` (pthread pool); `@vectorized` → LLVM vectors. No OpenMP prescriptive/descriptive fork; no execution-space dispatch table.

**Risk:** Tier-2 HPC benches (`md_lennard_jones`, `matmul_blocked`) cannot reach Kokkos-class portability on paper without a documented rubric — implementers will either (a) emit one-size-fits-all descriptive loops and lose perf, or (b) add ad-hoc `#ifdef` branches that bypass proof gates.

## Vision / philosophy check

- **Pass** — rubric supports **provable then fast**; prescriptive paths require the same `disjoint=` proofs as descriptive paths.
- **Reject:** weakening `threshold_ratio_cpp` to green benches; skipping disjoint checks for prescriptive offload; `unsafe` / unproved backend forks.
- **Defer to #34:** LLVM OpenMP IR / MLIR `omp` dialect lowering mechanics (this plan defines **when**, not **how** to emit IR).
- **Defer to #116:** OpenMPTarget offload checklist (this plan references target teams hooks only).
- **Complements #129:** affinity/occupancy rubric is operational; this plan is **codegen branch selection**.
- **Human-only:** `trusted.lean` changes; master-plan row merge.

## Scope

### In scope

1. **Normative rubric table** — prescriptive vs descriptive vs divergent-branch decision matrix keyed by decorator stack, loop shape, and target backend.
2. **Divergent-branch hook checklist** — required codegen extension points: `target`, `teams`, `distribute`, `parallel for`, `simd`, execution-space dispatch.
3. **Decorator policy surface** — document (spec + `decorators.li` header) proposed knobs: `@cpu(openmp=prescriptive|descriptive|auto)`, `@parallel(schedule=static|auto)`, backend fork markers.
4. **Kokkos execution-space mapping** — table from Li decorators → Kokkos analog → OpenMP prescriptive/descriptive variant.
5. **Acceptance tests plan** — `li-tests/execution/openmp_rubric/` fixture list (compile-only v1); benchmarks tier-2 annotation columns.
6. **G-par / G-dec gap register updates** — partial row for branch-policy rubric landed.

### Out of scope

- Product codegen implementation (requires **`plan-approved`** + separate implement PRs)
- Full Kokkos-class decorator lowering (**#15**)
- LLVM OpenMP IR builder mapping (**#34**)
- OpenMPTarget backend bring-up (**#116**)
- Thread affinity / MPI occupancy (**#129** — separate plan at [2026-06-07-ph7e-openmp-affinity-mpi-occupancy-rubric-129.md](2026-06-07-ph7e-openmp-affinity-mpi-occupancy-rubric-129.md))
- Weakening benchmark thresholds

## Rubric (normative target)

### A. Prescriptive vs descriptive selection

| Signal | Prescriptive (directive-driven) | Descriptive (compiler-discovered) | Proof requirement |
|--------|--------------------------------|-----------------------------------|-------------------|
| `@cpu(openmp=prescriptive)` or `li.toml parallel_style=prescriptive` | Emit explicit `#pragma omp` stack | — | Same `disjoint=` as descriptive |
| Regular loop, known trip count, inner `@vectorized` | `teams distribute parallel for` + `simd` on inner | Auto-vec outer + `parallel for` | SIMD scope proof (**G-math** partial) |
| Irregular control flow, indirect indexing | — | `parallel for` + auto schedule | Stronger disjoint proof or reject |
| GPU offload intent (`@gpu`, `@cpu(openmp=target)`) | OpenMP **target** prescriptive stack | Reject descriptive-only on device | **#116** offload proof track |
| Default / `@cpu(openmp=auto)` | Prefer descriptive on host pthread/OpenMP path until #34 IR green | Same | Auto must log chosen variant in `-v` build |

### B. Divergent backend branches

| Condition | Branch hook | Li surface | Verification |
|-----------|-------------|------------|--------------|
| Host-only build (`--target=host`) | Single TU, descriptive or prescriptive per §A | `@cpu` default | `li-tests/execution/openmp_rubric/host_only.li` |
| Heterogeneous manifest (`[execution] backends = ["openmp_host", "cuda"]`) | **Divergent TU** per backend; shared proved MIR | `@gpu(vendor=nvidia)` + `@cpu(openmp=prescriptive)` on host fallback | Compile-only fixtures per backend |
| Kokkos-style execution space | Dispatch table in `runtime/li_exec_dispatch.c` (future) | Maps to `@cpu`, `@gpu`, `@parallel` stack | Golden dispatch log in CI |
| Competitive perf requires vendor tweak | Documented **opt-in** branch (`LI_EXEC_PRESCRIPTIVE=1`) | Never silent; stderr once | Bench CSV `openmp_variant` column |

### C. Decorator → execution-space mapping (Kokkos analog)

| Li decorator stack | Kokkos analog | OpenMP prescriptive | OpenMP descriptive |
|--------------------|---------------|---------------------|-------------------|
| `@cpu` `@parallel` | `Kokkos::OpenMP` / `DefaultHostExecutionSpace` | `#pragma omp parallel for schedule(static)` | `#pragma omp parallel for` (auto) |
| `@cpu` `@parallel` `@vectorized(lanes=8)` | OpenMP + SIMD on inner | `parallel for simd` inner + teams outer if tiled | Auto-vec + `parallel for` |
| `@gpu(vendor=nvidia)` | `Kokkos::Cuda` | N/A (CUDA branch) | N/A |
| `@cpu(openmp=target)` | `Kokkos::OpenMPTarget` | `#pragma omp target teams distribute parallel for` | Reject — target requires prescriptive |
| `@serial` | `Kokkos::Serial` | No OpenMP | No OpenMP |

## Implementation phases (post plan-approved)

### Phase 0 — Spec + rubric doc (docs-only, can land first)

| Step | Path | Content |
|------|------|---------|
| 0.1 | `docs/superpowers/specs/2026-06-07-li-openmp-prescriptive-descriptive-rubric.md` | Normative §A–§C tables + decision flowchart |
| 0.2 | `docs/language/parallelism.md` | User-facing: when Li chooses prescriptive vs descriptive; divergent backend builds |
| 0.3 | `std/execution/decorators.li` header | Document proposed `@cpu(openmp=…)` knobs (comment-only until parser) |
| 0.4 | Extend [2026-05-25-li-execution-surface.md](../specs/2026-05-25-li-execution-surface.md) | Layer 4: backend fork + OpenMP variant |

**Exit:** `./scripts/check-doc-provability-claims.sh` green; cross-links to #124, #15, #34, #116, #129.

### Phase 1 — Rubric fixtures (compile-only)

| Step | Change | Notes |
|------|--------|-------|
| 1.1 | `li-tests/execution/openmp_rubric/` | Fixtures: `prescriptive_teams_simd.li`, `descriptive_auto.li`, `reject_target_descriptive.li` |
| 1.2 | Golden `-v` logs | Expected `lic: openmp variant=prescriptive` / `descriptive` strings (stub until codegen) |
| 1.3 | `decorator_exploits/` | Ensure `@cpu(openmp=prescriptive)` typosquat still fail |

**Exit:** `./li-tests/run_all.sh execution_openmp_rubric` green (parse + policy only).

### Phase 2 — Codegen branch hooks (requires #34 OpenMP IR)

| Step | Change | Notes |
|------|--------|-------|
| 2.1 | `compiler/codegen/openmp_variant.rs` (name TBD) | Emit prescriptive vs descriptive pragma stacks per rubric |
| 2.2 | Divergent TU split | `*_host_openmp.cpp` vs `*_cuda.cu` when manifest lists multiple backends |
| 2.3 | Dispatch stub | `runtime/li_exec_dispatch.c` — log chosen execution space |

**Exit:** opt-in CI job `openmp-rubric-smoke`; `race_shared_memory` unchanged green.

### Phase 3 — Benchmarks honesty

| Step | Repo | Change |
|------|------|--------|
| 3.1 | **benchmarks** | Tier-2 CSV columns: `openmp_variant`, `execution_space`, `divergent_branch` |
| 3.2 | **benchmarks** | `execution_resource_sweep.py` — annotate prescriptive vs descriptive runs |
| 3.3 | **lic** | `./scripts/check-hpc-competitive.sh` — fail if competitive claim uses descriptive-only on offload fixture |

**Exit:** ingest schema bump; **no** `threshold_ratio_cpp` edits.

## PH / REQ / G / test mapping

| ID | Requirement | Verification |
|----|-------------|--------------|
| **PH-7e** | Competitive portable codegen rubric | Tier-2 annotation + rubric spec |
| **PH-7d** | Decorator policy for OpenMP variant | `@cpu(openmp=…)` doc + parse fixtures |
| **PH-7b** | `parallel for` + OpenMP link | Phase 2 behind #34 |
| **REQ-par-omp-variant-001** | Prescriptive vs descriptive decision table | Spec §A; handbook |
| **REQ-par-omp-branch-001** | Divergent backend hook checklist | Spec §B; dispatch stub tests |
| **REQ-par-omp-kokkos-map-001** | Execution-space mapping table | Spec §C |
| **G-par** | Disjoint proofs unchanged across variants | `race_shared_memory` + `decorator_exploits` |
| **G-dec** | Decorator elaboration to MIR tags | Phase 2 ties to #387 |
| **G-math** | SIMD prescriptive inner loops | Partial — `@vectorized` scope proofs |
| **Bench** | `md_lennard_jones`, `matmul_blocked` tier 2 | `openmp_variant` column |
| **Bench** | `execution_resource_sweep` | Prescriptive/descriptive annotation |

## Gap register updates (implement pass)

| Gap | Move | Evidence |
|-----|------|----------|
| **G-par** | Partial → Partial+policy | Row: OpenMP prescriptive/descriptive rubric (#124) |
| **G-dec** | Partial | Decorator → MIR variant tags documented |
| Registry | Close explorer row | `swarm-gap-ingest.py` after plan merge + Phase 0 |

## Files touched (implement pass)

| Path | Change |
|------|--------|
| `docs/superpowers/specs/2026-06-07-li-openmp-prescriptive-descriptive-rubric.md` | New normative spec |
| `docs/language/parallelism.md` | Prescriptive vs descriptive section |
| `docs/superpowers/specs/2026-05-25-li-execution-surface.md` | Layer 4 backend fork |
| `std/execution/decorators.li` | Header comments for proposed knobs |
| `li-tests/execution/openmp_rubric/` | Rubric fixtures |
| `compiler/codegen/` (with #34) | Variant emission |
| `benchmarks/harness/` | CSV columns (benchmarks repo) |

## Learned from

1. [White Rose — Kokkos vs OpenMP descriptive and prescriptive](https://eprints.whiterose.ac.uk/id/eprint/235565/1/P3_Paper_on_Kokkos_vs_OpenMP_descriptive_and_prescriptive_-6.pdf) — when prescriptive directives beat compiler discovery on heterogeneous systems
2. [HPC Carpentry — Kokkos with OpenMP](http://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html) — hybrid host/device tuning; teams + SIMD stacks
3. [Trilinos#1391](https://github.com/trilinos/Trilinos/issues/1391) — backend preference when host already OpenMP-enabled; divergent branch rationale
4. [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) §7d–7e — decorator-first HPC surface and partial lowering status

## Acceptance criteria (plan-approved → implement)

- [ ] Normative spec + handbook sections merged (Phase 0)
- [ ] Rubric tables §A–§C reviewed against #15, #34, #116 scope boundaries
- [ ] `li-tests/execution/openmp_rubric/` fixture list committed (parse/policy v1)
- [ ] Tier-2 bench CSV schema documented for `openmp_variant` / `execution_space`
- [ ] `race_shared_memory` + `decorator_exploits` unchanged green (no proof regression)
- [ ] #124 closable with links to spec; **G-par** policy row updated in `provability-gaps.md`
- [ ] No product codegen in plan PR — implement PRs follow **`plan-approved`**

## Handoffs

| Agent | Trigger |
|-------|---------|
| `code_implementer` | After **`plan-approved`** on #124 — Phase 0 → 1 first; Phase 2 blocked on #34 |
| `issue_planner` | #34 LLVM IR map; #116 OpenMPTarget checklist (separate plans) |
| `bench_improver` | benchmarks harness Phase 3 after Phase 0 on main |
| Human maintainer | Merge plan PR; add **`plan-approved`** label; remove **`plan-needed`**
