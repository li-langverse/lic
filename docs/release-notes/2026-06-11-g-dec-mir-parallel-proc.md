# G-dec: `@parallel` MIR proc tag telemetry (7d-b)

**Date:** 2026-06-11  
**Gaps:** **G-dec** (Partial), **G-par** (related — disjoint witness)  
**Issue:** lic#2 — decorators beyond parse + policy (MIR lowering)

## Summary

Adds `mir_parallel_proc` `lic verify` telemetry for `@parallel` on `def`, completing the MIR proc-tag surface alongside `mir_vectorized_proc`, `mir_cpu_def`, and `mir_gpu_def`. Wires `check-mir-parallel-proc-decorator.sh` into master-plan gates and the 2f discharge corpus.

Updates master-plan tracker and [provability-gaps.md](../verification/provability-gaps.md) to cross-link **G-dec** / **G-par** exit gates for 7d-b–e.

## Gates

```bash
./scripts/build.sh
./scripts/check-mir-parallel-proc-decorator.sh
./li-tests/run_all.sh decorators decorator_exploits
```

## Not changed

- Lean **P-dec** proofs.
- Device LKIR lowering (**G-gpu**).
- Tier 2 MD `@cpu` `@parallel` `@vectorized` on `def` example.
