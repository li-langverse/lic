# MIR lowering for `object` field access and expanded parameters

## Summary

`object`-typed values are lowered as flattened per-field locals with deterministic MIR names (`__li_o_<root>_<field>…`), so field reads, assignments, `var` slots, and non-extern calls with object parameters match the type checker.

## Agent continuation

1. Read `compiler/mir/lower.cpp` (`mir_field_slot_for_expr`, `emit_object_slots_r`, `CallProc` argument expansion, `VarDecl` / `Assign` branches).
2. Run `cmake --build build` then `./li-tests/run_all.sh encapsulation` and `./li-tests/run_all.sh math_linalg` with `LIC` pointing at the built `lic`.
3. Next: lower object **return** values and `var x: T = callee()` copy-in for multi-field `T`; extend the same layout to `typedict` if product policy requires runtime parity.
4. Blocked: none for flat `object` tests; nested returns and `typedict` call ABI need a separate design pass.

## Changed

- `compiler/mir/lower.cpp` — object field MIR paths; `i64_locals` tracking for pointer-like scalar slots; `is_float_expr` handles `FieldAccess`; `CallProc` / `MirParam` expansion for object-typed parameters.
- `li-tests/objects/object_field_smoke.li` — regression for `limits.max_header_block` + `max_body` store/load.
- `li-tests/manifest.toml` — register `objects/object_field_smoke.li` under encapsulation suite.

## Not changed

- LLVM instruction selection outside existing `Store*` / `Load*` / `Call` paths (`emit.cpp` unchanged).
- `typedict` runtime layout (still not flattened in MIR).
- Parser, borrow checker, and verifier contracts for objects.

## Breaking

N/A — fixes incorrect codegen for programs that already type-checked.

## Security

N/A.

## Performance

N/A — same stack locals as before for scalar `object` fields; more MIR parameters for object-by-value calls (ABI expansion).

## Downstream

Callers of procs that take `object` parameters must pass the same Li source (compiler expands arguments); no C ABI change for non-object programs.
