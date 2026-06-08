# OpenMPTarget offload checklist (Li decorators → host OpenMP + Kokkos-class target)

**Status:** Rubric only — **no codegen** until [lic#34](https://github.com/li-langverse/lic/issues/34) (LLVM OpenMP IR lowering plan) is approved and merged.  
**North star fit:** scientific computing / HPC — **G-par**, **PH-7e**  
**Related:** [Execution decorators](../language/decorators.md) · [decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md) · [Phase 7 native HPC](../superpowers/plans/2026-05-14-phase-07-native-hpc.md) · [lic#110](https://github.com/li-langverse/lic/issues/110) (Kokkos Views / memory spaces) · [lic#15](https://github.com/li-langverse/lic/issues/15) (decorators → portable lowering)

Gap explorer digest: [2026-05-20-explorer.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-20-explorer.md) (benchmarks repo).

## Purpose

Li `std/execution` decorators express **where** and **how** work runs. Kokkos **OpenMPTarget** is a vendor-agnostic GPU path built on OpenMP 4.5+ **target** directives. This checklist maps Li decorator intent to OpenMP semantics Li can eventually lower, host-side OpenMP team sizing, and Kokkos-class memory / thread-binding knobs — without pretending codegen exists today.

**External references (informative, not normative for Li):**

| Source | Topic |
|--------|-------|
| [Kokkos OpenMPTarget backend](https://github.com/kokkos/kokkos/issues/2976) | Vendor-agnostic GPU via OpenMP target |
| [Portability study (OSTI)](https://www.osti.gov/servlets/purl/2224192) | Compiler/vendor sensitivity for target offload |
| [Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391) | Prefer Kokkos::OpenMP over Threads when mixing with app threads |

---

## Decorator → OpenMP / OpenMPTarget rubric

Decorators are **compile-time only** ([spec](../superpowers/specs/2026-05-16-li-execution-decorators.md)). The table below is the **planned lowering target** once #34 lands; rows marked **today** describe what ships on `main`.

| Li decorator / knob | Host OpenMP (Kokkos::OpenMP class) | OpenMP target / teams (Kokkos OpenMPTarget class) | Li status |
|---------------------|-------------------------------------|---------------------------------------------------|-----------|
| `@cpu` on `def` | Default **Host** execution; no `target` region | N/A — stays on host | **Partial** — placement tag; host OpenMP via `parallel for` |
| `@parallel(disjoint=…)` on `def` / `parallel for` | `#pragma omp parallel for` + proved iteration independence (**G-par**) | Future: `#pragma omp target teams distribute parallel for` only after disjoint + address-space proofs | **Partial** — host `parallel for` + OpenMP lowering; target variant **blocked on #34** |
| `@vectorized(lanes=N)` on `for` | `#pragma omp simd` / LLVM vectorize on host lanes | `#pragma omp target simd` (device inner loop) — requires map + device copy proofs | **Partial** — host `@vectorized(lanes=4)` → `ArraySimdScope`; device **blocked on #34** |
| `@gpu` / `@gpu(devices=N)` on `def` | N/A | Maps to **OpenMPTarget execution space** intent (1..N devices); not vendor strings in source | **Partial** — MIR telemetry only ([G-gpu](../verification/provability-gaps.md#g-gpu)); no LKIR / target emit |
| `@serial`, `@no_vectorize` | Suppress parallel / SIMD on marked region | Same on host; device serial regions TBD | **Partial** — policy + MIR tags |
| `lic build --cores=N` | `OMP_NUM_THREADS` / team size for host parallel regions | Does **not** set device team size | **Done** — host runtime team |
| `lic build --threads-per-core=M` | `min(cores×M, 64)` host team cap | N/A | **Done** |
| `lic build --threads=N` | Overrides `--cores` for host team | N/A | **Done** |
| `OMP_PROC_BIND` / `OMP_PLACES` (env) | Pin host OpenMP workers (Kokkos::OpenMP best practice when mixing with app threads) | Separate device launch queue — **Li defers to vendor runtime** | **Not wired** — document-only; users may set env until Li exposes `[execution]` bind policy |
| `@async` | Host task / I/O scheduling (reactor) | Not a GPU offload path | **Stub** — effects spec only |

### OpenMP directive mapping (future codegen slice)

When #34 approves LLVM OpenMP IR lowering, Li should lower in this order of preference:

| OpenMP construct | Li source shape | Proof / policy gate |
|------------------|-----------------|---------------------|
| `target enter data map(to:…)` / `map(from:…)` | `@gpu` `def` params + return buffers with explicit device contracts | **G-gpu** address-space separation; no `Any` / `unsafe` |
| `target teams` | `@gpu` outer `def` with team-parallel outer loop | Device placement + team size from `devices=N` |
| `distribute parallel for` | `@parallel(disjoint=…)` on device loop | Same **G-par** disjoint proof as host |
| `target simd` | `@vectorized(lanes=N)` inside `@gpu` region | Lane width + map consistency |
| `map(tofrom:…)` | In-out arrays with proved non-aliasing | Borrow + disjoint witnesses |

**Non-goals (explicit deferrals to vendor runtime):**

- Source-level `@gpu(vendor="cuda")` or backend strings — **rejected today**; backend selection stays in `lig` config / runtime gates ([lig RFC](../game-dev/specs/lig-rfc.md)).
- Full **Kokkos View** lifecycle (reference counting, subviews, dual views) — tracked in **lic#110**; Li uses proved buffer contracts, not C++ View templates.
- Implicit unified memory / USM without proof — **deferred**; prefer explicit `map` until address-space lemmas land.
- Replacing libomp / vendor OpenMP target runtime with ad-hoc drivers — Li emits IR + links vendor runtime; does not reimplement OpenMPTarget scheduling.

---

## Memory space ↔ decorator checklist

Kokkos-class spaces inform Li naming and future `lig` runtime tables. Li does **not** expose Kokkos types in user code.

| Kokkos / OpenMP concept | Li surface (today / planned) | Notes |
|-------------------------|------------------------------|-------|
| `HostSpace` / host allocation | `@cpu`, stack + `array` / `tensor` on host | Default for tier-1 / tier-2 benches |
| `OpenMP` host execution space | `@cpu` + `@parallel` + `--cores` | Prefer over `Threads` when app already uses threads ([Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391)) |
| `OpenMPTarget` / `Cuda` / `HIP` device space | `@gpu(devices=N)` placement tag | Vendor picked by `lig`, not decorator args |
| `SharedSpace` / unified memory | **Non-goal v1** | Requires **G-gpu** proofs; cite honest **modeling_gap** until lemmas exist |
| `OMP_TARGET_OFFLOAD` env | **Vendor runtime** | Li docs may mention for ops; not set by `lic build` |

---

## Tier-2 physics benchmarks — offload scope vs shared-C oracle

Tier-2 rows live under `benchmarks/tier2_physics/` ([bench plan](../superpowers/plans/2026-05-14-benchmarks-and-simulations.md)). **Today every tier-2 physics harness uses a shared C reference kernel** (`common/*_core.c` or alias) for checksum / energy oracle parity. Li drivers are **`lic build`-able wrappers** around the same numerics — not device offload paths.

### In-scope for offload (future, after #34 + G-gpu)

| Benchmark family | Why offload may matter | Preconditions |
|------------------|------------------------|---------------|
| `nbody_gravity`, `md_lennard_jones`, `md_*` aliases | O(N²) or large-N force loops; SIMD + target teams candidate | #34 lowering approved; **G-par** disjoint on device loop; **G-gpu** buffer maps; tier-2 **correctness** still vs shared-C oracle on host reference column |
| `heat_equation_2d`, `wave_equation_1d`, `euler_fluid_2d` | Regular stencils; target teams + `@vectorized` inner | Same as above; stencil halo maps proved |
| Tier-3 `mlp_forward`, `conv2d_forward` (not tier-2) | Throughput kernels | **PH-ML-GPU** / `@gpu` LKIR track — separate from tier-2 physics oracle policy |

### Shared-C oracle only (current policy — do not claim GPU speed)

| Category | Examples | Rule |
|----------|----------|------|
| All tier-2 catalog rows until offload gate opens | `three_body`, `md_lennard_jones`, `cloth_swing`, `qm_*`, `bio_*`, … | CSV **li** column = host `parallel for` + SIMD only; compare to **cpp** shared kernel; no `target` column |
| Extern / `modeling_gap` wrappers | Tier-2 stubs with `ensures true` on extern | Correctness = checksum vs C; perf advisory only ([P-physics](../verification/proof-database/README.md)) |
| Tier-0 / tier-1 microkernels | `simd_dot`, `matmul_*` | Host SIMD / OpenMP only; tier-1 ≤1.2× C++ policy |

**Bench honesty rule:** Do not add an offload / GPU variant column to tier-2 physics until (1) #34 plan merged, (2) this checklist row updated to **Done**, and (3) `bench.py --tier 2` documents a separate `variant=target` label with shared `params.toml` and reference hash unchanged.

---

## Implementation gate checklist

Use this table in PRs that touch offload lowering (none expected until #34).

| ID | Gate | Owner | Status |
|----|------|-------|--------|
| **OMPT-01** | Rubric doc under `lic/docs/` | This file | **Done** |
| **OMPT-02** | Tier-2 scope notes (oracle vs offload) | § Tier-2 physics above | **Done** |
| **OMPT-03** | No codegen until #34 approved | Block all `target` / `@gpu` emit PRs | **Enforced** |
| **OMPT-04** | Cross-link from [decorators.md](../language/decorators.md) | Handbook | **Done** (same PR as OMPT-01) |
| **OMPT-05** | Update [provability-gaps.md](../verification/provability-gaps.md) when first target MIR lands | Future codegen PR | **Open** |
| **OMPT-06** | `li-tests/decorators/` + `parallel_codegen` smoke for host path only | #34 follow-up | **Open** |

---

## Agent / reviewer quick reference

1. **Docs-only PRs** (this issue) — no `lit test` codegen requirement; run `./scripts/check-doc-provability-claims.sh` if provability wording changes.
2. **Future codegen PRs** — require #34 link, **G-par** + **G-gpu** gap updates, and tier-2 bench policy row in this file flipped from **blocked** to **partial/done**.
3. **Prefer host OpenMP** (`@cpu`, `@parallel`, `--cores`) for tier-2 perf tables until OMPT-03 clears.
