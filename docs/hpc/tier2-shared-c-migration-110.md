# Tier-2 `shared_c_kernel` → explicit copy migration (lic#110)

**Pilot row:** `heat_equation_2d`  
**Secondary row:** `md_lennard_jones` (host-only path first; SoA layout via [#128](https://github.com/li-langverse/lic/issues/128))

## Today (shared C oracle)

| Row | Li driver | C core | Honesty label |
|-----|-----------|--------|---------------|
| `heat_equation_2d` | `extern proc li_heat_2d_kernel()` | `heat_core.c` via `LI_EXTRA_C` | `shared_c_kernel` |
| `md_lennard_jones` | `extern proc li_md_kernel()` | `md_core.c` via `LI_EXTRA_C` | `shared_c_kernel` |

The C oracle owns device-resident data implicitly (OpenMP team over host buffers). Li source has **no** memory-space tag and **no** explicit sync — acceptable only while `li_pure=False` and honesty is labeled.

## Staged migration — `heat_equation_2d`

### Stage 1 — Host-only pure-Li (current target after #110 policy)

- Replace `extern proc li_heat_2d_kernel()` with pure-Li explicit 2D stencil.
- Decorators: `@cpu` `@parallel(disjoint=…)`; `ExecutionSpace = OpenMP` (default).
- `MemorySpace = Host` only; no `devicebuffer` yet.
- Harness: checksum via `li_rt_volatile_sink_f64`; `li_pure=True`; drop `LI_EXTRA_C`.
- Gate: `benchmarks/harness/bench.py --tier 2 --only heat_equation_2d` checksum unchanged.

### Stage 2 — Explicit host/device buffer pair

```li
# Illustrative — names frozen after #128 layout ABI
var u_host: hostbuffer[f64]
var u_dev: devicebuffer[f64]
@sync_device(u_host, u_dev)   # explicit deep_copy analog
@gpu
def heat_step_dev() -> unit
  ...
@sync_host(u_dev, u_host)     # before host checksum
```

- No implicit DualView; host mirror is a **named** `hostbuffer[T]` paired with `devicebuffer[T]`.
- MIR telemetry must show sync points (**G-gpu** / **G-dec**).

### Stage 3 — Drop shared C

- Remove `heat_core.c` from harness `LI_EXTRA_C`.
- CSV row: `kernel_honesty = pure_li`.
- Competitive ratio gates unchanged until perf proof lands.

## Secondary — `md_lennard_jones`

| Stage | Focus | Blocker |
|-------|-------|---------|
| 1 | Host-only pure-Li velocity-Verlet | [#128](https://github.com/li-langverse/lic/issues/128) SoA layout |
| 2 | `hostbuffer`/`devicebuffer` + `@sync_device` | [#15](https://github.com/li-langverse/lic/issues/15) lowering |
| 3 | Drop `md_core.c` | Stage 2 green checksum |

## Checklist (issue #110)

- [x] `MemorySpace` / `ExecutionSpace` enums in `std/execution/memory_spaces.li`
- [x] Rubric doc: `docs/hpc/kokkos-memory-execution-spaces-rubric.md`
- [x] Migration appendix (this doc)
- [ ] Stage 1 pure-Li `heat_equation_2d` implementation (blocked on #128 stride names or host-only grid API)
- [ ] Kokkos 4.6.x vendor pin on **benchmarks** ([#27](https://github.com/li-langverse/benchmarks/issues/27))
