# MIR lowering for `object` field access and expanded parameters

## Summary

`object`-typed values are lowered as flattened per-field locals (`__li_o_<root>_<field>…`) for field access, assignment, `var`, expanded call arguments, same-type `var dst: T = srcIdent` slot copies, whole-object `dst = srcIdent` / `dst = foo()` assigns, and **LLVM struct returns** (`ReturnObject`, callee unpack) including `var w: T = foo()` when `foo` returns `T`.

## Agent continuation

1. Read `compiler/mir/include/li/mir.hpp` (`ReturnObject`, `MirFn::returns_object` / `return_object_layout`, `MirInsn::object_layout`), `compiler/mir/lower.cpp`, `compiler/codegen/emit.cpp`.
2. Run `cmake --build build` then `./li-tests/run_all.sh encapsulation` and `./li-tests/run_all.sh math_linalg` with `LIC` pointing at the built `lic`.
3. Next: nested object returns with mixed layouts; `extern proc` returning object; `typedict` parity; object locals declared only on one branch of `if` (shadowing / dominance).
4. Blocked: none for scalar-only object tests; array fields inside objects still not copied on `var` init.

## Changed

- `compiler/mir/include/li/mir.hpp` — `MirOp::ReturnObject`, `MirInsn::object_layout`, `MirFn::returns_object` / `return_object_layout`.
- `compiler/mir/lower.cpp` — `collect_object_return_layout_r`, `ReturnObject` lowering, object-return `CallProc` temps (`__li_o___cr*`), `var … = call()` copy from temp, implicit zero-struct return for object procedures, `collect_object_local_types` + whole-object `Assign` (`b = a`, `b = foo()`).
- `compiler/codegen/emit.cpp` — LLVM struct return types, `ReturnObject`, struct unpack on `CallProc`.
- `compiler/verify/vc_witness.cpp` — treat `ReturnObject` as a return terminator; link `return v` to `ReturnObject` with `__li_o_v` prefix.
- `li-tests/objects/object_return_call.li` — regression for callee returning `Vec3` consumed by `var`.
- `li-tests/objects/object_whole_assign.li` — regression for `b = a` and `c = unit_vec()`.
- `li-tests/manifest.toml` — register `object_return_call.li`, `object_whole_assign.li`.

## Not changed

- General scalar/control-flow codegen paths in `emit.cpp` beyond struct-return plumbing (`llvm_struct_from_layout`, `InsertValue`/`ExtractValue` for object layouts).
- `typedict` runtime layout (still not flattened in MIR).
- Parser, borrow checker, and verifier contracts for objects.
- Dominance: `object_locals` is a flat map from the whole procedure AST; assigning to a name that is not object-typed or not declared on all paths may still be accepted by the typechecker separately from MIR slot layout.
- `extern proc` returning a Li `object` type (no struct lowering contract).

## Breaking

N/A — fixes incorrect codegen for programs that already type-checked.

## Security

N/A.

## Performance

N/A — same stack locals as before for scalar `object` fields; more MIR parameters for object-by-value calls (ABI expansion).

## Downstream

Callers of procs that take `object` parameters must pass the same Li source (compiler expands arguments); no C ABI change for non-object programs.
