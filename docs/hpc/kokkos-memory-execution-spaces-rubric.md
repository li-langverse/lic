# Kokkos 4.6 memory + execution spaces — tier-2 View lifecycle rubric

**Status:** Spec-only (plan-approved, #110) — no compiler codegen yet  
**Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**Plan:** [2026-06-07-kokkos-memory-execution-spaces-110.md](../superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md)  
**north_star_fit:** HPC / tier-2 physics · **PH-7e**, **PH-7d**, **G-par**, **G-gpu**  
**Vision:** Provable placement tags + explicit copy/sync before device perf; no silent DualView; Kokkos 4.6 alignment without Kokkos headers

---

## Context

Kokkos **4.5–4.6** shipped production **SYCL**, graph API improvements, H100-oriented reductions, and accelerated **DualView** deprecation ([4.6.02 release](https://github.com/kokkos/kokkos/releases/tag/4.6.02)). Li tier-2 physics benches still rely on **`shared_c_kernel`** catalog rows with no first-class **memory space** or **execution space** model beyond minimal `std/execution` decorators.

This rubric defines **where data lives**, **who may access it**, and **when explicit sync is required** — the policy matrix #110 owns. Strided layout ABI (`ndview` extents, SoA/AoS) lives in sibling [#128](https://github.com/li-langverse/lic/issues/128).

**Sibling issues (do not duplicate):**

| Issue | Owns |
|-------|------|
| [#128](https://github.com/li-langverse/lic/issues/128) | mdspan layout / stride ABI, `FieldSoA` / `FieldAoS` |
| [#15](https://github.com/li-langverse/lic/issues/15) | `@cpu` / `@gpu` / `@parallel` decorator elaboration → sync MIR tags |
| [#116](https://github.com/li-langverse/lic/issues/116) | OpenMPTarget / SYCL offload codegen |
| [#129](https://github.com/li-langverse/lic/issues/129) | NUMA / affinity maps to parallel policies |

---

## Competitive rubric (Kokkos 4.6 → Li policy matrix)

| Kokkos 4.6 concept | Li requirement | Proof / gate |
|--------------------|----------------|--------------|
| `Kokkos::MemorySpace` (`HostSpace`, `CudaSpace`, `HIPSpace`, `SYCLSpace`, `HBWSpace`) | `MemorySpace` enum: `Host`, `Device`, `Unified` (`Unified` documents HBW / managed memory alias) | Static placement tag on buffer type; no runtime space discovery |
| `Kokkos::ExecutionSpace` (`Serial`, `OpenMP`, `Threads`, `Cuda`, `HIP`, `SYCL`) | `ExecutionSpace` enum: `Serial`, `OpenMP`, `Threads` (v1 host); `Cuda` / `HIP` / `SYCL` reserved (#116) | Decorator stack selects space; default **OpenMP** for tier-2 |
| `Kokkos::View` lifecycle | `View[T, Space, Layout]` — allocate, use, destroy in **same** space unless explicit sync | Compile error on cross-space read without `@sync_*` |
| `deep_copy(src, dst)` | `@sync_host(view)`, `@sync_device(view)` — named, compile-visible | **G-par** + **G-gpu**: sync MIR tags in telemetry |
| `DualView` deprecation (4.6) | **No implicit dual view** — explicit `hostbuffer[T]` + `devicebuffer[T]` pair | Reject auto-sync-on-read APIs |
| Graph API / composite loops (#7513) | Defer graph capture to #15 / #116; serial staging for tier-2 pilot | Plan-only; no graph codegen in v1 |
| H100-oriented reductions | `@parallel(reduction=…)` + execution-space tag; perf after proof | Tier-2 bench unchanged until pure-Li lands |
| OpenMP vs Threads pool conflict ([Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391)) | Default `OpenMP`; `Threads` opt-in with runtime warning if libomp also linked | See [Execution space policy](#execution-space-policy) |

---

## Memory space enums (REQ-MS-01 / REQ-MS-02)

| Li `MemorySpace` | Kokkos analogue | Buffer type | Notes |
|------------------|-----------------|-------------|-------|
| `Host` | `HostSpace` | `hostbuffer[T]` | Authoritative for `@cpu` kernels; pageable or pinned |
| `Device` | `CudaSpace` / `HIPSpace` / `SYCLSpace` | `devicebuffer[T]` | GPU-resident; requires sync before host read |
| `Unified` | managed / HBW alias | `unifiedbuffer[T]` (reserved name) | Document-only in v1; codegen deferred to #116 |

**Static tag rule:** every owning buffer and non-owning `View` carries its `MemorySpace` in the type. Casting between spaces without `@sync_*` → **compile error** (E-mem-space).

**View surface (spec sketch):**

```text
# Not parsed yet — language design §Phase 3
type View[T, Space, Layout]   # non-owning slice over hostbuffer/devicebuffer/unifiedbuffer
var u_host: hostbuffer[f64, N * M]
var u_dev: devicebuffer[f64, N * M]
var v_host: View[f64, Host, layout_right] = u_host.view()
```

Lifecycle: construct view in same space as backing buffer; destroy view before buffer dealloc; cross-space view alias forbidden without proven sync chain.

Cross-link layout types: [#128 mdspan rubric](kokkos-mdspan-tier2-rubric.md) (when merged) · [language design §Phase 3](../superpowers/specs/2026-05-14-li-language-design.md#phase-3--hpc--scientific-shapes).

---

## Execution space policy (REQ-ES-01 / REQ-ES-02)

| Li `ExecutionSpace` | Kokkos analogue | v1 status | Tier-2 default |
|---------------------|-----------------|-----------|----------------|
| `Serial` | `Serial` | Spec + `@cpu` serial loops | Debug / checksum oracle |
| `OpenMP` | `OpenMP` | **Default** for `parallel for` on tier-2 | Yes |
| `Threads` | `Threads` | Opt-in; hazard documented | No (unless maintainer override) |
| `Cuda` / `HIP` / `SYCL` | device backends | Reserved names (#116) | N/A until offload lands |

### OpenMP vs Threads conflict

Kokkos practitioners report thread-pool conflicts when **OpenMP** and **Threads** execution spaces are both initialized in one process ([Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391); [LAMMPS tuning guide](https://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html)).

**Li policy (v1):**

1. Tier-2 harnesses and `parallel for` defaults use **`ExecutionSpace.OpenMP`**.
2. `ExecutionSpace.Threads` is **opt-in** via explicit config (TOML / env — names TBD in #15).
3. Runtime emits **warning** (not silent fallback) when both OpenMP and Li thread-pool backends are linked.
4. Do not nest Kokkos-style `Threads` team policies inside Li `parallel for` until #129 affinity map lands.

Decorator mapping (feeds #15):

| Decorator stack | Execution space | MIR tag (planned) |
|-----------------|-----------------|-----------------|
| `@cpu` only | `Serial` or `OpenMP` (config) | `exec_host` |
| `@parallel` | `OpenMP` (default) | `exec_omp` |
| `@gpu` | `Cuda` / `HIP` / `SYCL` (#116) | `exec_device` |

---

## Copy / sync contract (REQ-SYNC-01 / REQ-SYNC-02)

Kokkos 4.6 deprecates implicit `DualView` sync. Li requires **named, compile-visible** sync points before any cross-space read or kernel launch.

| Decorator stack | Buffer state | Required sync before read / launch | MIR tag (planned) |
|-----------------|-------------|-------------------------------------|-------------------|
| `@cpu` only | `hostbuffer[T]` | None (host authoritative) | `mem_host` |
| Host write → `@gpu` kernel | `devicebuffer[T]` | `@sync_device` after host write | `mem_sync_device` |
| `@gpu` kernel → host reduction | `devicebuffer[T]` → `hostbuffer[T]` | `@sync_host` before host read | `mem_sync_host` |
| `parallel for` on `hostbuffer` | host shared RAM | None (`disjoint=` required) | `mem_host_par` |
| `parallel for` on `devicebuffer` | device | `@sync_device` if host wrote since last launch | `mem_device_par` |
| Tier-2 `shared_c_kernel` oracle | extern C (opaque placement) | Document as `mem_extern` until pure-Li lands | `mem_extern` |
| Explicit host/device pair | `hostbuffer` + `devicebuffer` | `@sync_device` / `@sync_host` at coupling boundary | `mem_explicit_pair` |

**Compile-time obligations (post-#15 / codegen):**

1. Reading `devicebuffer[T]` after host-side write without `@sync_device` → **compile error** (E-mem-sync).
2. Passing `hostbuffer` slice to `@gpu` proc without proven pinned placement → **compile error** (E-mem-space).
3. Implicit DualView-style auto-sync on indexed read → **compile error** (E-mem-dualview).

Cross-links: [execution decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md) · [execution resources](../superpowers/specs/2026-05-25-li-execution-resources.md) · [#128 layout-side contract](kokkos-mdspan-tier2-rubric.md).

---

## shared_c_kernel → explicit copy migration (sub-phase D)

Today tier-2 **`shared_c_kernel`** rows link C oracles (`md_core.c`, heat stencil C, etc.) via `LI_EXTRA_C`. The C side may hold device-resident data opaquely; Li wrappers see only checksum sinks. Pure-Li migration **must** name every host↔device transition.

| Catalog id | Current variant | C oracle owns | Pure-Li staging requirement |
|------------|-----------------|---------------|----------------------------|
| `heat_equation_2d` | `shared_c_kernel` | Host stencil + opaque sink | Stage 1: host-only `heat_oracle_stencil_step`; Stage 2: explicit `hostbuffer`/`devicebuffer` + `@sync_device` |
| `md_lennard_jones` | `shared_c_kernel` | Host SoA force loop in C | Stage 1: `packages/li-sim-scientific` oracle; Stage 2: `FieldSoA` + sync at force launch |
| `three_body` | `shared_c_kernel` | Host integrator in C | Same pattern as MD — host-only first, device pair second |

**Migration rules:**

1. Do **not** drop `LI_EXTRA_C` until pure-Li row passes checksum **and** MIR dump shows explicit sync tags (no `mem_extern`).
2. Do **not** weaken `threshold_ratio_cpp` or re-label tier-2 green while on shared C.
3. Layout names (`grid`, `FieldSoA`) must match [#128](https://github.com/li-langverse/lic/issues/128) ABI before device staging.
4. Graph capture / composite loops (Kokkos 4.6 #7513) deferred — use serial staging path in pilot.

---

## Pilot row plan — `heat_equation_2d` (sub-phase E)

Single staged path from shared-C oracle to pure-Li with explicit memory-space semantics. Codegen **blocked** until this rubric + #128 ABI merge.

| Stage | State | Catalog `variant` | Gate |
|-------|-------|-------------------|------|
| **0** (today) | `shared_c_kernel` C oracle + Li wrapper checksum | `shared_c_kernel` | Checksum + ratio unchanged |
| **1** | Pure-Li 1D stencil (`heat_oracle_stencil_step` in `li-sim-scientific`) | `li_pure` (oracle only) | `sim_scientific_oracle_checksum_heat` in `li-tests` |
| **2** | `@cpu` `@parallel` over interior; host-only `grid[N,M,f64]` | `li_pure` (harness row, host) | `bench.py --tier 2 --only heat_equation_2d` green |
| **3** | `hostbuffer` + `devicebuffer` pair; `@sync_device` before device stencil | `li_pure` | MIR shows `mem_sync_device`; **G-gpu** obligation tracked |
| **4** | Drop `LI_EXTRA_C`; optional `@vectorized` inner loop | `li_pure` | Tier-2 ratio gate unchanged (no threshold weakening) |

**Do not:** edit `trusted.lean`, enable silent DualView, or ship device codegen before #116.

---

## Benchmarks vendor policy handoff (sub-phase F)

**Owner:** [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27) — lic does not edit `catalog.toml` thresholds.

Checklist for benchmarks agent / human PR:

- [ ] Pin Kokkos **4.6.x** (minimum **4.6.02**) in vendor policy doc when Kokkos driver rows are added
- [ ] Document SYCL backend parity expectation (production in 4.6; not required for Li tier-2 v1)
- [ ] Add `hpc_libraries.kokkos.li_status=watch` → `planned` when vendor pin merges
- [ ] Cross-link this rubric + [#128 mdspan rubric](kokkos-mdspan-tier2-rubric.md) from explorer digest
- [ ] No `threshold_ratio_cpp` changes in vendor-policy PR
- [ ] Track pure-Li variant expansion separately ([#41](https://github.com/li-langverse/benchmarks/issues/41))

---

## Tests / evidence (post-codegen)

| Artifact | Tier | Purpose |
|----------|------|---------|
| `heat_equation_2d` | 2 | Pilot migration target — explicit host→device staging |
| `md_lennard_jones` | 2 | Secondary row — host-only path first |
| `li-tests/hpc/memory_spaces/` (new suite) | — | `compile_fail` illegal device read without sync; `compile_ok` explicit sync chain |
| `benchmarks/harness/bench.py --tier 2` | 2 | Checksum + ratio gates unchanged |

---

## Sequencing

```mermaid
flowchart LR
  I128["#128 mdspan ABI"]
  I110["#110 memory spaces"]
  I15["#15 decorator lowering"]
  I116["#116 OpenMPTarget"]
  I128 --> I110
  I110 --> I15
  I15 --> I116
```

- **#128:** layout / stride / SoA-AoS ABI.
- **#110 (this doc):** memory-space + execution-space + View lifecycle.
- **#15 / #116:** lowering and offload after policy matrix is frozen.

---

## External signals

1. [Kokkos 4.6.02 release](https://github.com/kokkos/kokkos/releases/tag/4.6.02)
2. [Kokkos 4.6 composite loops / reductions (#7513)](https://github.com/kokkos/kokkos/issues/7513)
3. [Kokkos::OpenMP vs Threads (Trilinos #1391)](https://github.com/trilinos/Trilinos/issues/1391)
4. [LAMMPS Kokkos+OpenMP practitioner guide](https://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html)
5. [2026-05-20 explorer digest](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-20-explorer.md)
