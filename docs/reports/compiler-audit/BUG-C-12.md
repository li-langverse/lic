# BUG-C-12 — vec3_len CallProc ensures

**Gap script:** `li-tests/tooling/vec3_len_callproc_ensures_gap.sh`  
**Status:** Resolved

## Summary

G-vc / P-linalg / P-float: `vec3_len` / `vec3_len_sq` CallProc ensures chain discharges via `Li.Discharge.vec3_len_spec` / `vec3_len_sq_spec`; `sqrt_open_bound` control stays intentionally open (`Float.abs`, no `_proved`).

## Resolution

- `witness_vec3_len_*` in `vc_witness.cpp`; eval stubs in `Discharge.lean`
- `expr_same_shape` extended for `FieldAccess` and `Call`
- `sqrt_open` proc excluded from auto sqrt discharge (open control specimen)
