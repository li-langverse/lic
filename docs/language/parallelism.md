# Parallelism and vectorization (handbook)

Normative: [execution surface spec](../superpowers/specs/2026-05-25-li-execution-surface.md) · OpenMP rubric: [prescriptive vs descriptive](../superpowers/specs/2026-06-07-li-openmp-prescriptive-descriptive-rubric.md).

| You want | In `.li` | `lic` flags |
| -------- | -------- | ----------- |
| Multi-core | `parallel for` + disjoint | `--cores=8` |
| SIMD inner | `@vectorized(lanes=4)` | none |
| Prescriptive OpenMP | `@cpu(openmp=prescriptive)` | none (codegen Phase 2) |
| Descriptive / auto host | `@cpu(openmp=auto)` or omit | none |
| Fast CI | nothing | `lic check --workspace --jobs=8` |

## Prescriptive vs descriptive OpenMP (#124)

Li distinguishes **prescriptive** OpenMP (you or the compiler emit explicit `#pragma omp` stacks — teams, target, SIMD) from **descriptive** OpenMP (the compiler discovers parallelism from loop structure). Portable HPC code often needs **divergent backend branches** (CUDA/HIP/SYCL vs OpenMP host) to stay competitive with vendor-tuned libraries — the rubric documents when each path is required without weakening **G-par** disjoint proofs.

| Knob | Values | Effect (when codegen lands) |
| ---- | ------ | --------------------------- |
| `@cpu(openmp=…)` | `prescriptive`, `descriptive`, `auto`, `target` | Select OpenMP variant for host/offload lowering |
| `@parallel(schedule=…)` | `static`, `auto`, `dynamic` | Hint schedule for prescriptive `parallel for` |
| `[execution] parallel_style` | same as `openmp=` | Workspace default |

**Rules today (policy v1):**

- `@cpu(openmp=descriptive)` with `@gpu` on the same function is rejected — GPU offload requires prescriptive or `openmp=target`.
- `@cpu(openmp=target)` implies prescriptive target teams stacks (**#116** offload track).
- Default / `auto` prefers descriptive host loops until LLVM OpenMP IR (#34) is green; `lic build -v` will log the chosen variant.

**Not in v1:** silent prescriptive codegen, threshold weakening, or skipping `disjoint=` for offload branches. See [provability-gaps.md](../verification/provability-gaps.md) (**G-par**).

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
