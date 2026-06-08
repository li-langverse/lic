# Parallelism and vectorization (handbook)

Normative: [execution surface spec](../superpowers/specs/2026-05-25-li-execution-surface.md).

| You want | In `.li` | `lic` flags |
| -------- | -------- | ----------- |
| Multi-core | `parallel for` + disjoint | `--cores=8` |
| SIMD inner | `@vectorized(lanes=8)` | none |
| Fast CI | nothing | `lic check --workspace --jobs=8` |

## Example 1 — MD kernel

```nim
parallel for i in 0..<N
  requires disjoint_atom(i, forces)
  decreases N - i
=
  @vectorized(lanes=4)
  for k in 0..<n_neighbors(i)
    accumulate_lj(i, k, positions, forces)
```

```bash
lic build md_step.li -o md_step --cores=8 --threads-per-core=1
```

## Example 2 — Dot product (SIMD only)

```nim
@vectorized(lanes=8)
for i in 0..<N
  ...
```

## Example 3 — Workspace (compile farm)

```bash
lic check --workspace path/to/li.toml --jobs=8 --max-memory=4096
```

## Thread affinity (OpenMP backend)

When Li lowers `parallel for` through the **OpenMP prescriptive** backend (#34), HPC best practice applies:

| Variable | Typical value | Purpose |
| -------- | ------------- | ------- |
| `OMP_NUM_THREADS` | match Li team size | OpenMP team (Li `--cores` / `--threads` bakes team into the binary) |
| `OMP_PROC_BIND` | `spread` | Spread threads across cores |
| `OMP_PLACES` | `threads` | Place threads on hardware threads |

Li’s default **portable pthread pool** does not set these variables. Export them before launch when linking OpenMP, or wait for `parallel_backend=openmp_prescriptive` (lic#129 Phase 2).

See [OpenMP affinity rubric spec](../superpowers/specs/2026-06-07-li-openmp-affinity-occupancy-rubric.md).

## Hybrid MPI + OpenMP {#hybrid-mpi-openmp}

On clusters, **MPI ranks × OpenMP threads per rank** should not exceed **physical cores** on the node ([HPC Carpentry Kokkos+OpenMP tuning](http://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html)).

Li reads `OMPI_COMM_WORLD_SIZE` or `PMI_SIZE` at runtime (no MPI runtime in stdlib). When the product exceeds detected cores, `lic` emits a **one-shot warning** on stderr:

```text
lic: warning: parallel team (N) × mpi_ranks (M) = T exceeds physical cores (C); ...
```

Disable with `LI_EXEC_WARN_OVERSUBSCRIBE=0` (e.g. deliberate oversubscribe experiments). The warning is diagnostic only — proved `disjoint=` semantics are unchanged.

Example sizing:

```bash
# 4 cores/node, 2 MPI ranks → use --threads=2 (or --cores=2) per rank
export OMPI_COMM_WORLD_SIZE=2
lic build md_step.li -o md_step --cores=2 --threads-per-core=1
./md_step
```
