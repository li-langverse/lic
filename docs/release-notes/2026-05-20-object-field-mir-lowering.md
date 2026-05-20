# MIR lowering for `object` field access and expanded parameters

## Summary

`object`-typed values are lowered as flattened per-field locals (`__li_o_<root>_<field>…`) for field access, assignment, `var`, expanded call arguments, same-type `var dst: T = srcIdent` slot copies, whole-object `dst = srcIdent` / `dst = foo()` assigns, **element-wise copy of fixed `array[N, int|float]` fields**, and **LLVM struct returns** (`ReturnObject`, callee unpack) including `var w: T = foo()` when `foo` returns `T`.

## Agent continuation

1. Read `compiler/mir/include/li/mir.hpp` (`ReturnObject`, `MirFn::returns_object` / `return_object_layout`, `MirInsn::object_layout`), `compiler/mir/lower.cpp`, `compiler/codegen/emit.cpp`.
2. Run `cmake --build build` then `./li-tests/run_all.sh encapsulation` and `./li-tests/run_all.sh math_linalg` with `LIC` pointing at the built `lic`.
3. Next: extend `return_object_layout` + LLVM struct for array leaves (or forbid at typecheck); `extern proc` returning object; `typedict` parity.
4. Blocked: none for scalar-only object tests; `array[N, …]` inside objects is copied on `var`/assign only for `int`/`float` elements; object returns with array fields still omit arrays from `return_object_layout` / LLVM struct.

## Changed

- `compiler/mir/include/li/mir.hpp` — `MirOp::ReturnObject`, `MirInsn::object_layout`, `MirFn::returns_object` / `return_object_layout`.
- `compiler/mir/lower.cpp` — `collect_object_return_layout_r`, `ReturnObject` lowering, object-return `CallProc` temps (`__li_o___cr*`), `var … = call()` copy from temp, implicit zero-struct return for object procedures, `collect_object_local_types` + whole-object `Assign` (`b = a`, `b = foo()`), `emit_copy_array_slots_r`, `g_arr_ctx` registration for nested object arrays, `Index` / array `Assign` with `FieldAccess` bases, defer `g_arr_ctx` teardown until after implicit object return.
- `compiler/codegen/emit.cpp` — LLVM struct return types, `ReturnObject`, struct unpack on `CallProc`.
- `compiler/verify/vc_witness.cpp` — treat `ReturnObject` as a return terminator; link `return v` to `ReturnObject` with `__li_o_v` prefix.
- `li-tests/objects/object_array_field_copy.li` — regression for `array[2, int]` field deep copy (`var b = a` then mutate `a`).
- `li-tests/manifest.toml` — register `object_return_call.li`, `object_whole_assign.li`, `object_array_field_copy.li`.

## Not changed

- General scalar/control-flow codegen paths in `emit.cpp` beyond struct-return plumbing (`llvm_struct_from_layout`, `InsertValue`/`ExtractValue` for object layouts).
- `typedict` runtime layout (still not flattened in MIR).
- Parser, borrow checker, and verifier contracts for objects.
- Dominance: `object_locals` is a flat map from the whole procedure AST; assigning to a name that is not object-typed or not declared on all paths may still be accepted by the typechecker separately from MIR slot layout.
- `extern proc` returning a Li `object` type (no struct lowering contract).
- LLVM `ReturnObject` / `return_object_layout` still lists only scalar leaves; objects containing **array** fields are not fully returnable via struct pack yet.

## Breaking

N/A — fixes incorrect codegen for programs that already type-checked.

## Security

N/A.

## Performance

N/A — same stack locals as before for scalar `object` fields; more MIR parameters for object-by-value calls (ABI expansion).

## Downstream

Callers of procs that take `object` parameters must pass the same Li source (compiler expands arguments); no C ABI change for non-object programs.
