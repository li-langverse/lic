#pragma once

#include "li/ast.hpp"

#include <cstdint>
#include <string>
#include <vector>

namespace li {

enum class MirOp {
  ReturnVoid,
  ReturnInt,
  ReturnFloat,
  ReturnIdent,
  /** Pack scalar locals named `ident + "_" + layout[i].name` into LLVM struct return. */
  ReturnObject,
  EchoInt,
  EchoString,
  CallExtern,
  CallProc,
  ArrayAlloc,
  ArrayStoreInt,
  ArrayLoadInt,
  ArrayStoreFloat,
  ArrayLoadFloat,
  ArrayDotF64,
  ArraySumF64,
  ArraySumI64,
  LocalAllocInt,
  LocalAllocI64,
  StoreInt,
  StoreI64,
  StoreFloat,
  LoadIntToIdent,
  BinOpInt,
  BinOpFloat,
  LocalAllocFloat,
  LocalAllocSimdF64,
  SimdSplatF64,
  SimdMulF64,
  SimdAddF64,
  SimdHorizSumF64,
  SimdCopyF64,
  OmpParallelFor,
  Label,
  Jump,
  BranchIfZero,
  AsyncAwait,
  AsyncFrameEnter,
  AsyncFrameLeave,
};

struct MirArg {
  bool is_literal = false;
  std::int64_t int_value = 0;
  std::string ident;
  bool is_string = false;
  std::string str_value;
};

struct MirParam {
  std::string name;
  bool is_float = false;
  bool is_string = false;
  bool is_i64 = false;
  bool is_simd_f64 = false;
  std::int64_t simd_lanes = 0;
};

struct MirInsn {
  MirOp op = MirOp::ReturnVoid;
  std::int64_t int_value = 0;
  double float_value = 0.0;
  std::string ident;
  std::string str_value;
  std::string callee;
  std::string lhs_ident;
  std::string rhs_ident;
  std::string label;
  BinOp bin_op = BinOp::Add;
  bool ret_is_float = false;
  bool index_is_literal = true;
  std::string index_ident;
  bool use_loaded_int = false;
  bool rhs_is_literal = true;
  std::int64_t rhs_int = 0;
  bool lhs_is_literal = false;
  std::int64_t lhs_int = 0;
  bool is_i64 = false;
  bool array_is_float = false;
  std::int64_t simd_lanes = 0;
  std::vector<MirArg> args;
  /** Leaf layout: `name` is path under object root (e.g. `x`, `mid_x`). Used for ReturnObject
   *  (pack) and CallProc when callee returns an object (unpack into `ident + "_" + name`). */
  std::vector<MirParam> object_layout;
};

struct MirDecorator {
  std::string name;
};

struct MirFn {
  std::string name;
  bool returns_float = false;
  bool returns_void = false;
  /** When true, LLVM return type is a struct; `return_object_layout` lists leaf fields. */
  bool returns_object = false;
  bool is_extern = false;
  bool is_async = false;
  std::vector<MirDecorator> decorators;
  std::vector<MirParam> params;
  /** Populated when `returns_object`; parallel to ReturnObject / unpack layout. */
  std::vector<MirParam> return_object_layout;
  std::vector<MirInsn> body;
};

struct MirModule {
  std::vector<MirFn> functions;
  bool uses_openmp = false;
  bool uses_async = false;
  /** When true: MIR stability pass + strict FP codegen (no fast-math reassociation). */
  bool fp_numerically_stable = false;
};

MirModule lower_to_mir(const Module& module);

}  // namespace li
