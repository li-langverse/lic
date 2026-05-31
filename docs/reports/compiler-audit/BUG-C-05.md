# BUG-C-05 — Missing `witnessed_ensures_ident.li` in contracts_verify corpus

**Class:** Compiler (C)  
**Status:** Resolved (Phase 5 WP-DS-02) — specimen added  
**Affected tooling:** `li-tests/tooling/mir_vc_witness.sh`, `proof-db/expected.json`

## Summary

The proof-db discrepancy template and `proof-db/expected.json` reference `contracts_verify/witnessed_ensures_ident.li` as a canonical MIR-linked ensures witness specimen, but the file was absent from `li-tests/contracts_verify/`. CI slices that grep for `witnessed_ensures=` could not run against this anchor.

## Resolution

Added `li-tests/contracts_verify/witnessed_ensures_ident.li` — minimal identity function with `ensures result == x` and local return witness. Expected: `lic verify` reports `witnessed_ensures=1`, `mir_return_linked=1`.

## Verification

```bash
export LIC="$PWD/build/compiler/lic/lic"
"$LIC" verify li-tests/contracts_verify/witnessed_ensures_ident.li
# witnessed_ensures=1 mir_return_linked=1
bash li-tests/tooling/mir_vc_witness.sh  # uses discharge_const.li; sibling pattern
```

## References

- `li-tests/contracts_verify/witnessed_ensures_ident.li`
- `proof-db/discrepancies.toml` — example-lean-mir-witness row
- Plan WP-DS-02
