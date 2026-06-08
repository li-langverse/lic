# Phase 2e partial exit gates (G-vc / lic#21)

**Issue:** [lic#21](https://github.com/li-langverse/lic/issues/21) · **IDs:** PH-2e, G-vc

## Summary

- Added [phase 2e plan](../superpowers/plans/2026-05-14-phase-02e-contracts-vc.md) with explicit partial + full exit gates.
- Added `./scripts/check-phase-2e-exit-gates.sh` bundling `vc_emit_contracts.sh`, `mir_vc_witness.sh`, `contracts_discharge_corpus.sh`, and `vc_witness.cpp` presence checks.
- Updated master plan tracker + **G-vc** rows (status stays **Partial**; evidence cites CI gates).

## Verify

```bash
export LIC=./build-wsl/compiler/lic/lic  # or ./scripts/resolve-lic.sh
./scripts/check-phase-2e-exit-gates.sh
```
