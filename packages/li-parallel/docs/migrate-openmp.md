# OpenMP → li-parallel migration

<!-- DOC-PAR-06 -->

Map common OpenMP patterns to native Li surfaces. Li does **not** link libomp for the li-parallel runtime — the persistent pool replaces `#pragma omp parallel`.

For the full Li ↔ RAJA ↔ Kokkos ↔ OpenMP policy matrix, see [portability-policy-matrix.md](portability-policy-matrix.md).

## Parallel loop

| OpenMP | Li |
|--------|-----|
| `#pragma omp parallel for` | `parallel for` + disjoint clause |
| `num_threads(N)` | `lic build … --cores=N` |
| `schedule(static)` | `LI_PAR_SCHEDULE=static` |
| `schedule(dynamic)` | `LI_PAR_SCHEDULE=dynamic` |
| `schedule(guided)` | `LI_PAR_SCHEDULE=guided` |

```c
// OpenMP
#pragma omp parallel for
for (int i = 0; i < N; ++i)
  a[i] = f(i);
```

```li
parallel for i in 0..<N
  requires disjoint_elem(i, a)
  decreases N - i
=
  a[i] = f(i)
```

```bash
lic build app.li -o app --cores=8
LI_PARALLEL=1 ./app
```

## Reduction

| OpenMP | Li |
|--------|-----|
| `#pragma omp parallel for reduction(+:s)` | `parallel for` + `reduce(+: s)` |

```li
var s: float = 0.0
parallel for i in 0..<N
  requires disjoint_elem(i, a)
  reduce(+: s)
  decreases N - i
=
  s = s + a[i]
```

## SIMD (inner loop)

| OpenMP | Li |
|--------|-----|
| `#pragma omp simd` | `@vectorized(lanes=8)` on inner `for` |

See [SIMD and parallel](../../../docs/language/simd-parallel.md).

## Not yet supported

| OpenMP | Li status |
|--------|-----------|
| `omp_get_thread_num()` | Use pool index via future `team()` API (WP-PAR-17) |
| `omp sections` | Use separate `parallel for` or `def` + `@parallel` |
| `omp task` | **Pending** |
| Device offload `#pragma omp target` | `@offload` + hetero plan (WP-PAR-07–09) |
