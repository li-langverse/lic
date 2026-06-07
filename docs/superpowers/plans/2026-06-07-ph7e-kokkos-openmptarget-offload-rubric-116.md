---
name: PH-7e Kokkos OpenMPTarget offload rubric (#116)
workflow_repo: lic
ph_ids: [PH-7e, PH-7d, PH-7b]
gaps: [G-par, G-gpu, G-dec]
tracker: docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md
master_plan: docs/superpowers/plans/2026-05-14-li-master-plan.md
issues: [li-langverse/lic#116]
related_issues:
  - li-langverse/lic#34
  - li-langverse/lic#110
  - li-langverse/lic#15
  - li-langverse/lic#129
north_star_fit: "HPC/scientific computing (PH-7e, G-par, G-gpu) — proof-before-perf; vendor-agnostic GPU offload rubric without codegen until OpenMP IR lowering is plan-approved"
status: draft
---

# PH-7e / G-par: Kokkos OpenMPTarget offload checklist vs Li `std/execution` (#116)

**Date:** 2026-06-07  
**Kind:** Explorer-finding → normative offload rubric + tier-2 bench scope notes  
**Parent:** [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) §7d–7e  
**Normative rubric:** [2026-06-07-li-openmptarget-offload-rubric.md](../specs/2026-06-07-li-openmptarget-offload-rubric.md)  
**Related (not duplicate):** [#34](https://github.com/li-langverse/lic/issues/34) LLVM OpenMP IR lowering; [#110](https://github.com/li-langverse/lic/issues/110) Kokkos Views/memory spaces; [#15](https://github.com/li-langverse/lic/issues/15) portable decorator lowering; [#129](https://github.com/li-langverse/lic/issues/129) host OpenMP affinity/occupancy

## Problem

Gap explorer **2026-05-20** ([digest](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-20-explorer.md)) identified Kokkos **OpenMPTarget** as a vendor-agnostic GPU path via standard OpenMP `target` / `teams` / `map` — but Li has no checklist mapping `std/execution` offload decorators to that lowering surface.

| External signal | Source | Li gap today |
|-----------------|--------|--------------|
| OpenMPTarget backend maturity | [Kokkos#2976](https://github.com/kokkos/kokkos/issues/2976) | `@gpu` MIR telemetry only; no OpenMP-target rubric |
| Compiler/vendor portability of target offload | [OSTI portability study](https://www.osti.gov/servlets/purl/2224192) | No documented vendor-runtime deferral boundaries |
| Host OpenMP backend preference when mixing app threads | [Trilinos#1391](https://github.com/trilinos/Trilinos/issues/1391) | Covered by **#129** (host affinity); this plan covers **device target** + host/device memory-space pairing |
| Kokkos-class memory spaces + execution spaces | Registry `gap-hpc-kokkos-execution-memory-spaces` | **#110** owns View ABI; **#116** owns offload decorator → target clause mapping |

**Current Li state:** `@gpu` / `@cpu` decorators elaborate to MIR placement tags; `parallel for` lowers to pthread pool (host). OpenMP IR (`#pragma omp target …`) is **blocked** until **#34** receives `plan-approved`. Tier-2 physics benches (`md_lennard_jones`, `three_body`) compare host pure-Li or `shared_c_kernel` — no honest GPU offload column.

**Risk:** Agents implement ad-hoc CUDA stubs or weaken tier-2 thresholds before proved address-space separation (**G-gpu**) and OpenMP-target lowering gates exist.

## Vision / philosophy check

- **Pass** — rubric-only deliverable supports **provable then fast**; checklist precedes codegen.
- **Reject:** codegen in this issue; weakening `threshold_ratio_cpp`; `unsafe` / unproved `map` inference; claiming GPU perf without `G-gpu` closed slice.
- **Defer to #34:** LLVM OpenMP IR / MLIR `omp` emission — hard gate for any `target` lowering.
- **Defer to #110:** Kokkos View / mdspan memory-space ABI for tier-2 buffers.
- **Defer to #15:** general portable decorator elaboration policy.
- **Human-only:** `trusted.lean` changes; master-plan row merge; vendor runtime version pins.

## Scope

### In scope (this plan PR — docs only)

1. **Decorator → OpenMPTarget rubric table** — Li `@cpu` / `@gpu` / `@parallel` / `@vectorized` mapped to Kokkos OpenMPTarget execution + OpenMP `target` / `teams` / `distribute` / `map` clauses Li *can* lower once **#34** is approved.
2. **Memory-space pairing checklist** — host `array`/`tensor` vs device buffer tags aligned with Kokkos HostSpace / OpenMPTargetSpace semantics (feeds **#110**, does not duplicate View ABI).
3. **Host OpenMP companion column** — thread binding (`OMP_PROC_BIND`, `OMP_PLACES`) cross-link to **#129**; hybrid host+device occupancy notes.
4. **Explicit non-goals** — vendor CUDA/HIP native emit, Kokkos runtime in stdlib, automatic `map` without proofs, SYCL/oneAPI.
5. **Tier-2 physics bench scope notes** — which rows may claim offload in-scope vs `shared_c_kernel` oracle only until pure-Li + proofs land.
6. **PH / REQ / G / bench mapping** — tracker rows for implement pass after `plan-approved`.

### Out of scope

- Product codegen (`lic` MIR → LLVM `omp target`) — **blocked on #34 `plan-approved`**
- Kokkos View struct layout / stride ABI — **#110**
- Decorator elaboration implementation — **#15**
- Host affinity guard implementation — **#129**
- Benchmarks harness kernel code — **benchmarks** repo (ingest columns only, follow-up)
- `trusted.lean` / new axioms for device memory

## Rubric summary (normative detail in spec)

| Li surface | Kokkos OpenMPTarget analogue | OpenMP target lowering (post-#34) | Proof / gap |
|------------|------------------------------|-----------------------------------|-------------|
| `@cpu` on `def` | `Kokkos::Serial` / `Kokkos::OpenMP` host | Host `parallel` regions only | **G-par** |
| `@gpu` on `def` | `Kokkos::OpenMPTarget` execution space | `#pragma omp target teams distribute parallel for` | **G-gpu** (address space) |
| `@parallel(disjoint=…)` host | `Kokkos::parallel_for` on HostSpace | `#pragma omp parallel for` | **G-par** |
| `@parallel` in `@gpu` scope | `Kokkos::parallel_for` on device | `target teams distribute parallel for` | **G-gpu** + **G-par** |
| `@vectorized(lanes=N)` | SIMD width / vector lanes | Host SIMD / **not** `target simd` v1 | **G-dec** |
| Host `array` / `tensor` | `View` HostSpace | `map(tofrom:)` — default **avoid** without proof | **G-gpu** |
| `lig` device buffer | `View` OpenMPTargetSpace | `map(to:)` / `map(from:)` explicit | **G-gpu** Wave 13+ |
| `[execution] parallel_backend` | `Kokkos::Initialization` backend | `openmp_target` vs `portable_pthread` | **#129**, **#15** |
| `OMP_PROC_BIND` / `OMP_PLACES` | Kokkos OpenMP host tuning | Host only — see **#129** | ops |

## Tier-2 physics bench scope (honesty)

| Bench id | Offload in-scope when | Until then (oracle mode) | Notes |
|----------|----------------------|--------------------------|-------|
| `md_lennard_jones` | Pure-Li force loop + proved `disjoint=` + device buffer contract (**G-gpu** slice) + **#34** green | `shared_c_kernel` or host `pure_li` only | LJ cutoff + periodic box proofs stay host-first |
| `three_body` | Same + symplectic integrator proved on device buffer | `shared_c_kernel` / host `pure_li` | Chaotic hash correctness — no GPU column without proof |
| `nbody_gravity` | O(N²) kernel device offload after **#110** View ABI | Host `parallel for` scaling only | Barnes–Hut GPU deferred tier 4 |
| `heat_equation_2d` | Stencil offload **deferred** — host `@vectorized` first | Host SIMD column | GPU stencil = post-7e stretch goal |
| `wave_equation_1d` | Same as heat | Host only | CFL proof stays host |
| `double_pendulum` | Host only (chaos sensitivity) | `shared_c_kernel` | No GPU perf claims |

**Harness rule:** CSV `kernel_honesty` must not read `pure_li_gpu` until implement pass Phase 3 gates pass. No `threshold_ratio_cpp` edits to green incomplete offload.

## Implementation phases (after `plan-approved` — not this PR)

### Phase 0 — Rubric docs (can merge from this plan PR)

| Step | Path | Exit |
|------|------|------|
| 0.1 | [2026-06-07-li-openmptarget-offload-rubric.md](../specs/2026-06-07-li-openmptarget-offload-rubric.md) | Decorator ↔ OpenMPTarget ↔ OpenMP table complete |
| 0.2 | [tier2-offload-scope.md](../../benchmarks/tier2-offload-scope.md) | Tier-2 in-scope matrix + honesty labels |
| 0.3 | Cross-links in [decorators.md](../../language/decorators.md), [competitive-landscape.md](../../benchmarks/competitive-landscape.md) | `./scripts/check-doc-provability-claims.sh` green |

### Phase 1 — Gate on #34 (codegen prerequisite)

| Step | Dependency | Exit |
|------|------------|------|
| 1.1 | **#34** `plan-approved` + merged lowering plan | OpenMP IR mapping table signed off |
| 1.2 | `li-tests/parallel_codegen/` target smoke stubs | Compile-only; no perf claims |

**Hard stop:** No `omp target` emit in **lic** until 1.1.

### Phase 2 — Memory-space rubric → MIR tags (with #110)

| Step | Change | Notes |
|------|--------|-------|
| 2.1 | Extend `@gpu` MIR with `memory_space=host\|device` doc hook | ABI details in **#110** |
| 2.2 | `map` clause policy table in spec → codegen checklist | Proof required per clause kind |
| 2.3 | `swarm-gap-registry` close `gap-hpc-kokkos-execution-memory-spaces` partial row | After spec merge |

### Phase 3 — Tier-2 bench honesty columns (benchmarks follow-up)

| Step | Repo | Change |
|------|------|--------|
| 3.1 | **benchmarks** | `offload_backend`, `offload_in_scope` CSV columns |
| 3.2 | **benchmarks** | Tier-2 README links to `tier2-offload-scope.md` |
| 3.3 | **lic** | `check-hpc-competitive.sh` warns if registry claims GPU track without spec gate |

## PH / REQ / G / test mapping

| ID | Requirement | Verification |
|----|-------------|--------------|
| **PH-7e** | Portable parallel/offload lowering honesty | Rubric + tier-2 scope doc |
| **PH-7d** | Decorator elaboration policy | Table links to **#15** |
| **PH-7b** | Host OpenMP regions | Cross-link **#129**, **#34** |
| **REQ-offload-rubric-001** | Decorator → OpenMPTarget checklist | Spec § tables |
| **REQ-offload-gate-001** | No codegen before **#34** approved | Plan § Phase 1 gate |
| **REQ-tier2-honesty-001** | Offload in-scope vs shared-C documented | `tier2-offload-scope.md` |
| **G-par** | Host `parallel for` safety | Unchanged; device `parallel` adds **G-gpu** deps |
| **G-gpu** | Address-space / `map` proofs | Partial → rubric landed; proofs still open |
| **G-dec** | Decorator lowering | Cross-link **#15** |
| **Bench** | `md_lennard_jones`, `three_body`, `nbody_gravity` | Scope notes only in Phase 0 |
| **Bench** | `execution_resource_sweep` | Host occupancy (**#129**); device cols Phase 3 |

## Gap register updates (post-merge)

| Gap / registry id | Move | Evidence |
|-------------------|------|----------|
| **G-gpu** | Partial → Partial+rubric | Offload checklist doc (#116) |
| `gap-hpc-kokkos-execution-memory-spaces` | Partial → checklist landed | Spec link; full close with **#110** implement |
| Explorer digest row | Plan debt cleared | `swarm-gap-ingest.py` after plan merge |

## Files in this plan PR

| Path | Change |
|------|--------|
| `docs/superpowers/plans/2026-06-07-ph7e-kokkos-openmptarget-offload-rubric-116.md` | This plan |
| `docs/superpowers/specs/2026-06-07-li-openmptarget-offload-rubric.md` | Normative rubric |
| `docs/benchmarks/tier2-offload-scope.md` | Tier-2 in-scope / oracle matrix |

## Learned from

1. [Kokkos#2976 — OpenMPTarget backend](https://github.com/kokkos/kokkos/issues/2976) — vendor-agnostic GPU via OpenMP target
2. [OSTI portability study (compiler/vendor sensitivity)](https://www.osti.gov/servlets/purl/2224192) — defer vendor-runtime quirks to explicit non-goals
3. [2026-05-16-li-execution-decorators.md](../specs/2026-05-16-li-execution-decorators.md) — compile-time-only decorator semantics (**G-dec**)
4. [2026-05-14-benchmarks-and-simulations.md](2026-05-14-benchmarks-and-simulations.md) §Tier 2 — physics flagship correctness gates

## Acceptance criteria (plan-approved → implement)

- [ ] Normative rubric spec + tier-2 scope doc merged
- [ ] Decorator table links OpenMPTarget + host OpenMP + explicit non-goals
- [ ] **No codegen** merged until **#34** has `plan-approved` + linked lowering plan
- [ ] Tier-2 bench notes distinguish offload-in-scope vs `shared_c_kernel` oracle
- [ ] `check-doc-provability-claims.sh` green
- [ ] **G-gpu** row in `provability-gaps.md` cites rubric (proofs still open)
- [ ] #116 closable after docs merge + human `plan-approved`

## Handoffs

| Agent | Trigger |
|-------|---------|
| `issue_planner` | **#34** OpenMP IR lowering plan (if not yet `plan-approved`) |
| `issue_planner` | **#110** Kokkos View memory-space plan |
| `code_implementer` | After **`plan-approved`** on #116 **and** #34 — Phase 1+ only |
| `bench_improver` | benchmarks harness Phase 3 columns |
| Human maintainer | Merge plan PR; add **`plan-approved`** label; remove **`plan-needed`** |
