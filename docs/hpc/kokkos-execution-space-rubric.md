# Kokkos execution-space policy (OpenMP default, Threads opt-in)

**Status:** Spec (lic#110) · **REQ-ES-01**, **REQ-ES-02**  
**Parent:** [kokkos-memory-execution-spaces-rubric.md](kokkos-memory-execution-spaces-rubric.md)

## Default policy

| Tier | Default `ExecutionSpace` | Rationale |
|------|--------------------------|-----------|
| Tier-0 correctness | `Serial` | Deterministic smoke; no thread pool |
| Tier-1 micro | `OpenMP` when `LI_PARALLEL=1` | Matches existing `li_parallel_for_i64` team |
| Tier-2 physics | `OpenMP` | Aligns with C++ `-fopenmp` harness drivers and Kokkos `OpenMP` backend |

Li **does not** auto-select execution space at runtime. The decorator stack + `lic build --cores=N` fix the space at compile time.

## Kokkos::OpenMP vs Kokkos::Threads

Kokkos allows both `OpenMP` and `Threads` execution spaces in one build. Nesting them (or mixing with external OpenMP regions) causes oversubscription and undefined speedups — see [Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391).

| Policy | Li behavior |
|--------|-------------|
| **Default** | `ExecutionSpace.OpenMP` for `@parallel` on host memory |
| **Opt-in** | `ExecutionSpace.Threads` only when user sets `LI_EXEC_SPACE=threads` (env) **and** build does not link libomp for the same translation unit |
| **Reject** | `@parallel` + `@gpu` on the same `def` without explicit phase split (feeds #15) |
| **Document** | Link-time warning when both `Threads` and OpenMP runtime are detected (future `li_rt_exec_space_probe`) |

## Practitioner guidance (LAMMPS pattern)

From the [HPC Carpentry LAMMPS Kokkos+OpenMP guide](https://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html):

1. Pick **one** host parallel backend per process (OpenMP **or** pthreads, not both).
2. Size OpenMP teams to physical cores when a GPU backend also runs (avoid host oversubscription).
3. Stage host→device copies at timestep boundaries, not inside inner loops.

Li tier-2 pilot (`heat_equation_2d`) follows step 3 — see [shared-c-kernel-migration-appendix.md](shared-c-kernel-migration-appendix.md).

## Reserved execution spaces (#116)

| Space | Status | Notes |
|-------|--------|-------|
| `SYCL` | Reserved | Kokkos 4.6 SYCL production; Li offload via #116 |
| `Cuda` | Reserved | Maps to `lig` CUDA backend |
| `HIP` | Reserved | Maps to `lig` HIP backend |

These appear in `std/execution/memory_spaces.li` as enum variants for forward compatibility; no codegen until #116.

## Cross-links

- [execution decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md) — `@cpu`, `@gpu`, `@parallel` elaboration
- [#15 decorator lowering](https://github.com/li-langverse/lic/issues/15)
- [#129 NUMA affinity](https://github.com/li-langverse/lic/issues/129)
- `benchmarks/competitive/registry.toml` — `execution_resource_sweep` track for cores×threads matrix
