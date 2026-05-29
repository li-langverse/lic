# Provability holes — cycle 13 (G-test-verify manifest honesty)

**north_star_fit:** ecosystem · PH-2e · PH-2f · G-test-verify

## Focus

Manifest outcome `verify_ok` runs plain `lic build` (`run_all.sh:91-98`) without `--strict-lean`. No `prove_lean_ok` outcome exists. True-stub certificates (`index_refinement.li`) pass both gates while AutoVC `requires := True`.

## Verified

- `manifest_verify_ok_honesty_gap.sh` — ok
- `contracts_discharge_corpus.sh` — ok (includes new harness)
- `sqrt_open_bound.li` correctly tiered as `verify_open_ok`

## Hypothesis

- `verify_ok` name overclaims proof when P-refine stubs remain True.

## Repro

```bash
bash li-tests/tooling/manifest_verify_ok_honesty_gap.sh
bash li-tests/tooling/contracts_discharge_corpus.sh
```
