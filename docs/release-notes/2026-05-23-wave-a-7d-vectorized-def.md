# wave-a-7d — `@vectorized` on `def` MIR + G-par Lean roadmap

## Summary

`@vectorized` / `@vectorized(lanes=4)` on a `def` now sets `MirFn.vectorized_lanes` (default 4 when `lanes` omitted). Combining `@vectorized` and `@no_vectorize` on the same `def` is **E0323**. Proof corpus documents the **G-par** Lean disjoint roadmap (AST policy today; kernel proofs next).

## Agent deliverable

- [x] `MirFn.vectorized_lanes` from proc `@vectorized`
- [x] `LI_MIR_DECOR_FLAGS=1` verify smoke + `vectorized_def_mir_smoke.sh`
- [x] G-par disjoint Lean roadmap in `proof-corpus-roadmap.md`

## Changed

| Path | What |
|------|------|
| `compiler/mir/` | `vectorized_lanes`, `print_mir_decorator_flags` |
| `compiler/types/policy_module.cpp` | E0323 def conflict |
| `compiler/lic/main.cpp` | `LI_MIR_DECOR_FLAGS` |
| `li-tests/decorators/` | default lanes + conflict fail |
| `li-tests/tooling/vectorized_def_mir_smoke.sh` | MIR smoke |
| `docs/verification/proof-corpus-roadmap.md` | **P-par** Lean roadmap |
| `docs/verification/provability-gaps.md` | **G-dec** / **G-par** rows |

## Verify

```bash
./scripts/build.sh
./li-tests/tooling/vectorized_def_mir_smoke.sh
./li-tests/run_all.sh decorators
./scripts/compiler-studio-plan-gates.sh
```

## Not changed

- f64x8 / `lanes=8` codegen
- Full Lean discharge of `disjoint=` (**G-par** — roadmap only)
- Opt-in SIMD only when `@vectorized` present (default remains SIMD-on unless `@no_vectorize`)
