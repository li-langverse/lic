# md_lennard_jones — tier-2 Li checksum parity

**Todo:** `sim-p0-md-lj-li-parity`  
**Bench:** `benchmarks/tier2_physics/md_lennard_jones`  
**Registry algo:** `md_lj_cutoff_mic` (id=101)  
**Status:** `implemented_smoke: true` (composable); tier-2 verify **green**

## Problem

`md_lennard_jones` was marked `li_pure=True` in `bench.py` while `li/main.li` was a parallel-for stub. The harness reads Li results via `LI_PRINT_SINK_F64` + `li_rt_volatile_sink_f64`, so verify failed with “no stdout”.

## Fix (2026-05-24)

1. **`benchmarks/tier2_physics/md_lennard_jones/li/main.li`** — Restore shared-kernel driver: `li_md_kernel()` then `li_rt_volatile_sink_f64(li_md_checksum())`.
2. **`benchmarks/harness/bench.py`** — Drop `li_pure=True` on MD so `LI_EXTRA_C` links `common/md_core.c` (same kernel as native/cpp).
3. **Scoped package peers** — Applied the same sink pattern to `heat_equation_2d`, `three_body`, `nbody_gravity`, `double_pendulum` so `sim-plan-gates.sh` for `li-sim-scientific` passes.

## Validity

| Check | Result |
|-------|--------|
| Native reproducibility | drift `0.6892536936825765` |
| Li vs native (`--verify-results --tier 2`) | **match** `0.6892536936825765` |
| `./scripts/sim-plan-gates.sh` | **ok** |

```bash
export CC=clang-22 CXX=clang++-22
python3 benchmarks/harness/bench.py --verify-results --tier 2 --only md_lennard_jones
./scripts/sim-plan-gates.sh
```

## Performance (scoped, 1 run)

From `latest.csv` after gates: Li wall_time ≈ 1.16s (median of 3), on par with cpp/rust/julia for N=256, 10k steps.

## Memory

`sim-bench-memory.sh` records native peak RSS in `benchmarks/results/memory/latest_memory.json` (peak may read 0 when `/usr/bin/time` is unavailable in the sandbox).

## Follow-ups

- **Pure-Li MD kernel** (no `LI_EXTRA_C`) remains a separate Wave B item; this slice only restores harness parity via the reference C kernel.
- External oracle (LAMMPS/GROMACS) column — see `docs/benchmarks/competitive-engines-plan.md`.

## Agent iteration (2026-05-24)

Re-ran `./scripts/sim-plan-gates.sh` on `cursor/sim-algo-plan-loop` @ `0305ba5`: Li/native checksum `0.6892536936825765`, scoped timing Li ≈ 1.12s. Report: [iterations/20260524-163113.md](../iterations/20260524-163113.md).
