# Wave B tier-2 verify — md_lennard_jones + heat PDE smoke

## Summary

`verify.py` now runs tier-2 physics smokes for `md_lennard_jones` (energy drift checksum vs native `md_core.c`) and `heat_equation_2d` (PDE stencil checksum). Li drivers sink results via `li_rt_volatile_sink_f64` so harness verify can read checksums.

## Changed

| Path | What |
|------|------|
| `benchmarks/harness/verify.py` | Tier-2 smoke: `md_lennard_jones`, `heat_equation_2d` |
| `benchmarks/tier2_physics/md_lennard_jones/li/main.li` | Restore C-kernel driver + checksum sink |
| `benchmarks/tier2_physics/heat_equation_2d/li/main.li` | Checksum sink for PDE verify |
| `benchmarks/harness/bench.py` | `md_lennard_jones` uses shared C kernel (not `li_pure`) |
| `scripts/compiler-studio-plan-gates.sh` | Tier-2 verify.py phase |
| `li-tests/tooling/tier2_physics_verify_smoke.sh` | Standalone gate script |

## Verify

```bash
python3 benchmarks/harness/verify.py
./scripts/verify-math-physics-goldens.sh
./scripts/bench-verify-results.sh 1
./scripts/compiler-studio-plan-gates.sh
```
