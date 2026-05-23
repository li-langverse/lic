# Wave D — physics.rigid tier-2 harden (2026-05-23)

## Summary

**wave-d-27-physics-deepen:** Harden `physics.rigid` gaming kernels (gravity + floor step, broadphase cell index) and wire tier-2 `rigid_body_stack` into `verify.py` checksum smoke.

## Changes

| Path | What |
|------|------|
| `packages/li-physics-rigid/src/lib.li` | `rigid_gravity_step_1d`, `rigid_floor_clamp_y`; fix `broadphase_cell_index`, `pgs_resolve_normal` |
| `benchmarks/tier2_physics/rigid_body_stack/li/main.li` | Checksum sink for harness verify |
| `benchmarks/harness/verify.py` | Tier-2 smoke: `rigid_body_stack` + Wave D note |
| `li-tests/composable/import_physics_rigid_gaming.li` | Gravity/floor + broadphase cell tests |
| `docs/ecosystem/vertical-algorithm-catalog.md` | gaming_rigid verify.py row |
| `benchmarks/competitive/verticals.toml` | gaming_rigid notes |

## Honesty

Tier-2 `rigid_body_stack` proves checksum parity vs `rigid_stack_core.c` only — **not** UE5/Bullet/Jolt parity (`workload_class=v0_gaming`).

## Verify

```bash
python3 benchmarks/harness/verify.py
./scripts/verify-math-physics-goldens.sh
./scripts/bench-verify-results.sh 1
./scripts/compiler-studio-plan-gates.sh
```
