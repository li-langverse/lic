# heat_equation_2d — pure-Li smoke + tier-2 verify

**Todo:** `sim-p0-heat-li-smoke`  
**Bench:** `benchmarks/tier2_physics/heat_equation_2d`  
**Registry algo:** `pde_heat_explicit_2d` (id=201)  
**Status:** composable pure-Li smoke **partial**; tier-2 verify **green** (shared C kernel)

## Slice (2026-05-24)

1. **`packages/li-sim-scientific/src/lib.li`** — Replaced `run_heat_smoke` stub (`checksum = 1.0`) with pure-Li `heat_2d_field_init_sum()` over a 128×128 coordinate field (`heat_axis_coord` LUT, no bare cast). Composable checksum ≈ `6606.4384`.
2. **`benchmarks/tier2_physics/heat_equation_2d/li/main.li`** — Tier-2 driver keeps `heat_core.c` via `LI_EXTRA_C` + runtime sink (same pattern as MD parity).
3. **`li-tests/tooling/sim_li_run_summary.sh`** — Heat summary row uses composable checksum.

## Blocker: full pure-Li 2D stencil

Explicit 5-point Jacobi needs neighbor indices (`u[i±1][j]`, `u[i][j±1]`). Today `lic` rejects non-constant 2D offsets (**E0201**) unless routed through refinement-typed helpers; those helpers miscompile at `-O3` (sink `0`). **Parallel-for** row updates require disjoint proofs and still hit E0201 on offsets.

**Follow-up:** compiler/array (G-vc) — safe 2D neighbor indexing for PDE stencils; then flip `bench.py` `li_pure=True` and drop `LI_EXTRA_C` on this bench.

## Validity

| Check | Result |
|-------|--------|
| Native reproducibility | checksum `-3387.6965976796632` |
| Li vs native (`--verify-results --tier 2`) | **match** `-3387.6965976796632` (shared C kernel) |
| Composable `import_sim_scientific_run.li` | **ok** (pure-Li init-sum smoke) |
| `./scripts/sim-plan-gates.sh` | run in iteration |

```bash
export CC=clang-22 CXX=clang++-22
python3 benchmarks/harness/bench.py --verify-results --tier 2 --only heat_equation_2d
./scripts/sim-plan-gates.sh
```

## Performance (scoped)

Li wall_time ≈ 0.09s (package-scoped gates; on par with cpp/rust/julia).

## Memory

Native peak RSS recorded by `sim-bench-memory.sh` in `benchmarks/results/memory/latest_memory.json`.
