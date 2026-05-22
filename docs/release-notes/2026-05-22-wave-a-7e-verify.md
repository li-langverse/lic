# Wave A 7e — tier-1 result verify (reference specs + harness)

## Summary

All five tier-1 micro benchmarks (`simd_dot`, `matmul_naive`, `matmul_blocked`, `reduce_sum`, `horner_pure_li`) pass normative `reference.py` small-spec self-checks and full-size Li/native checksum verify via `bench-verify-results.sh 1`.

## Changed

| Path | What |
|------|------|
| `benchmarks/harness/reference.py` | `verify_all_tier1_specs()` + `__main__` self-check |
| `scripts/bench-verify-results.sh` | Run `reference.py` before tier-1 harness verify |
| `scripts/compiler-studio-plan-gates.sh` | Explicit tier-1 reference phase |

## Verify

```bash
python3 benchmarks/harness/reference.py
./scripts/bench-verify-results.sh 1
./scripts/verify-math-physics-goldens.sh
./scripts/compiler-studio-plan-gates.sh
```
