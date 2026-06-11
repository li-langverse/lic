# G-dec: 7d-b–e MIR lowering exit gate (lic#2)

**Date:** 2026-06-11  
**Gaps:** **G-dec** (Partial), **G-par** (Partial — Host `disjoint=` lowering cross-link)  
**Issue:** [lic#2](https://gitlab.lilangverse.xyz/li-langverse/lic/-/issues/2) — decorators beyond parse + policy (MIR lowering)

## Summary

Names explicit exit gates for master plan **7d-b–e** and adds a unified CI gate for decorator MIR lowering:

- `scripts/check-mir-decorator-lowering.sh` runs vectorized/gpu/cpu/parallel MIR telemetry, Host `li_parallel_for_i64` lowering, and `decorator_exploits` policy rejects.
- Master plan tracker, phase-07 plan, and `provability-gaps.md` cross-link **G-dec** and **G-par** where `disjoint=` Host lowering is exercised.

## Gates

```bash
./scripts/build.sh
./scripts/check-mir-decorator-lowering.sh
./scripts/check-master-plan-gates.sh  # includes unified gate
```

## Not changed

- Lean **P-dec** elaboration proofs.
- Device LKIR / address-space proofs (**G-gpu**).
- Tier 2 MD example with full `@` decorator stack on `def`.
