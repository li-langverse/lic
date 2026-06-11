# PH-7d/G-dec: decorator MIR lowering exit gates (lic#2)

**Date:** 2026-06-11  
**Gaps:** **G-dec** (Partial), **G-par** (Partial)  
**Issue:** lic#2 — decorators beyond parse + policy (MIR lowering)

## Summary

Documents canonical **7d-b–e** exit gates with **G-dec** / **G-par** cross-links. MIR elaboration closed slices were already on `main`; this PR aligns phase tracker text with `check-mir-*-decorator.sh` evidence.

## Gates (doc + existing compiler slices)

```bash
./li-tests/run_all.sh decorators decorator_exploits
./scripts/check-mir-vectorized-decorator.sh
./scripts/check-mir-gpu-decorator.sh
./scripts/check-mir-parallel-decorator.sh
./scripts/check-mir-parallel-portable-lowering.sh
```

## Not changed

- Lean **P-dec** proofs.
- Full **G-par** kernel discharge (string heuristics in `policy.cpp` remain).
- Device LKIR lowering (**G-gpu**).
- `@async` elaboration.
