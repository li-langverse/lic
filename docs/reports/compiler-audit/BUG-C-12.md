# BUG-C-12 — vec3_len CallProc ensures

**Gap script:** `li-tests/tooling/vec3_len_callproc_ensures_gap.sh`  
**Status:** Open

## Summary (from gap script)

G-vc / P-linalg / P-float: `vec3_len` CallProc ensures chain (`li_rt_sqrt(vec3_len_sq(a))`) opaque in AutoVC + trivial discharge; contrast `sqrt_open_bound` real `Float.abs` Prop (intentionally open).

## Owner action

Destub CallProc ensures emission for `vec3_len`; optional WP-CG-06 tracks specimen/catalog notes only (no compiler edits by agents).

## Specimens

- `li-tests/contracts_verify/linalg_vec3_len_*` — keep `proof_status` honest until gap passes.
