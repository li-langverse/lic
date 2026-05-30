# Runtime reference drivers (competitive refs only)

Parallel reduce sweep (`execution_resource_sweep` track):

- `reduce_parallel/li_native` — serial reference kernel (Li codegen target)
- `reduce_parallel/cpp_omp` — OpenMP team (`--threads=N`)
- `reduce_parallel/cpp_pthread` — pthread worker pool

Run: `python3 benchmarks/harness/execution_resource_sweep.py` or `bench.py --tier 6`.

CSV: `benchmarks/results/execution_resource_sweep.csv` (columns `li_native`, `cpp_omp`, `cpp_pthread` via `implementation`).

SIMD dot intrathread row uses `parallelism=simd_intrathread` (single OS thread, vector lanes only).
