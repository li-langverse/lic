---
name: PH-7e OpenMP affinity + MPI×threads occupancy rubric (#129)
workflow_repo: lic
ph_ids: [PH-7e, PH-7b, PH-7d]
gaps: [G-par]
tracker: docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md
master_plan: docs/superpowers/plans/2026-05-14-li-master-plan.md
issues: [li-langverse/lic#129]
related_issues: [li-langverse/lic#34, li-langverse/lic#116, li-langverse/lic#124, li-langverse/lic#15]
north_star_fit: "HPC/scientific computing (PH-7e, G-par) — proof-before-perf; portable parallel runtime must not silently oversubscribe or ignore affinity best practice"
status: draft
---

# PH-7e / G-par: OpenMP affinity + MPI×threads occupancy rubric (#129)

**Date:** 2026-06-07  
**Kind:** Explorer-finding → normative runtime/lowered-OpenMP rubric + guardrails  
**Parent:** [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) §7b  
**Companion specs:** [2026-05-25-li-execution-resources.md](../specs/2026-05-25-li-execution-resources.md), [2026-05-25-li-execution-surface.md](../specs/2026-05-25-li-execution-surface.md)  
**Related (not duplicate):** [#124](https://github.com/li-langverse/lic/issues/124) prescriptive vs descriptive **branch** policy; this plan covers **affinity + occupancy + backend selection** rubric

## Problem

Gap explorer **2026-05-20** ([digest](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-20-explorer.md)) surfaced operational Kokkos+OpenMP practice that Li’s partial OpenMP / pthread-pool lowering does not yet encode:

| External practice | Source | Li gap today |
|-------------------|--------|--------------|
| `OMP_NUM_THREADS`, `OMP_PROC_BIND=spread`, `OMP_PLACES=threads` | [HPC Carpentry — Kokkos with OpenMP](http://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html) | `--cores` / `LI_OMP_THREADS` set team size only; no affinity doc or defaults |
| **MPI ranks × OpenMP threads ≤ physical cores** | Same + Kokkos hybrid guidance | No occupancy warning when `team × ranks > cores` |
| Prefer OpenMP Kokkos backend when host already uses OpenMP | [Trilinos#1391](https://github.com/trilinos/Trilinos/issues/1391) | No `[execution].parallel_backend` policy bit |
| Prescriptive vs descriptive loop variants | [White Rose paper](https://eprints.whiterose.ac.uk/id/eprint/235565/1/P3_Paper_on_Kokkos_vs_OpenMP_descriptive_and_prescriptive_-6.pdf) | Complements **#124**; affinity plan does not subsume branch rubric |

**Current runtime:** `parallel for` lowers to `li_parallel_for_i64` → native **pthread pool** (`runtime/li_par_pool.c`); deprecated `li_omp_parallel_for_*` alias warns once. OpenMP IR lowering (#34) is a separate codegen track.

**Risk:** Tier-2 game physics / MD benches (`md_lennard_jones`, `three_body`) report misleading speedups when users oversubscribe hybrid MPI+OpenMP clusters — perf pillar violated **after** proof, not by weakening benchmarks.

## Vision / philosophy check

- **Pass** — operational guardrails support **provable then fast**; warnings preserve strict-by-default (no silent wrong results).
- **Reject:** auto-pinning that breaks proved disjoint semantics; weakening `threshold_ratio_cpp`; hiding oversubscription in tier-2 CSV columns.
- **Defer to #124:** divergent prescriptive/descriptive **codegen branches** (separate plan).
- **Human-only:** `trusted.lean` changes; master-plan row merge.

## Scope

### In scope

1. **Normative rubric table** — map HPC Carpentry / Trilinos practice → Li CLI, `li.toml`, env, diagnostics.
2. **Thread affinity documentation** — handbook + execution spec; optional runtime defaults when OpenMP backend is active.
3. **Occupancy guard** — compile-time or startup warning when configured parallelism exceeds detected physical cores (including MPI rank factor when `OMPI_COMM_WORLD_SIZE` / `PMI_SIZE` present).
4. **Backend policy bit** — `[execution] parallel_backend = "openmp_prescriptive" | "portable_pthread" | "auto"` (names TBD in spec); `@cpu(openmp=…)` decorator hook for #15 / #34 alignment.
5. **Tests + bench hooks** — `li-tests/execution/` warnings; `execution_resource_sweep` occupancy column in **benchmarks** ingest (harness-only PR after lic guard lands).

### Out of scope

- Full Kokkos-class decorator lowering (**#15**)
- LLVM OpenMP IR / MLIR omp mapping (**#34**)
- OpenMPTarget offload checklist (**#116**)
- Prescriptive vs descriptive **divergent branch** codegen (**#124**)
- MPI runtime in Li stdlib (read env only for occupancy math)
- Product implementation in this planning PR

## Rubric (normative target)

| Practice | Li deliverable | Verification |
|----------|----------------|--------------|
| Thread affinity env | Document `OMP_PROC_BIND` / `OMP_PLACES`; when `parallel_backend=openmp_prescriptive`, `lic` may set **documented** defaults before first parallel region (override via env) | Handbook section + spec; opt-in integration test |
| Occupancy guard | Warn (stderr, once) when `mpi_ranks × team_size > physical_cores` or `team_size > physical_cores` in serial | `li-tests/execution/occupancy_warn*.li` + golden stderr |
| Backend choice | Policy in `li.toml` + `--parallel-backend=`; default `portable_pthread` until OpenMP IR path green | Parse tests + manifest round-trip |
| Proof preserved | Guard is diagnostic only; does not skip `disjoint=` checks (**G-par**) | `race_shared_memory` + `decorator_exploits` unchanged green |

## Implementation phases

### Phase 0 — Spec + handbook (docs-only, can land first)

| Step | Path | Content |
|------|------|---------|
| 0.1 | `docs/superpowers/specs/2026-06-07-li-openmp-affinity-occupancy-rubric.md` | Normative rubric + env/CLI table |
| 0.2 | `docs/language/parallelism.md` | User-facing: affinity, hybrid MPI+OpenMP, when to use `--cores` vs OpenMP env |
| 0.3 | Extend [2026-05-25-li-execution-resources.md](../specs/2026-05-25-li-execution-resources.md) | Add `parallel_backend`, `affinity_profile` keys |

**Exit:** `./scripts/check-doc-provability-claims.sh` green; cross-links to #129, #124, #34.

### Phase 1 — Occupancy guard (runtime, minimal)

| Step | Change | Notes |
|------|--------|-------|
| 1.1 | `runtime/li_par_pool.c` — `li_warn_occupancy_once()` | Read `_SC_NPROCESSORS_ONLN`; optional `OMPI_COMM_WORLD_SIZE` / `PMI_SIZE`; compare to baked `team_size` from `--cores × --threads-per-core` |
| 1.2 | Call site | Invoke once before first `li_parallel_for_i64` when `LI_EXEC_WARN_OVERSUBSCRIBE=1` (default **on** in debug builds; **on** with one-release warn in release) |
| 1.3 | Message shape | `lic: warning: parallel team (N) × mpi_ranks (M) = T exceeds physical cores (C); see docs/language/parallelism.md#hybrid-mpi-openmp` |

**Exit:** `./li-tests/run_all.sh execution_occupancy` (new suite) green.

### Phase 2 — OpenMP affinity defaults (OpenMP backend only)

| Step | Change | Notes |
|------|--------|-------|
| 2.1 | `runtime/li_omp_init.c` (new, linked when `-fopenmp`) | If `parallel_backend=openmp_prescriptive` and env unset: set `OMP_PROC_BIND=spread`, `OMP_PLACES=threads` via `setenv(..., 0)` (no overwrite) |
| 2.2 | Codegen gate | Only when #34 OpenMP IR lowering selected; pthread pool path skips |
| 2.3 | Document escape hatch | Users export env before launch; Li never pins in `portable_pthread` mode |

**Exit:** opt-in CI job `openmp-affinity-smoke` (Linux + libomp); skipped on Windows until OpenMP path stable.

### Phase 3 — Backend policy bit (manifest + CLI)

| Step | Change | Notes |
|------|--------|-------|
| 3.1 | `lic build --parallel-backend=…` | Values: `portable_pthread` (default), `openmp_prescriptive`, `auto` (prefer OpenMP when host toolchain + `-fopenmp` link) |
| 3.2 | `li.toml` `[execution]` | `parallel_backend = "portable_pthread"` |
| 3.3 | Decorator surface (doc-only v1) | `@cpu(parallel_backend=openmp_prescriptive)` defers to #15 decorator elaboration |

**Exit:** `li-tests/manifest/execution_backend_parse.li`; no codegen change until `plan-approved` implement pass completes Phase 2 gate.

### Phase 4 — Benchmarks + tier-2 honesty

| Step | Repo | Change |
|------|------|--------|
| 4.1 | **benchmarks** | `execution_resource_sweep.py` — add columns `physical_cores`, `mpi_ranks`, `oversubscribed` |
| 4.2 | **benchmarks** | Tier-2 MD/game physics rows annotate when sweep ran oversubscribed (no threshold tweak) |
| 4.3 | **lic** | `./scripts/check-hpc-competitive.sh` — fail if tier-2 li build logs occupancy warning unless `LI_EXEC_WARN_OVERSUBSCRIBE=0` documented in bench README |

**Exit:** ingest CSV schema version bump + dashboard note; **no** `threshold_ratio_cpp` edits.

## PH / REQ / G / test mapping

| ID | Requirement | Verification |
|----|-------------|--------------|
| **PH-7e** | Portable parallel lowering honesty | Tier-2 perf columns + occupancy annotation |
| **PH-7b** | `parallel for` + OpenMP link | Phase 2 behind OpenMP IR (#34) |
| **PH-7d** | Decorator policy inheritance | Phase 3 doc hook → #15 |
| **REQ-par-affinity-001** | Document + optional OpenMP defaults | Spec § affinity; handbook |
| **REQ-par-occupancy-001** | Warn on oversubscription | `execution_occupancy` suite |
| **REQ-par-backend-001** | Explicit backend selection | CLI + `li.toml` parse tests |
| **G-par** | Parallel safety + ops correctness | Guard diagnostic-only; disjoint proofs unchanged |
| **G-math** | — | No change (perf ops layer) |
| **Bench** | `execution_resource_sweep` | benchmarks harness PR after Phase 1 |
| **Bench** | `md_lennard_jones`, `three_body` tier 2 | advisory speedup only when not oversubscribed |

## Gap register updates (implement pass)

| Gap | Move | Evidence |
|-----|------|----------|
| **G-par** | Partial → Partial+ops | Add row: operational affinity/occupancy rubric landed (#129) |
| Registry | Close explorer row | `swarm-gap-ingest.py` after plan merge + implement Phase 1 |

## Files touched (implement pass)

| Path | Change |
|------|--------|
| `docs/superpowers/specs/2026-06-07-li-openmp-affinity-occupancy-rubric.md` | New normative spec |
| `docs/language/parallelism.md` | Affinity + hybrid MPI section |
| `docs/superpowers/specs/2026-05-25-li-execution-resources.md` | Backend + affinity keys |
| `runtime/li_rt.c`, `runtime/li_omp_init.c` | Occupancy warn + optional affinity init |
| `li-tests/execution/` | Occupancy + manifest suites |
| `benchmarks/harness/execution_resource_sweep.py` | Occupancy columns (benchmarks repo) |

## Learned from

1. [HPC Carpentry — Kokkos with OpenMP](http://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html) — `OMP_NUM_THREADS`, `OMP_PROC_BIND=spread`, `OMP_PLACES=threads`, MPI×threads ≤ cores
2. [Trilinos#1391](https://github.com/trilinos/Trilinos/issues/1391) — prefer OpenMP backend when host already OpenMP-enabled
3. [2026-05-25-li-execution-resources.md](../specs/2026-05-25-li-execution-resources.md) — four-axis resource model (`--cores`, `--threads-per-core`, no `--jobs` conflation)
4. [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) §7b — `parallel for` + OpenMP exit gates

## Acceptance criteria (plan-approved → implement)

- [ ] Normative spec + handbook sections merged
- [ ] Occupancy warning fires in hybrid oversubscribe fixture; silent when `team × ranks ≤ cores`
- [ ] OpenMP affinity defaults apply only in `openmp_prescriptive` backend; never override user env
- [ ] `parallel_backend` CLI/manifest parse tests green
- [ ] `race_shared_memory` + `decorator_exploits` unchanged green
- [ ] Benchmarks sweep publishes occupancy columns (follow-up PR)
- [ ] #129 closable with links to spec + test logs; **G-par** ops row updated in `provability-gaps.md`

## Handoffs

| Agent | Trigger |
|-------|---------|
| `code_implementer` | After **`plan-approved`** on #129 — Phase 1 → 3 in order |
| `issue_planner` | #124 divergent-branch plan (separate PR) |
| `bench_improver` | benchmarks harness Phase 4 after Phase 1 on main |
| Human maintainer | Merge plan PR; add **`plan-approved`** label |
