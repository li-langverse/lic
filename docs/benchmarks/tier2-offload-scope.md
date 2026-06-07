# Tier-2 physics benchmarks — GPU offload scope vs shared-C oracle

**Date:** 2026-06-07  
**Plan:** [#116](https://github.com/li-langverse/lic/issues/116) · **Rubric:** [openmptarget-offload-rubric](../superpowers/specs/2026-06-07-li-openmptarget-offload-rubric.md)

Li tier-2 physics simulations are **correctness-first** (energy/momentum invariants, symplectic stability). GPU offload is **optional perf** and only honest when proofs and drivers match the rubric.

## Honesty labels (CSV / registry)

| Label | Meaning |
|-------|---------|
| `pure_li_host` | Pure-Li driver, host `parallel for` / SIMD only |
| `shared_c_kernel` | Shared C reference kernel for cross-lang compare |
| `pure_li_gpu` | Pure-Li driver with proved device offload — **forbidden** until #116 Phase 3 + #34 codegen gates |
| `modeling_gap` | Extern stub; no perf claims |

## Per-benchmark matrix

| Bench id | Correctness gate | Offload in-scope when | Until then | Competitive column |
|----------|------------------|----------------------|------------|-------------------|
| `three_body` | COM / momentum invariants | Pure-Li integrator + `disjoint=` + **G-gpu** buffer proofs + **#34** target emit | `pure_li_host` or `shared_c_kernel` | `cpp` native OpenMP only |
| `nbody_gravity` | Same family as three_body | O(N²) device kernel after **#110** View ABI | Host scaling (`N` sweep) | No GPU column |
| `md_lennard_jones` | Energy drift < 0.1% / 10⁴ steps | Pure-Li LJ force + periodic box + device `map` proofs | `shared_c_kernel` common today | `cpp` MD reference |
| `heat_equation_2d` | L2 error vs analytical | **Deferred** — host `@vectorized` stencil first | `pure_li_host` | Host SIMD |
| `wave_equation_1d` | CFL + energy conservation | **Deferred** | `pure_li_host` | Host only |
| `double_pendulum` | Trajectory hash | **Never** GPU v1 (chaos sensitivity) | `shared_c_kernel` | Host |
| `harmonic_oscillator_chain` | Mode frequencies | Host only | `pure_li_host` | Host |

## When offload is **not** in-scope

- `kernel_honesty = shared_c_kernel` — do not add Li GPU timing column.  
- `modeling_gap` extern wrappers — tier-2 verifies checksum only.  
- **#34** lacks `plan-approved` — all rows host-only regardless of `@gpu` telemetry.  
- Oversubscribed host threads (**#129**) — annotate advisory speedup only when occupancy guard fires.

## Dashboard / ingest rules

1. No new `lang=li_gpu` CSV column until `pure_li_gpu` gates pass.  
2. `offload_in_scope=false` default for all tier-2 physics rows in ingest v1.  
3. Never lower `threshold_ratio_cpp` to green partial offload — file **lic** compiler issue (**PH-7e**).  
4. Registry `kokkos_openmptarget` stays `track = watch` until at least one row flips `offload_in_scope=true` with proof links.

## Related issues

- [#116](https://github.com/li-langverse/lic/issues/116) — this rubric  
- [#34](https://github.com/li-langverse/lic/issues/34) — OpenMP IR lowering gate  
- [#110](https://github.com/li-langverse/lic/issues/110) — memory-space / View ABI  
- [#129](https://github.com/li-langverse/lic/issues/129) — host affinity / occupancy
