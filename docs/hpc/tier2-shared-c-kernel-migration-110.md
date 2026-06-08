# Tier-2 migration: `shared_c_kernel` → explicit copy semantics

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110) · **Pilot:** `heat_equation_2d` · **Secondary:** `md_lennard_jones`

Today Rust/Julia competitive columns use `kernel_honesty = shared_c_kernel` — the C oracle may own buffers that Li wrappers treat as host-visible. Pure-Li tier-2 rows must **name** host/device placement and sync; no silent copy through `LI_EXTRA_C`.

## Row inventory

| Bench ID | Current Li path | `kernel_honesty` (competitive) | Oracle today |
|----------|-----------------|--------------------------------|--------------|
| `heat_equation_2d` | `sim_scientific_oracle_checksum_heat()` — host `array[8, float]` | Li: mixed; Rust/Julia: `shared_c_kernel` | Pure-Li 1D stencil in `packages/li-sim-scientific` |
| `md_lennard_jones` | tier-2 harness + C `md_core.c` | `shared_c_kernel` for Rust/Julia | Shared C core via `LI_EXTRA_C` |

## Migration rubric (all tier-2 `shared_c_kernel` rows)

1. **Inventory** — document which language column calls `LI_EXTRA_C` vs pure-Li (`benchmarks/results/README.md` honesty labels).
2. **Stage host-only** — pure-Li kernel on `MemorySpace.Host` with `@cpu` `@parallel` where proved; green checksum vs verify.py.
3. **Introduce buffers** — `hostbuffer[T]` + `devicebuffer[T]` pair; explicit `@sync_device` before device path (even if device path is stub until #116).
4. **Drop `LI_EXTRA_C`** for Li column only; competitive C++/Rust columns unchanged.
5. **Gate** — `li_pure=True` in harness metadata; `threshold_ratio_cpp` unchanged; no re-labeling green while Li still on shared C.

## Pilot: `heat_equation_2d` staged path

| Stage | Work | Exit gate |
|-------|------|-----------|
| **1** | Host-only: reuse `heat_oracle_stencil_step` / `sim_scientific_oracle_checksum_heat` in harness `li/main.li` | Checksum matches verify.py; `kernel_honesty` → `pure_li` for Li column |
| **2** | Add `hostbuffer[8, float]` + `devicebuffer[8, float]` pair; `@sync_device` before no-op `@gpu` stub kernel | Source shows explicit sync; MIR telemetry when #15 lands |
| **3** | Remove any `LI_EXTRA_C` link for Li driver; device kernel real when #116 ready | `li-tests/hpc/` compile_fail cross-space reads |

**Reference stencil (stage 1 — already on main):**

```163:209:packages/li-sim-scientific/src/lib.li
# WP-SCI-03 — tier-2 Li oracle: explicit 1D heat stencil (8-point grid).
def heat_oracle_stencil_step(u: var array[8, float], v: var array[8, float], r: float) -> unit
  ...
def sim_scientific_oracle_checksum_heat() -> float
  ...
```

Stage 2 specimen (spec — not wired to harness until parser):

```li
import std.hpc.memory

@cpu
def heat_equation_2d_host_stage(u: hostbuffer[float], v: hostbuffer[float], r: float) -> unit
  # same stencil on host mirrors
  ...

@cpu
def heat_equation_2d_sync_stage(u_host: hostbuffer[float], u_dev: devicebuffer[float]) -> unit
  @sync_device(u_dev)  # explicit — no DualView
```

## Secondary: `md_lennard_jones`

- **Stage 1:** host-only pure-Li forces (depends [#128](https://github.com/li-langverse/lic/issues/128) SoA layout).
- **Stage 2+:** same sync contract as heat; coordinate with `benchmarks/tier2_physics/md_lennard_jones`.

## Checklist (#110)

- [x] Migration rubric documented (this file)
- [x] `heat_equation_2d` staged path with explicit copy semantics named
- [x] `md_lennard_jones` called out as secondary
- [ ] Harness `li/main.li` stage 1 wire-up (follow-up after #128 layout)
- [ ] Stage 2 buffer pair in compiler (#15 / #116)
