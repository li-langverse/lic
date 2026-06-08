# Execution policy portability matrix (Li ↔ RAJA ↔ Kokkos ↔ OpenMP)

<!-- DOC-PAR-11 -->

**Gaps:** **G-par**, **PH-7e**  
**Issue:** [lic#109](https://github.com/li-langverse/lic/issues/109)  
**References:** [ICS 2025 portability study](https://pssg.cs.umd.edu/assets/papers/2025-06-portability-ics.pdf), [Kokkos programming model](https://performanceportability.org/perfport/frameworks/kokkos/)

Li maps source-level execution decorators and `parallel for` to a **documented policy set** at `lic build` time. Illegal stacks or missing `disjoint=` are compile errors — there is no silent serial fallback for proved `@parallel` / `parallel for`.

## Policy matrix

| Li surface | MIR / codegen | RAJA policy | Kokkos policy | OpenMP schedule / directive |
|------------|---------------|-------------|---------------|----------------------------|
| `for` (serial) | scalar loop | `RAJA::seq_exec` | `Kokkos::Serial` | (none) |
| `@serial` on `def` / loop | scalar loop | `RAJA::seq_exec` | `Kokkos::Serial` | (none) |
| `parallel for` + `disjoint_*` | `OmpParallelFor` → `li_parallel_for_i64` | `RAJA::omp_parallel_exec` | `Kokkos::parallel_for` + `RangePolicy` on `DefaultHostExecutionSpace` | `#pragma omp parallel for` |
| `@parallel(disjoint=…)` on `def` | inherits to nested `parallel for` | same as row above | same as row above | same as row above |
| `LI_PAR_SCHEDULE=static` | static chunk partition in `li_par_pool.c` | `RAJA::omp_parallel_exec` + static tiling | `RangePolicy` with static chunk size | `schedule(static)` |
| `LI_PAR_SCHEDULE=dynamic` | dynamic work queue | `RAJA::omp_parallel_exec` + dynamic | `RangePolicy` dynamic | `schedule(dynamic)` |
| `LI_PAR_SCHEDULE=guided` | guided decay | guided tiling | guided chunk | `schedule(guided)` |
| `LI_PAR_SCHEDULE=steal` | work-stealing deque | task-style steal (conceptual) | `Kokkos::parallel_for` + work stealing backend | `schedule(guided)` (approx.) |
| `reduce(+: s)` on `parallel for` | `li_parallel_for_reduce_add_f64` | `RAJA::ReduceSum` + `forall` | `Kokkos::parallel_reduce` | `reduction(+:s)` |
| `@vectorized(lanes=N)` | SIMD LLVM lanes only | `RAJA::simd_exec` (conceptual) | vectorization intrinsic path | `#pragma omp simd` |
| `@cpu` | host placement tag | host execution policies | `HostSpace` | host thread |
| `@gpu` | MIR placement tag (G-gpu lowering open) | `RAJA::cuda_exec` / `RAJA::hip_exec` | `Cuda` / `HIP` execution space | `#pragma omp target teams distribute` (future) |
| `@no_vectorize` | scalar inner loops | `seq_exec` inner | serial inner | `simd` suppressed |

### Verify telemetry (no silent serial fallback)

`lic verify` reports parallel lowering explicitly:

```text
mir_parallel_disjoint=1 mir_omp_parallel_for=1
```

- `mir_parallel_disjoint` — `@parallel` / `parallel for` with policy-accepted disjoint witness (**G-par**).
- `mir_omp_parallel_for` — `OmpParallelFor` MIR sites that lower to `li_parallel_for_i64` (or OpenMP runtime symbol when enabled).

Gate: `./scripts/check-mir-parallel-decorator.sh` requires both counters ≥ 1 and a `li_omp_parallel_for_i64` link symbol on decorated samples.

## Tier-1 example: `reduce_sum`

Side-by-side policy documentation for the tier-1 `reduce_sum` micro-kernel (registry: `benchmarks/competitive/registry.toml`).

### Li (proved disjoint + tree reduce)

```li
def reduce_sum_f64(data: array[N, f64]) -> f64
  requires true
  ensures true
=
  var s: f64 = 0.0
  parallel for i in 0..<N
    requires disjoint_elem(i, data)
    reduce(+: s)
    decreases N - i
  =
    s = s + data[i]
  return s
```

```bash
lic build reduce_sum.li -o reduce_sum --cores=8
LI_PARALLEL=1 LI_PAR_SCHEDULE=static ./reduce_sum
lic verify reduce_sum.li   # expect mir_omp_parallel_for>=1
```

**Lowering:** `OmpParallelFor` + `reduce(+: s)` → `li_parallel_for_reduce_add_f64(start, end, body, &s, team_size)`.

### RAJA (reference parity doc)

```cpp
using Pol = RAJA::omp_parallel_exec;
RAJA::ReduceSum<double, RAJA::omp_reduce> sum(0.0);
RAJA::forall<Pol>(RAJA::RangeSegment(0, N),
  [&](int i) { sum += data[i]; });
double result = sum.get();
```

Policy: `omp_parallel_exec` + `ReduceSum` reducer — matches Li `parallel for` + `reduce(+:)` when `LI_PAR_SCHEDULE=static`.

### Kokkos (reference parity doc)

```cpp
double result = 0.0;
Kokkos::parallel_reduce(
  "reduce_sum", Kokkos::RangePolicy<>(0, N),
  KOKKOS_LAMBDA(const int i, double& lsum) { lsum += data[i]; },
  result);
```

Policy: `DefaultHostExecutionSpace` + `RangePolicy` — Li `--cores=N` maps to Kokkos team size via runtime pool.

### OpenMP (reference parity doc)

```c
double s = 0.0;
#pragma omp parallel for reduction(+:s) schedule(static)
for (int i = 0; i < N; ++i)
  s += data[i];
```

Policy: `schedule(static)` ↔ `LI_PAR_SCHEDULE=static`; `reduction(+:s)` ↔ Li `reduce(+: s)`.

## Honesty / not yet portable

| Surface | Status |
|---------|--------|
| Host `parallel for` + schedule env | **Implemented** — pool + verify telemetry |
| `@gpu` device policies | **MIR tag only** — no RAJA/Kokkos GPU lowering yet (**G-gpu**) |
| SYCL / HIP direct drivers | **Watch** — competitive registry only |
| RAJA reference harness row | **Optional** — parity documentation; no RAJA dep in CI |

## Related docs

- [migrate-openmp.md](migrate-openmp.md) — OpenMP → Li mapping
- [api-shared-memory.md](api-shared-memory.md) — runtime symbols and env knobs
- [proofs-table.md](proofs-table.md) — G-par proof status
